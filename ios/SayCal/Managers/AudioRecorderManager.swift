import SwiftUI
import AVFoundation
import Supabase
import Combine

enum ProcessingState: Equatable {
    case idle
    case recording
    case transcribing
    case analyzing(transcription: String)
    case completed(transcription: String, response: NutritionResponse)
    case error(message: String)
    
    var isProcessing: Bool {
        switch self {
        case .idle, .completed, .error:
            return false
        case .recording, .transcribing, .analyzing:
            return true
        }
    }
    
    var transcription: String? {
        switch self {
        case .analyzing(let transcription), .completed(let transcription, _):
            return transcription
        default:
            return nil
        }
    }
    
    var nutritionResponse: NutritionResponse? {
        if case .completed(_, let response) = self {
            return response
        }
        return nil
    }
    
    static func == (lhs: ProcessingState, rhs: ProcessingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.recording, .recording), (.transcribing, .transcribing):
            return true
        case (.analyzing(let l), .analyzing(let r)):
            return l == r
        case (.error(let l), .error(let r)):
            return l == r
        case (.completed(let lt, _), .completed(let rt, _)):
            return lt == rt
        default:
            return false
        }
    }
}

@MainActor
class AudioRecorder: NSObject, ObservableObject {
    @Published var state: ProcessingState = .idle
    @Published var currentAudioLevel: CGFloat = 1.0

    private var audioRecorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private var recordingURL: URL?
    private var maxAudioLevel: Float = -160.0
    private var hasSignificantAudio = false

    var isRecording: Bool {
        if case .recording = state { return true }
        return false
    }
    
    var isProcessing: Bool {
        state.isProcessing
    }
    
    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }

    func requestPermission() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            print(granted ? "✅ Microphone access granted" : "❌ Microphone access denied")
            if !granted {
                Task { @MainActor [weak self] in
                    self?.state = .error(message: "Microphone access denied. Please enable in Settings.")
                }
            }
        }
    }

    // MARK: - Recording
    
    func startRecording() {
        HapticManager.shared.medium()
        state = .recording
        maxAudioLevel = -160.0
        hasSignificantAudio = false

        let tempDir = FileManager.default.temporaryDirectory
        recordingURL = tempDir.appendingPathComponent(UUID().uuidString + ".m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            let didStart = audioRecorder?.record() ?? false
            startLevelMonitoring()
            print("🎙️ Recording started: \(didStart)")
            print("🎙️ Recording URL: \(recordingURL?.path ?? "unknown")")
        } catch {
            print("❌ Failed to start recording: \(error)")
            state = .error(message: "Failed to start recording")
        }
    }

    func stopRecording() {
        HapticManager.shared.medium()
        audioRecorder?.stop()
        stopLevelMonitoring()

        guard hasSignificantAudio, maxAudioLevel >= -50.0 else {
            print("⚠️ No significant audio detected (max level: \(maxAudioLevel) dB)")
            state = .error(message: "No audio detected. Please speak clearly into the microphone.")
            HapticManager.shared.error()
            cleanupRecording()
            return
        }

        guard let url = recordingURL else { return }
        
        print("💾 Recording stopped, processing...")
        state = .transcribing
        
        Task {
            await processRecording(url)
        }
    }
    
    private func cleanupRecording() {
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
    }

    // MARK: - Audio Level Monitoring
    
    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                self?.updateAudioLevel()
            }
        }
    }
    
    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        currentAudioLevel = 1.0
    }

    private func updateAudioLevel() {
        guard let recorder = audioRecorder else {
            print("⚠️ No recorder in updateAudioLevel")
            return
        }

        guard recorder.isRecording else {
            print("⚠️ Recorder not recording")
            return
        }

        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        let peakPower = recorder.peakPower(forChannel: 0)

        maxAudioLevel = max(maxAudioLevel, peakPower)
        if peakPower > -40.0 { hasSignificantAudio = true }

        if Int.random(in: 0..<100) == 0 {
            print("🎤 Audio levels - avg: \(averagePower) dB, peak: \(peakPower) dB, max: \(maxAudioLevel) dB")
        }

        // Normalize -50dB to 0dB range
        let normalized = max(0, min(1, (averagePower + 50) / 50))
        let targetLevel = CGFloat(pow(normalized, 0.7))

        // Smooth transitions
        let rate: CGFloat = targetLevel < currentAudioLevel ? 0.3 : 0.8
        currentAudioLevel = currentAudioLevel * (1 - rate) + targetLevel * rate
    }

    // MARK: - Processing Pipeline
    
    private func processRecording(_ fileURL: URL) async {
        defer { cleanupRecording() }
        
        // Step 1: Transcribe
        guard let transcription = await transcribe(fileURL) else { return }
        
        state = .analyzing(transcription: transcription)
        HapticManager.shared.success()
        
        // Step 2: Analyze nutrition
        await analyzeNutrition(transcription: transcription)
    }
    
    // MARK: - Local Transcription (On-Device)

    private func transcribe(_ fileURL: URL) async -> String? {
        do {
            let transcription = try await LocalTranscriptionManager.shared.transcribe(audioFileURL: fileURL)
            print("✅ Local transcription: \(transcription)")
            return transcription

        } catch TranscriptionError.modelNotLoaded {
            state = .error(message: "Loading speech model... Please try again in a moment.")
            HapticManager.shared.error()
            return nil

        } catch TranscriptionError.noSpeechDetected {
            state = .error(message: "No speech detected")
            HapticManager.shared.error()
            return nil

        } catch {
            print("❌ Local transcription failed: \(error)")
            state = .error(message: "Failed to transcribe audio")
            HapticManager.shared.error()
            return nil
        }
    }

    private func analyzeNutrition(transcription: String) async {
        do {
            print("🧮 Analyzing nutrition...")
            
            let response: NutritionResponse = try await SupabaseManager.client.functions.invoke(
                "calculate-calories",
                options: FunctionInvokeOptions(
                    body: ["transcribed_meal": transcription]
                )
            )
            
            state = .completed(transcription: transcription, response: response)
            HapticManager.shared.success()
            print(response)
            print("✅ Analysis complete")
            
        } catch {
            print("❌ Analysis failed: \(error)")
            state = .error(message: "Failed to analyze nutrition")
            HapticManager.shared.error()
        }
    }
}

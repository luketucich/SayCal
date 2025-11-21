import SwiftUI
import AVFoundation
import Combine
import Supabase

// MARK: - Models

struct TranscriptionResponse: Codable {
    let text: String
}

// MARK: - Processing State

enum ProcessingState {
    case idle
    case recording
    case transcribing
    case calculatingNutrition(transcription: String)
    case streamingNutrition(transcription: String, partialInfo: String)
    case completed(nutritionInfo: String)
    case error(message: String)

    var isProcessing: Bool {
        switch self {
        case .idle, .completed, .error: return false
        case .recording, .transcribing, .calculatingNutrition, .streamingNutrition: return true
        }
    }

    var isRecording: Bool {
        if case .recording = self { return true }
        return false
    }
}

// MARK: - Audio Recorder

class AudioRecorder: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var state: ProcessingState = .idle
    @Published var currentAudioLevel: CGFloat = 1.0

    // MARK: - Private Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioLevelTimer: Timer?
    private var recordingURL: URL?
    private var realtimeChannel: Task<Void, Never>?

    // MARK: - Computed Properties

    var displayText: String {
        switch state {
        case .idle:
            return ""
        case .recording:
            return "Recording..."
        case .transcribing:
            return "Transcribing..."
        case .calculatingNutrition(let transcription):
            return "Calculating:\n\(transcription)"
        case .streamingNutrition(_, let partialInfo):
            return partialInfo
        case .completed(let nutritionInfo):
            return nutritionInfo
        case .error(let message):
            return "Error: \(message)"
        }
    }

    var isRecording: Bool {
        state.isRecording
    }

    var isProcessing: Bool {
        state.isProcessing
    }

    // MARK: - Initialization

    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func requestPermission() {
        AVAudioApplication.requestRecordPermission { _ in }
    }
    
    // MARK: - Recording Control

    func startRecording() {
        HapticManager.shared.medium()
        state = .recording

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
            audioRecorder?.record()

            audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateAudioLevel()
            }
        } catch {
            state = .error(message: "Failed to start recording")
        }
    }

    func stopRecording() {
        HapticManager.shared.medium()

        audioRecorder?.stop()
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        currentAudioLevel = 1.0

        guard let url = recordingURL else { return }
        state = .transcribing

        Task {
            await transcribeAndAnalyze(audioURL: url)
        }
    }
    
    // MARK: - Transcription & Analysis

    private func transcribeAndAnalyze(audioURL: URL) async {
        do {
            // Transcribe audio
            let audioData = try Data(contentsOf: audioURL)
            let base64Audio = audioData.base64EncodedString()

            let requestBody: [String: Any] = [
                "audio": base64Audio,
                "format": "m4a",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            let response: TranscriptionResponse = try await SupabaseManager.client.functions.invoke(
                "transcribe",
                options: FunctionInvokeOptions(body: jsonData)
            )

            let transcription = response.text

            DispatchQueue.main.async {
                self.state = .calculatingNutrition(transcription: transcription)
                HapticManager.shared.success()
            }

            // Cleanup audio file
            try? FileManager.default.removeItem(at: audioURL)

            // Calculate nutrition with realtime streaming
            await calculateNutrition(for: transcription)

        } catch {
            DispatchQueue.main.async {
                self.state = .error(message: "Transcription failed")
                HapticManager.shared.error()
            }
        }
    }
    
    // MARK: - Audio Level Monitoring

    private func updateAudioLevel() {
        guard let recorder = audioRecorder else { return }

        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        let normalized = max(0.0, (averagePower + 60) / 60)
        let scale = 0.85 + (CGFloat(normalized) * 0.5)

        DispatchQueue.main.async {
            self.currentAudioLevel = scale
        }
    }

    // MARK: - Nutrition Calculation

    private func calculateNutrition(for transcription: String) async {
        let text = transcription.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate transcription
        guard validateTranscription(text) else { return }

        // Create realtime channel
        let channelId = "nutrition-\(UUID().uuidString)"
        await setupRealtimeChannel(channelId: channelId, transcription: text)

        // Call edge function to start nutrition calculation
        await invokeNutritionCalculation(channelId: channelId, transcription: text)
    }

    private func validateTranscription(_ text: String) -> Bool {
        guard !text.isEmpty, text.count >= 5 else {
            DispatchQueue.main.async {
                self.state = .error(message: "Transcription too short")
            }
            return false
        }

        let invalidPhrases = ["you", "um", "uh", "hmm", "ah", "okay", "ok", "test"]
        if invalidPhrases.contains(text.lowercased()) {
            DispatchQueue.main.async {
                self.state = .error(message: "Invalid transcription")
            }
            return false
        }

        guard text.split(separator: " ").count >= 2 else {
            DispatchQueue.main.async {
                self.state = .error(message: "Needs more words")
            }
            return false
        }

        return true
    }

    // MARK: - Realtime Channel Setup

    private func setupRealtimeChannel(channelId: String, transcription: String) async {
        let channel = SupabaseManager.client.channel(channelId)

        let deltaStream = channel.broadcastStream(event: "nutrition_delta")
        let completeStream = channel.broadcastStream(event: "nutrition_complete")

        // Subscribe to channel
        do {
            try await channel.subscribeWithError()
        } catch {
            DispatchQueue.main.async {
                self.state = .error(message: "Failed to connect")
                HapticManager.shared.error()
            }
            return
        }

        // Track when streaming starts for haptic feedback
        var hasStartedStreaming = false

        // Listen for streaming deltas
        realtimeChannel = Task {
            for await message in deltaStream {
                if let payload = message["payload"]?.objectValue,
                   let fullText = payload["fullText"]?.stringValue {
                    DispatchQueue.main.async {
                        // Trigger haptic on first stream delta
                        if !hasStartedStreaming {
                            hasStartedStreaming = true
                            HapticManager.shared.light()
                        }

                        self.state = .streamingNutrition(
                            transcription: transcription,
                            partialInfo: fullText
                        )
                    }
                }
            }
        }

        // Listen for completion
        Task {
            for await message in completeStream {
                if let payload = message["payload"]?.objectValue,
                   let fullText = payload["fullText"]?.stringValue {
                    DispatchQueue.main.async {
                        self.state = .completed(nutritionInfo: fullText)
                        HapticManager.shared.success()
                    }

                    // Cleanup
                    await channel.unsubscribe()
                    self.realtimeChannel?.cancel()
                    self.realtimeChannel = nil
                }
            }
        }
    }

    private func invokeNutritionCalculation(channelId: String, transcription: String) async {
        do {
            let requestBody: [String: Any] = [
                "transcribed_meal": transcription,
                "channel_id": channelId
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

            struct EdgeResponse: Codable {
                let success: Bool
                let message: String?
            }

            let _: EdgeResponse = try await SupabaseManager.client.functions.invoke(
                "calculate-calories",
                options: FunctionInvokeOptions(body: jsonData)
            )
        } catch {
            DispatchQueue.main.async {
                self.state = .error(message: "Calculation failed")
                HapticManager.shared.error()
            }
        }
    }
}

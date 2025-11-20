import SwiftUI
import AVFoundation
import Combine
import Supabase

// MARK: - Transcription Response
struct TranscriptionResponse: Codable {
    let text: String
}

// MARK: - Audio Recorder
class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var transcriptionText: String = ""
    @Published var currentAudioLevel: CGFloat = 1.0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordingURL: URL?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Permission Request
    func requestPermission() {
        AVAudioApplication.requestRecordPermission { granted in
            if granted {
                print("✅ Microphone access granted")
            } else {
                print("❌ Microphone access denied")
            }
        }
    }
    
    // MARK: - Start Recording
    func startRecording() {
        HapticManager.shared.medium()
        
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
            
            isRecording = true
            
            // Monitor audio levels
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateAudioLevel()
            }
            
            print("🎙️ Recording started")
        } catch {
            print("❌ Failed to start recording: \(error)")
        }
    }
    
    // MARK: - Stop Recording
    func stopRecording() {
        HapticManager.shared.medium()
        
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        
        isRecording = false
        currentAudioLevel = 1.0
        
        if let url = recordingURL {
            print("💾 Recording stopped, transcribing...")
            isTranscribing = true
            Task {
                await uploadAudioToSupabase(url)
            }
        }
    }
    
    // MARK: - Upload Audio to Supabase
    private func uploadAudioToSupabase(_ fileURL: URL) async {
        do {
            let audioData = try Data(contentsOf: fileURL)
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
            
            DispatchQueue.main.async {
                self.isTranscribing = false
                self.transcriptionText = response.text
                HapticManager.shared.success()
            }
            
            print("✅ Transcription: \(response.text)")
            try? FileManager.default.removeItem(at: fileURL)
            
        } catch let error as FunctionsError {
            print("❌ Functions Error: \(error)")
            if case .httpError(let code, let data) = error {
                print("HTTP Code: \(code)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error body: \(errorString)")
                }
            }
            DispatchQueue.main.async {
                self.isTranscribing = false
                self.transcriptionText = "Failed to transcribe"
                HapticManager.shared.error()
            }
        } catch {
            print("❌ Failed to upload audio: \(error)")
            DispatchQueue.main.async {
                self.isTranscribing = false
                self.transcriptionText = "Failed to transcribe"
                HapticManager.shared.error()
            }
        }
    }
    
    // MARK: - Update Audio Level
    private func updateAudioLevel() {
        guard let recorder = audioRecorder else { return }
        
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        
        // Normalize to 0.85-1.35 range for more obvious pulsing
        let normalized = max(0.0, (averagePower + 60) / 60)
        let scale = 0.85 + (CGFloat(normalized) * 0.5)
        
        DispatchQueue.main.async {
            self.currentAudioLevel = scale
        }
    }
}

import SwiftUI
import AVFoundation
import Combine
import Supabase

struct TranscriptionResponse: Codable {
    let text: String
}

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
        case .idle, .completed, .error:
            return false
        case .recording, .transcribing, .calculatingNutrition, .streamingNutrition:
            return true
        }
    }
}

class AudioRecorder: NSObject, ObservableObject {
    @Published var state: ProcessingState = .idle
    @Published var currentAudioLevel: CGFloat = 1.0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordingURL: URL?
    private var channelTask: Task<Void, Never>?

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
        case .streamingNutrition(let transcription, let partialInfo):
            return partialInfo.isEmpty ? "Calculating:\n\(transcription)" : partialInfo
        case .completed(let nutritionInfo):
            return nutritionInfo
        case .error(let message):
            return "Error: \(message)"
        }
    }

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

    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }

    func requestPermission() {
        AVAudioApplication.requestRecordPermission { granted in
            if granted {
                print("✅ Microphone access granted")
            } else {
                print("❌ Microphone access denied")
            }
        }
    }

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
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateAudioLevel()
            }
            
            print("🎙️ Recording started")
        } catch {
            print("❌ Failed to start recording: \(error)")
            state = .error(message: "Failed to start recording")
        }
    }

    func stopRecording() {
        HapticManager.shared.medium()
        
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        currentAudioLevel = 1.0
        
        if let url = recordingURL {
            print("💾 Recording stopped, transcribing...")
            state = .transcribing
            Task {
                await uploadAudioToSupabase(url)
            }
        }
    }

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
            
            let transcription = response.text
            
            DispatchQueue.main.async {
                self.state = .calculatingNutrition(transcription: transcription)
                HapticManager.shared.success()
            }
            
            print("✅ Transcription: \(transcription)")
            try? FileManager.default.removeItem(at: fileURL)

            await calculateNutritionWithRealtime(transcription: transcription)
            
        } catch let error as FunctionsError {
            print("❌ Functions Error: \(error)")
            if case .httpError(let code, let data) = error {
                print("HTTP Code: \(code)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error body: \(errorString)")
                }
            }
            DispatchQueue.main.async {
                self.state = .error(message: "Failed to transcribe")
                HapticManager.shared.error()
            }
        } catch {
            print("❌ Failed to upload audio: \(error)")
            DispatchQueue.main.async {
                self.state = .error(message: "Failed to transcribe")
                HapticManager.shared.error()
            }
        }
    }

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

    private func calculateNutritionWithRealtime(transcription: String) async {
        let trimmedText = transcription.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty, trimmedText.count >= 5 else {
            print("⚠️ Transcription too short")
            DispatchQueue.main.async {
                self.state = .error(message: "Transcription too short")
            }
            return
        }
        
        let invalidPhrases = ["you", "um", "uh", "hmm", "ah", "okay", "ok", "test"]
        if invalidPhrases.contains(trimmedText.lowercased()) {
            print("⚠️ Invalid transcription")
            DispatchQueue.main.async {
                self.state = .error(message: "Invalid transcription")
            }
            return
        }
        
        guard trimmedText.split(separator: " ").count >= 2 else {
            print("⚠️ Needs more words")
            DispatchQueue.main.async {
                self.state = .error(message: "Transcription needs more words")
            }
            return
        }

        let channelId = "nutrition-\(UUID().uuidString)"
        print("📡 Created channel: \(channelId)")

        let channel = SupabaseManager.client.channel(channelId)
        let deltaStream = channel.broadcastStream(event: "nutrition_delta")
        let completeStream = channel.broadcastStream(event: "nutrition_complete")

        do {
            try await channel.subscribeWithError()
            print("✅ Subscribed to channel: \(channelId)")
        } catch {
            print("❌ Failed to subscribe: \(error)")
            DispatchQueue.main.async {
                self.state = .error(message: "Failed to subscribe to updates")
            }
            return
        }

        channelTask = Task {
            for await message in deltaStream {
                if let payload = message["payload"]?.objectValue,
                   let fullText = payload["fullText"]?.stringValue {
                    DispatchQueue.main.async {
                        self.state = .streamingNutrition(
                            transcription: trimmedText,
                            partialInfo: fullText
                        )
                    }
                }
            }
        }

        Task {
            for await message in completeStream {
                if let payload = message["payload"]?.objectValue,
                   let fullText = payload["fullText"]?.stringValue {
                    DispatchQueue.main.async {
                        self.state = .completed(nutritionInfo: fullText)
                        HapticManager.shared.success()
                    }
                    print("✅ Nutrition complete!")

                    await channel.unsubscribe()
                    self.channelTask?.cancel()
                    self.channelTask = nil
                }
            }
        }

        do {
            print("🧮 Calling edge function...")
            
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
            
            print("✅ Edge function started")
            
        } catch {
            print("❌ Edge function error: \(error)")
            DispatchQueue.main.async {
                self.state = .error(message: "Failed to calculate nutrition")
                HapticManager.shared.error()
            }
            await channel.unsubscribe()
            channelTask?.cancel()
        }
    }
}

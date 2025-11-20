import SwiftUI
import AVFoundation
import Combine
import Supabase

// MARK: - Transcription Response
struct TranscriptionResponse: Codable {
    let text: String
}

// MARK: - Nutrition Info Response
struct NutritionResponse: Codable {
    let nutritionInfo: String
}

// MARK: - Processing State
enum ProcessingState {
    case idle
    case recording
    case transcribing
    case calculatingNutrition(transcription: String)
    case completed(nutritionInfo: String)
    case error(message: String)
    
    var isProcessing: Bool {
        switch self {
        case .idle, .completed, .error:
            return false
        case .recording, .transcribing, .calculatingNutrition:
            return true
        }
    }
}

// MARK: - Audio Recorder
class AudioRecorder: NSObject, ObservableObject {
    @Published var state: ProcessingState = .idle
    @Published var currentAudioLevel: CGFloat = 1.0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordingURL: URL?
    
    // Computed property for display text
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
        case .completed(let nutritionInfo):
            return nutritionInfo
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    // Helper computed properties for convenience
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
        
        // Reset state
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
            
            // Monitor audio levels
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateAudioLevel()
            }
            
            print("🎙️ Recording started")
        } catch {
            print("❌ Failed to start recording: \(error)")
            state = .error(message: "Failed to start recording")
        }
    }
    
    // MARK: - Stop Recording
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
            
            let transcription = response.text
            
            DispatchQueue.main.async {
                self.state = .calculatingNutrition(transcription: transcription)
                HapticManager.shared.success()
            }
            
            print("✅ Transcription: \(transcription)")
            try? FileManager.default.removeItem(at: fileURL)
            
            // Calculate nutrition info after successful transcription
            await calculateNutritionInfo(transcription: transcription)
            
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
    
    // MARK: - Calculate Nutrition Info
    private func calculateNutritionInfo(transcription: String) async {
        let trimmedText = transcription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if text is empty or too short (less than 5 characters)
        guard !trimmedText.isEmpty, trimmedText.count >= 5 else {
            print("⚠️ Transcription too short to process: '\(trimmedText)'")
            DispatchQueue.main.async {
                self.state = .error(message: "Transcription too short")
            }
            return
        }
        
        // Filter out common false positives
        let invalidPhrases = ["you", "um", "uh", "hmm", "ah", "okay", "ok", "test"]
        let lowercasedText = trimmedText.lowercased()
        
        if invalidPhrases.contains(lowercasedText) {
            print("⚠️ Transcription appears to be invalid: '\(trimmedText)'")
            DispatchQueue.main.async {
                self.state = .error(message: "Invalid transcription")
            }
            return
        }
        
        // Check if text has at least 2 words (split by spaces)
        let wordCount = trimmedText.split(separator: " ").count
        guard wordCount >= 2 else {
            print("⚠️ Transcription needs at least 2 words: '\(trimmedText)'")
            DispatchQueue.main.async {
                self.state = .error(message: "Transcription needs more words")
            }
            return
        }
        
        do {
            print("🧮 Started calculating nutrition info for: '\(trimmedText)'")
            let requestBody: [String: Any] = [
                "transcribed_meal": transcription
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            
            // Get string response from the edge function
            let response: NutritionResponse = try await SupabaseManager.client.functions.invoke(
                "calculate-calories",
                options: FunctionInvokeOptions(body: jsonData)
            )
            
            DispatchQueue.main.async {
                self.state = .completed(nutritionInfo: response.nutritionInfo)
                HapticManager.shared.success()
            }
            
            print("✅ Nutrition info calculated successfully")
            print("📊 Full response: \(response.nutritionInfo)")
            print("📊 For meal: '\(trimmedText)'")
            
        } catch let error as FunctionsError {
            print("❌ Calculate-Calories Functions Error: \(error)")
            if case .httpError(let code, let data) = error {
                print("❌ HTTP Status Code: \(code)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error Response Body: \(errorString)")
                }
            }
            DispatchQueue.main.async {
                self.state = .error(message: "Failed to calculate nutrition")
                HapticManager.shared.error()
            }
        } catch {
            print("❌ Failed to calculate nutrition info: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
            DispatchQueue.main.async {
                self.state = .error(message: error.localizedDescription)
                HapticManager.shared.error()
            }
        }
    }
}

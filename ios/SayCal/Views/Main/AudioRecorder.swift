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
    @Published var audioLevels: [CGFloat] = Array(repeating: 0.3, count: 30)
    
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
            // Configure for recording with speaker output
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
    
    // MARK: - Toggle Recording
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // MARK: - Start Recording
    func startRecording() {
        // Create temporary file for recording
        let tempDir = FileManager.default.temporaryDirectory
        recordingURL = tempDir.appendingPathComponent(UUID().uuidString + ".m4a")
        
        // Audio settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            // Initialize and start recorder
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            
            // Start monitoring audio levels for visualizer
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateAudioLevels()
            }
            
            print("🎙️ Recording started at: \(recordingURL!)")
        } catch {
            print("❌ Failed to start recording: \(error)")
        }
    }
    
    // MARK: - Stop Recording
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        
        isRecording = false
        
        // Reset audio levels to default
        DispatchQueue.main.async {
            self.audioLevels = Array(repeating: 0.3, count: 30)
        }
        
        if let url = recordingURL {
            print("💾 Recording stopped, preparing to upload")
            Task {
                await uploadAudioToSupabase(url)
            }
        }
    }
    
    // MARK: - Upload Audio to Supabase
    private func uploadAudioToSupabase(_ fileURL: URL) async {
        do {
            // Read audio file data
            let audioData = try Data(contentsOf: fileURL)
            
            // Convert to base64 for JSON transmission
            let base64Audio = audioData.base64EncodedString()
            
            // Prepare request body
            let requestBody: [String: Any] = [
                "audio": base64Audio,
                "format": "m4a",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            
            // Call Supabase edge function with typed response
            let response: TranscriptionResponse = try await SupabaseManager.client.functions.invoke(
                "transcribe",
                options: FunctionInvokeOptions(body: jsonData)
            )
            
            print("✅ Audio uploaded successfully")
            print("📝 Transcription: \(response.text)")
            
            // Clean up temporary file
            try? FileManager.default.removeItem(at: fileURL)
            
        } catch {
            print("❌ Failed to upload audio: \(error)")
        }
    }
    
    // MARK: - Update Audio Levels
    private func updateAudioLevels() {
        guard let recorder = audioRecorder else { return }
        
        recorder.updateMeters()
        
        // Get current audio power in decibels (-160 dB to 0 dB)
        let averagePower = recorder.averagePower(forChannel: 0)
        
        // Normalize to 0.0-1.0 range
        let normalized = max(0.0, (averagePower + 60) / 60) // Adjusted range for better visualization
        
        // Update visualizer bars with variation for dynamic effect
        DispatchQueue.main.async {
            for i in 0..<self.audioLevels.count {
                let variation = CGFloat.random(in: -0.15...0.15)
                self.audioLevels[i] = max(0.2, min(1.0, CGFloat(normalized) + variation))
            }
        }
    }
}

// MARK: - Recording Expanded View
struct RecordingExpandedView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        HStack(spacing: 16) {
            // Audio visualizer bars
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<30, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 3, height: audioRecorder.audioLevels[index] * 40)
                        .animation(.easeInOut(duration: 0.1), value: audioRecorder.audioLevels[index])
                }
            }
            .frame(height: 50)
            
            // Prompt text
            Text("What did you eat?")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            // Stop button
            Button(action: {
                audioRecorder.toggleRecording()
            }) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            // Liquid glass container
            RoundedRectangle(cornerRadius: 28)
                .fill(.blue.gradient)
                .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
        )
        .padding(.trailing, 20)
        .padding(.bottom, 8)
    }
}

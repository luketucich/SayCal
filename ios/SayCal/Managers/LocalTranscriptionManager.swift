import Foundation
import Combine
import AVFoundation
import WhisperKit

// MARK: - Local Transcription Manager

@MainActor
class LocalTranscriptionManager: ObservableObject {
    static let shared = LocalTranscriptionManager()

    private var whisperKit: WhisperKit?
    @Published var isModelLoaded = false
    @Published var downloadProgress: Double = 0

    private init() {
        Task {
            await loadModel()
        }
    }

    // MARK: - Model Loading

    func loadModel() async {
        do {
            // Use tiny.en for faster performance, or base.en for better accuracy
            // Models: tiny.en (~75MB), base.en (~150MB), small.en (~500MB)
            whisperKit = try await WhisperKit(
                model: "tiny.en",
                downloadBase: nil,
                verbose: true,
                logLevel: .info,
                prewarm: true,
                load: true,
                download: true
            )

            isModelLoaded = true
            print("✅ WhisperKit model loaded successfully")

        } catch {
            print("❌ Failed to load WhisperKit model: \(error)")
            isModelLoaded = false
        }
    }

    // MARK: - Transcription

    func transcribe(audioFileURL: URL) async throws -> String {
        guard let whisperKit = whisperKit else {
            throw TranscriptionError.modelNotLoaded
        }

        print("🎤 Starting local transcription...")

        // Transcribe the audio file
        let results = try await whisperKit.transcribe(
            audioPath: audioFileURL.path,
            decodeOptions: DecodingOptions(
                temperature: 0.0,
                temperatureIncrementOnFallback: 0.2,
                temperatureFallbackCount: 5,
                skipSpecialTokens: true,
                withoutTimestamps: true
            )
        )

        // Extract text from segments
        let transcription = results.first?.text ?? ""

        guard !transcription.isEmpty else {
            throw TranscriptionError.noSpeechDetected
        }

        print("✅ Local transcription complete: \(transcription)")
        return transcription
    }

    // MARK: - Model Management

    func getAvailableModels() async -> [String] {
        do {
            return try await WhisperKit.fetchAvailableModels()
        } catch {
            print("❌ Failed to fetch available models: \(error)")
            return []
        }
    }

    func switchModel(to modelName: String) async {
        do {
            whisperKit = try await WhisperKit(model: modelName)
            isModelLoaded = true
            print("✅ Switched to model: \(modelName)")
        } catch {
            print("❌ Failed to switch model: \(error)")
        }
    }
}

// MARK: - Errors

enum TranscriptionError: LocalizedError {
    case modelNotLoaded
    case noSpeechDetected
    case transcriptionFailed

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Whisper model not loaded. Please wait for initialization."
        case .noSpeechDetected:
            return "No speech detected in the audio."
        case .transcriptionFailed:
            return "Transcription failed. Please try again."
        }
    }
}

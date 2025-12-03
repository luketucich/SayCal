import Foundation
import FoundationModels

/// AI Helper functions using Apple's Foundation Models
struct AIHelpers {

    /// Generates a concise meal title from a transcription using Apple's on-device language model
    /// - Parameter transcription: The raw meal transcription text
    /// - Returns: A short, concise meal title (5-8 words max), or nil if generation fails or model is unavailable
    /// - Note: This title is permanent and will not be replaced by the API's description
    @available(iOS 26.0, *)
    static func generateMealTitle(from transcription: String) async -> String? {
        guard SystemLanguageModel.default.isAvailable else {
            return nil
        }

        let instructions = """
        You are a meal logging assistant. The user has described what they ate.
        Create a short meal title (5-8 words max) using ONLY the foods they explicitly mentioned.

        CRITICAL RULES:
        - ONLY list foods the user actually said
        - DO NOT add foods they didn't mention
        - DO NOT infer or assume anything
        - DO NOT be creative or elaborate
        - Be literal and accurate

        Examples:
        Input: "one egg"
        Output: "Egg"

        Input: "chicken and rice"
        Output: "Chicken and Rice"

        Input: "two slices of pizza from dominos"
        Output: "Pizza, Domino's"

        Only respond with the meal title, nothing else. Use title case.
        """

        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: transcription)
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("❌ Failed to generate meal title: \(error)")
            return nil
        }
    }
}

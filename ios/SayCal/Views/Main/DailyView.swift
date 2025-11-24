import SwiftUI

struct DailyView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var remainingCalories = 1847
    @State private var selectedInputMethod: InputMethod?
    @State private var textInput = ""
    @State private var showResultSheet = false
    @State private var transcription: String?
    @State private var nutritionInfo = ""
    @State private var isCalculating = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Calorie Pie Chart
                        CaloriesPieChart(remainingCalories: remainingCalories)
                            .frame(width: 220, height: 220)
                            .environmentObject(userManager)

                        // Macro Breakdown
                        MacroBreakdownView(remainingCalories: remainingCalories)
                            .environmentObject(userManager)

                        Spacer()
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 100) // Space for input button
                }
                .navigationTitle("Daily")
                .navigationBarTitleDisplayMode(.large)

                // Input overlays
                VStack(spacing: 0) {
                    Spacer()

                    if selectedInputMethod == .voice {
                        AudioRecordingOverlay(
                            audioRecorder: audioRecorder,
                            isPresented: Binding(
                                get: { selectedInputMethod == .voice },
                                set: { if !$0 { selectedInputMethod = nil } }
                            ),
                            onSend: {
                                handleVoiceSend()
                            }
                        )
                    } else if selectedInputMethod == .text {
                        TextInputOverlay(
                            text: $textInput,
                            isPresented: Binding(
                                get: { selectedInputMethod == .text },
                                set: { if !$0 { selectedInputMethod = nil } }
                            ),
                            onSend: {
                                handleTextSend()
                            }
                        )
                    } else {
                        // Plus button
                        PlusButton(selectedMethod: $selectedInputMethod)
                            .padding(.bottom, 32)
                    }
                }
            }
        }
        .sheet(isPresented: $showResultSheet) {
            CalorieResultSheet(
                transcription: transcription,
                nutritionInfo: nutritionInfo,
                isLoading: isCalculating
            )
        }
        .onChange(of: audioRecorder.state) { _, newState in
            handleAudioRecorderStateChange(newState)
        }
    }

    private func handleVoiceSend() {
        // Show result sheet with loading state
        isCalculating = true
        showResultSheet = true

        // Wait for transcription and nutrition info
        // This will be handled by the audioRecorder state changes
    }

    private func handleTextSend() {
        guard !textInput.isEmpty else { return }

        // Show result sheet with loading state
        transcription = nil
        isCalculating = true
        showResultSheet = true

        // Send text to calorie calculation endpoint
        Task {
            do {
                // TODO: Replace with actual API call
                try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate API call

                nutritionInfo = """
                **Meal Summary**

                **Total Calories:** 450 kcal

                **Macronutrients:**
                • Protein: 35g
                • Carbohydrates: 45g
                • Fat: 12g

                **Input:** \(textInput)
                """

                isCalculating = false
                textInput = ""
                selectedInputMethod = nil
            } catch {
                print("Error calculating nutrition: \(error)")
                isCalculating = false
            }
        }
    }

    private func handleAudioRecorderStateChange(_ state: AudioRecorderState) {
        switch state {
        case .transcribing:
            // Show loading in sheet
            isCalculating = true

        case .calculatingNutrition(let text):
            // Update transcription
            transcription = text
            isCalculating = true

        case .streamingNutrition(let text, let partialInfo):
            // Update transcription and partial nutrition info
            transcription = text
            nutritionInfo = partialInfo
            isCalculating = false

        case .completed(let info):
            // Final nutrition info
            nutritionInfo = info
            isCalculating = false
            selectedInputMethod = nil

        case .error(let message):
            // Handle error
            nutritionInfo = "Error: \(message)"
            isCalculating = false

        default:
            break
        }
    }
}

#Preview {
    DailyView()
        .environmentObject(UserManager.shared)
}

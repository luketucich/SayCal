import SwiftUI
import Supabase

enum AppTab: Hashable {
    case daily
    case recipes
    case add
}

struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var audioRecorder = AudioRecorder()

    @State private var showSettings = false
    @State private var showInputMenu = false
    @State private var isMenuClosing = false
    @State private var selectedTab: AppTab = .daily
    @State private var previousTab: AppTab = .daily

    @State private var showRecordingOverlay = false
    @State private var showTextInput = false
    @State private var showResultSheet = false

    @State private var transcriptionText: String?
    @State private var nutritionInfo: String = ""
    @State private var textInput: String = ""
    @State private var isCalculatingFromText = false

    @FocusState private var isTextInputFocused: Bool

    // Custom binding to intercept .add selection without flickering
    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == .add {
                    HapticManager.shared.medium()
                    toggleMenu()
                } else {
                    if newValue != selectedTab {
                        previousTab = selectedTab
                        selectedTab = newValue
                        if showInputMenu { closeMenu() }
                    }
                }
            }
        )
    }

    private var isLoadingNutrition: Bool {
        if isCalculatingFromText {
            return nutritionInfo.isEmpty
        }
        switch audioRecorder.state {
        case .calculatingNutrition, .streamingNutrition:
            return nutritionInfo.isEmpty
        default:
            return false
        }
    }

    var body: some View {
        ZStack {
            TabView(selection: tabSelection) {
                Tab(value: .daily) {
                    DailyView(showSettings: $showSettings)
                } label: {
                    Image(systemName: selectedTab == .daily ? "house.fill" : "house")
                }

                Tab(value: .recipes) {
                    RecipesView(showSettings: $showSettings)
                } label: {
                    Image(systemName: selectedTab == .recipes ? "book.closed.fill" : "book.closed")
                }

                Tab(value: .add, role: .search) {
                    Color.clear
                } label: {
                    Image(systemName: "plus")
                }
            }
            .tabViewStyle(.tabBarOnly)

            // Floating menu
            if showInputMenu || isMenuClosing {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 12) {
                            MenuOption(
                                icon: "mic.fill",
                                label: "Voice",
                                appearDelay: 0.06,
                                disappearDelay: 0.06,
                                isClosing: isMenuClosing
                            ) {
                                HapticManager.shared.light()
                                closeMenu()
                                startVoiceRecording()
                            }

                            MenuOption(
                                icon: "keyboard",
                                label: "Type",
                                appearDelay: 0,
                                disappearDelay: 0,
                                isClosing: isMenuClosing
                            ) {
                                HapticManager.shared.light()
                                closeMenu()
                                startTextInput()
                            }
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 70)
                }
            }

            // Audio recording overlay
            if showRecordingOverlay {
                AudioRecordingOverlay(
                    audioRecorder: audioRecorder,
                    isPresented: $showRecordingOverlay,
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showRecordingOverlay = false
                        }
                    }
                )
            }
        }

        // *** UPDATED SECTION — input bar removed ***
        .safeAreaInset(edge: .bottom) {
            if showTextInput {
                TextField("What did you eat?", text: $textInput, axis: .vertical)
                    .focused($isTextInputFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        if !textInput.isEmpty { handleTextInputSend() }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            TextField("Enter your meal", text: $textInput)
                            
                            Spacer()

                            Button("Cancel") {
                                HapticManager.shared.light()
                                handleTextInputCancel()
                            }
                            .foregroundStyle(.secondary)

                            Button {
                                HapticManager.shared.medium()
                                handleTextInputSend()
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(.systemBackground))
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(textInput.isEmpty ? Color.secondary : Color.primary)
                                    )
                            }
                            .disabled(textInput.isEmpty)
                        }
                    }
                    // Make invisible & non-intrusive
                    .opacity(0.01)
                    .frame(height: 0)
            }
        }

        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .environmentObject(userManager)
        }

        .sheet(isPresented: $showResultSheet) {
            CalorieResultSheet(
                transcription: transcriptionText,
                nutritionInfo: nutritionInfo,
                isLoading: isLoadingNutrition
            )
        }

        .onChange(of: showSettings) { _, isShowing in
            if isShowing && showInputMenu {
                closeMenu()
            }
        }

        .onChange(of: audioRecorder.state) { _, newState in
            handleAudioRecorderStateChange(newState)
        }
    }

    // MARK: - Menu Controls
    private func toggleMenu() {
        if showInputMenu {
            closeMenu()
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showInputMenu = true
            }
        }
    }

    private func closeMenu() {
        guard !isMenuClosing else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isMenuClosing = true
            showInputMenu = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isMenuClosing = false
        }
    }

    private func startVoiceRecording() {
        transcriptionText = nil
        nutritionInfo = ""
        audioRecorder.requestPermission()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showRecordingOverlay = true
            }
        }
    }

    private func startTextInput() {
        transcriptionText = nil
        nutritionInfo = ""
        textInput = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showTextInput = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextInputFocused = true
            }
        }
    }

    private func handleTextInputCancel() {
        isTextInputFocused = false
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showTextInput = false
        }
        textInput = ""
    }

    private func handleTextInputSend() {
        guard !textInput.isEmpty else { return }
        isTextInputFocused = false
        let mealText = textInput
        textInput = ""

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showTextInput = false
        }

        transcriptionText = mealText
        nutritionInfo = ""
        isCalculatingFromText = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showResultSheet = true
        }

        Task {
            await calculateNutritionFromText(mealText)
        }
    }

    private func calculateNutritionFromText(_ mealText: String) async {
        let channelId = "nutrition-\(UUID().uuidString)"
        let channel = SupabaseManager.client.channel(channelId)

        let deltaStream = channel.broadcastStream(event: "nutrition_delta")
        let completeStream = channel.broadcastStream(event: "nutrition_complete")

        do {
            try await channel.subscribeWithError()

            Task {
                for await message in deltaStream {
                    if let payload = message["payload"]?.objectValue,
                       let fullText = payload["fullText"]?.stringValue {
                        DispatchQueue.main.async {
                            nutritionInfo = fullText
                        }
                    }
                }
            }

            Task {
                for await message in completeStream {
                    if let payload = message["payload"]?.objectValue,
                       let fullText = payload["fullText"]?.stringValue {
                        DispatchQueue.main.async {
                            nutritionInfo = fullText
                            isCalculatingFromText = false
                            HapticManager.shared.success()
                        }
                        await channel.unsubscribe()
                    }
                }
            }

            let requestBody: [String: Any] = [
                "transcribed_meal": mealText,
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
            print("❌ Failed to calculate nutrition: \(error)")
            DispatchQueue.main.async {
                isCalculatingFromText = false
                HapticManager.shared.error()
            }
            await channel.unsubscribe()
        }
    }

    private func handleAudioRecorderStateChange(_ state: ProcessingState) {
        switch state {
        case .calculatingNutrition(let transcription):
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showRecordingOverlay = false
            }
            transcriptionText = transcription
            nutritionInfo = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showResultSheet = true
            }

        case .streamingNutrition(let transcription, let partialInfo):
            transcriptionText = transcription
            nutritionInfo = partialInfo

        case .completed(let nutritionData):
            nutritionInfo = nutritionData

        case .error(let message):
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showRecordingOverlay = false
            }
            print("Error: \(message)")

        case .idle, .recording, .transcribing:
            break
        }
    }
}

// MARK: - Menu Option Button
struct MenuOption: View {
    let icon: String
    let label: String
    var appearDelay: Double = 0
    var disappearDelay: Double = 0
    var isClosing: Bool = false
    let action: () -> Void

    @State private var appeared = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
            }
        }
        .scaleEffect(appeared ? 1 : 0.5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7).delay(appearDelay)) {
                appeared = true
            }
        }
        .onChange(of: isClosing) { _, closing in
            if closing {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8).delay(disappearDelay)) {
                    appeared = false
                }
            }
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject(UserManager.shared)
}

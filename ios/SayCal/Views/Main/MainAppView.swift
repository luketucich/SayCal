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
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appTheme") private var selectedAppTheme: AppTheme = .device

    @State private var showSettings = false
    @State private var showInputMenu = false
    @State private var isMenuClosing = false
    @State private var selectedTab: AppTab = .daily
    @State private var previousTab: AppTab = .daily
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    @StateObject private var mealLogger = MealManager.shared

    @State private var showRecordingOverlay = false
    @State private var showTextInput = false
    @State private var showResultSheet = false
    @State private var currentMealId: String?
    @State private var selectedMealId: String?
    @State private var textInput: String = ""

    @FocusState private var isTextInputFocused: Bool

    private var isViewingToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

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

    var body: some View {
        ZStack {
            TabView(selection: tabSelection) {
                Tab(value: .daily) {
                    DailyView(
                        showSettings: $showSettings,
                        selectedDate: $selectedDate,
                        onMealTap: { meal in
                            selectedMealId = meal.id
                            showResultSheet = true
                        }
                    )
                } label: {
                    Image(systemName: selectedTab == .daily ? "house.fill" : "house")
                }

                Tab(value: .recipes) {
                    RecipesView(showSettings: $showSettings)
                } label: {
                    Image(systemName: selectedTab == .recipes ? "book.closed.fill" : "book.closed")
                }

                if isViewingToday {
                    Tab(value: .add, role: .search) {
                        Color.clear
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .tabViewStyle(.tabBarOnly)

            // Floating menu with backdrop
            if showInputMenu || isMenuClosing {
                ZStack {
                    RadialGradient(
                        colors: [
                            (colorScheme == .dark ? Color.black : Color.white).opacity(0.8),
                            (colorScheme == .dark ? Color.black : Color.white).opacity(0.6),
                            (colorScheme == .dark ? Color.black : Color.white).opacity(0.3)
                        ],
                        center: .bottomTrailing,
                        startRadius: 50,
                        endRadius: 500
                    )
                    .blur(radius: showInputMenu && !isMenuClosing ? 20 : 0)
                    .opacity(showInputMenu && !isMenuClosing ? 1 : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.25), value: showInputMenu)
                    .animation(.easeInOut(duration: 0.25), value: isMenuClosing)
                    .onTapGesture {
                        closeMenu()
                    }

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
                    },
                    onSend: {
                        // Create loading meal immediately
                        let mealId = MealManager.shared.createLoadingMeal(transcription: nil)
                        currentMealId = mealId

                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showRecordingOverlay = false
                        }
                    }
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if showTextInput {
                TextField("", text: $textInput, axis: .vertical)
                    .focused($isTextInputFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        if !textInput.isEmpty { handleTextInputSend() }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            HStack(spacing: 12) {
                                TextField("What did you eat?", text: $textInput, axis: .vertical)
                                    .lineLimit(1...4)
                                    .submitLabel(.return)
                                    .onSubmit {
                                        if !textInput.isEmpty { handleTextInputSend() }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                                    )

                                Button {
                                    HapticManager.shared.light()
                                    handleTextInputCancel()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }

                                Button {
                                    HapticManager.shared.medium()
                                    handleTextInputSend()
                                } label: {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(textInput.isEmpty ? Color.secondary : Color.primary)
                                }
                                .disabled(textInput.isEmpty)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
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
                .preferredColorScheme(selectedAppTheme.colorScheme)
                .tint(selectedAppTheme.accentColor)
        }

        .sheet(isPresented: $showResultSheet) {
            if let mealId = selectedMealId {
                CalorieResultSheet(mealId: mealId)
            }
        }
        .onChange(of: showResultSheet) { _, isShowing in
            if !isShowing {
                selectedMealId = nil
            }
        }

        .onChange(of: showSettings) { _, isShowing in
            if isShowing && showInputMenu {
                closeMenu()
            }
        }

        .onChange(of: audioRecorder.state) { _, newState in
            handleAudioRecorderStateChange(newState)
        }
        .preferredColorScheme(selectedAppTheme.colorScheme)
        .tint(selectedAppTheme.accentColor)
    }

    // MARK: - Menu

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

    // MARK: - Voice Recording

    private func startVoiceRecording() {
        audioRecorder.requestPermission()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showRecordingOverlay = true
            }
        }
    }

    private func handleAudioRecorderStateChange(_ state: ProcessingState) {
        guard let mealId = currentMealId else { return }

        switch state {
        case .analyzing(let transcription):
            MealManager.shared.updateMealTranscription(id: mealId, transcription: transcription)

        case .completed(_, let response):
            MealManager.shared.updateMeal(id: mealId, nutritionResponse: response)
            currentMealId = nil

        case .error:
            if let meal = MealManager.shared.loggedMeals.first(where: { $0.id == mealId }) {
                MealManager.shared.deleteMeal(meal)
            }
            currentMealId = nil

        case .idle, .recording, .transcribing:
            break
        }
    }

    // MARK: - Text Input

    private func startTextInput() {
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

        let mealText = textInput
        textInput = ""
        isTextInputFocused = false

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showTextInput = false
        }

        let mealId = MealManager.shared.createLoadingMeal(transcription: mealText)
        currentMealId = mealId

        Task {
            await calculateNutrition(for: mealText)
        }
    }

    private func calculateNutrition(for mealText: String) async {
        guard let mealId = currentMealId else { return }

        do {
            let response: NutritionResponse = try await SupabaseManager.client.functions.invoke(
                "calculate-calories",
                options: FunctionInvokeOptions(body: ["transcribed_meal": mealText])
            )

            await MainActor.run {
                MealManager.shared.updateMeal(id: mealId, nutritionResponse: response)
                currentMealId = nil
                HapticManager.shared.success()
            }
        } catch {
            await MainActor.run {
                if let meal = MealManager.shared.loggedMeals.first(where: { $0.id == mealId }) {
                    MealManager.shared.deleteMeal(meal)
                }
                currentMealId = nil
                HapticManager.shared.error()
            }
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

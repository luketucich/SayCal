import SwiftUI
import Supabase

enum AppTab: Hashable {
    case daily
    case micros
    case profile
    case add
}

struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var audioRecorder = AudioRecorder()
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appTheme") private var selectedAppTheme: AppTheme = .device

    @State private var showInputMenu = false
    @State private var isMenuClosing = false
    @State private var selectedTab: AppTab = .daily
    @State private var previousTab: AppTab = .daily
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    @StateObject private var mealLogger = MealManager.shared

    @State private var showRecordingOverlay = false
    @State private var showTextInput = false
    @State private var currentMealId: String?
    @State private var selectedMealId: String?
    @State private var textInput: String = ""

    @FocusState private var isTextInputFocused: Bool
    
    // Constants for consistent spacing
    private let bottomBarHeight: CGFloat = 80
    private let gradientHeight: CGFloat = 200

    private var isViewingToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue != selectedTab {
                    previousTab = selectedTab
                    selectedTab = newValue
                    if showInputMenu { closeMenu() }
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // MARK: - Main Content
                Group {
                    switch selectedTab {
                    case .daily:
                        DailyView(
                            selectedDate: $selectedDate,
                            onMealTap: { meal in
                                selectedMealId = meal.id
                            }
                        )
                    case .micros:
                        MicrosView(selectedDate: $selectedDate)
                    case .profile:
                        ProfileView()
                            .environmentObject(userManager)
                    case .add:
                        Color.clear
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                // MARK: - Floating Menu
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
                        .padding(.bottom, bottomBarHeight + 20)
                    }
                }

                // MARK: - Audio Recording Overlay
                if showRecordingOverlay {
                    AudioRecordingOverlay(
                        audioRecorder: audioRecorder,
                        isPresented: $showRecordingOverlay,
                        onDismiss: {
                            audioRecorder.state = .idle
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showRecordingOverlay = false
                            }
                        },
                        onSend: {
                            // Just stop recording, don't create meal yet
                            // Meal will be created after transcription confirmation
                        },
                        onConfirm: { transcription in
                            handleTranscriptionConfirmed(transcription)
                        },
                        onRetry: {
                            handleTranscriptionRetry()
                        }
                    )
                }

                // MARK: - Bottom Bar
                if showTextInput {
                    MealInputToolbar(
                        textInput: $textInput,
                        isTextInputFocused: $isTextInputFocused,
                        onCancel: handleTextInputCancel,
                        onSend: handleTextInputSend
                    )
                } else {
                    HStack(alignment: .bottom, spacing: 0) {
                        CustomTabBar(selectedTab: tabSelection)
                            .padding(.leading, 20)

                        Spacer()

                        FloatingAddButton(onTap: toggleMenu)
                            .padding(.trailing, 20)
                    }
                    .frame(height: bottomBarHeight)
                }
            }
            .navigationDestination(item: $selectedMealId) { mealId in
                MealSummaryView(mealId: mealId)
            }
            .navigationBarHidden(true)
            .preferredColorScheme(selectedAppTheme.colorScheme)
            .tint(selectedAppTheme.accentColor)
        }
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

    private func handleTranscriptionConfirmed(_ transcription: String) {
        // Close the overlay
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showRecordingOverlay = false
        }

        // Process the meal (will create it only on success)
        Task {
            await processMeal(for: transcription)
        }

        // Reset recorder
        audioRecorder.state = .idle
    }

    private func handleTranscriptionRetry() {
        // Reset audio recorder to start a new recording
        audioRecorder.state = .idle

        // Small delay before starting new recording
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            audioRecorder.startRecording()
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

        Task {
            await processMeal(for: mealText)
        }
    }

    private func processMeal(for mealText: String) async {
        // Create loading placeholder immediately
        let mealId = await MainActor.run {
            MealManager.shared.createLoadingMeal(transcription: mealText)
        }

        // Use background analysis so it continues even if app is closed
        await MealManager.shared.analyzeMealInBackground(mealId: mealId, transcription: mealText)
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
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.appCardBackground, in: Circle())
                    .cardShadow()
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

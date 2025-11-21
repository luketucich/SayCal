import SwiftUI

struct RecordingWindow: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var textOpacity: Double = 0
    @State private var previousTextLength: Int = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header with status indicator
            HStack {
                StatusIndicator(state: audioRecorder.state)
                Spacer()
                CloseButton(audioRecorder: audioRecorder)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .opacity(0.3)

            // Content area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !audioRecorder.displayText.isEmpty {
                            Text(audioRecorder.displayText)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(UIColor.label))
                                .textSelection(.enabled)
                                .opacity(textOpacity)
                                .id("contentText")
                        } else {
                            RecordingPrompt()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
                .onChange(of: audioRecorder.displayText) { _, newValue in
                    withAnimation(.easeIn(duration: 0.2)) {
                        textOpacity = 1.0
                    }

                    // Trigger haptic when new content arrives
                    if newValue.count > previousTextLength {
                        HapticManager.shared.light()
                        previousTextLength = newValue.count

                        // Auto-scroll to bottom
                        withAnimation {
                            proxy.scrollTo("contentText", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 20,
            y: 10
        )
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                textOpacity = 1.0
            }
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(UIColor.systemBackground)
            : Color.white
    }
}

// MARK: - Status Indicator

struct StatusIndicator: View {
    let state: ProcessingState

    var body: some View {
        HStack(spacing: 8) {
            // Animated dot
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .scaleEffect(state.isProcessing ? 1.2 : 1.0)
                .animation(
                    state.isProcessing
                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                    value: state.isProcessing
                )

            Text(statusText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
    }

    private var statusColor: Color {
        switch state {
        case .idle:
            return .gray
        case .recording:
            return .red
        case .transcribing, .calculatingNutrition, .streamingNutrition:
            return .blue
        case .completed:
            return .green
        case .error:
            return .red
        }
    }

    private var statusText: String {
        switch state {
        case .idle:
            return "Ready"
        case .recording:
            return "Recording"
        case .transcribing:
            return "Transcribing"
        case .calculatingNutrition:
            return "Analyzing"
        case .streamingNutrition:
            return "Calculating"
        case .completed:
            return "Complete"
        case .error:
            return "Error"
        }
    }
}

// MARK: - Close Button

struct CloseButton: View {
    @ObservedObject var audioRecorder: AudioRecorder

    var body: some View {
        Button {
            HapticManager.shared.light()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                audioRecorder.state = .idle
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .opacity(canClose ? 1.0 : 0.3)
        .disabled(!canClose)
    }

    private var canClose: Bool {
        switch audioRecorder.state {
        case .completed, .error:
            return true
        default:
            return false
        }
    }
}

// MARK: - Recording Prompt

struct RecordingPrompt: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue.opacity(0.6))
                .padding(.bottom, 8)

            Text("Listening...")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(UIColor.label))

            Text("Speak naturally about what you ate")
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()

        RecordingWindow(audioRecorder: {
            let recorder = AudioRecorder()
            recorder.state = .streamingNutrition(
                transcription: "Half a pint of ice cream",
                partialInfo: "Meal Type: Snack\nDescription: Ice cream (1/2 pint)\n\nTotal Calories: 400\nTotal Protein: 8g"
            )
            return recorder
        }())
    }
}

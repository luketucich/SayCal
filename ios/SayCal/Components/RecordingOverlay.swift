import SwiftUI

struct RecordingOverlay: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            if !audioRecorder.displayText.isEmpty {
                overlayContent
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: audioRecorder.displayText.isEmpty)
    }
    
    private var overlayContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header with status indicator
            HStack(spacing: Theme.Spacing.sm) {
                statusIndicator
                statusText
                Spacer()
            }

            // Content area
            if case .streamingNutrition(_, let partialInfo) = audioRecorder.state, !partialInfo.isEmpty {
                ScrollView {
                    Text(partialInfo)
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
            } else if case .completed(let nutritionInfo) = audioRecorder.state {
                ScrollView {
                    Text(nutritionInfo)
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
            } else if case .calculatingNutrition(let transcription) = audioRecorder.state {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(transcription)
                        .font(Theme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.Colors.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if case .error(let message) = audioRecorder.state {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.Colors.error)

                    Text(message)
                        .font(Theme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.Colors.error)
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                        .stroke(Theme.Colors.separator.opacity(0.5), lineWidth: Theme.BorderWidth.thin)
                )
        )
        .boldShadow()
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.sm)
    }
    
    private var statusIndicator: some View {
        Group {
            switch audioRecorder.state {
            case .recording:
                ZStack {
                    Circle()
                        .fill(Theme.Colors.errorLight)
                        .frame(width: 32, height: 32)

                    Circle()
                        .fill(Theme.Colors.error)
                        .frame(width: 12, height: 12)
                        .opacity(audioRecorder.isRecording ? 1 : 0.5)
                        .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: audioRecorder.isRecording)
                }

            case .transcribing, .calculatingNutrition:
                ZStack {
                    Circle()
                        .fill(Theme.Colors.accentLight)
                        .frame(width: 32, height: 32)

                    ProgressView()
                        .tint(Theme.Colors.accent)
                }

            case .streamingNutrition:
                ZStack {
                    Circle()
                        .fill(Theme.Colors.successLight)
                        .frame(width: 32, height: 32)

                    Image(systemName: "waveform")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.success)
                }

            case .completed:
                ZStack {
                    Circle()
                        .fill(Theme.Colors.successLight)
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.Colors.success)
                }

            case .error:
                ZStack {
                    Circle()
                        .fill(Theme.Colors.errorLight)
                        .frame(width: 32, height: 32)

                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.Colors.error)
                }

            case .idle:
                EmptyView()
            }
        }
    }
    
    private var statusText: some View {
        Group {
            switch audioRecorder.state {
            case .recording:
                Text("Recording...")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.label)

            case .transcribing:
                Text("Transcribing...")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.label)

            case .calculatingNutrition:
                Text("Calculating nutrition...")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.label)

            case .streamingNutrition:
                Text("Analyzing...")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.label)

            case .completed:
                Text("Complete")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.success)

            case .error:
                Text("Error")
                    .font(Theme.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.error)

            case .idle:
                EmptyView()
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        RecordingOverlay(audioRecorder: {
            let recorder = AudioRecorder()
            recorder.state = .streamingNutrition(
                transcription: "2 eggs and toast with avocado",
                partialInfo: "**Nutrition Information**\n\nCalories: 450\nProtein: 18g\nCarbs: 35g\nFat: 25g"
            )
            return recorder
        }())
        
        Spacer()
    }
    .background(Color(UIColor.systemGray6))
}

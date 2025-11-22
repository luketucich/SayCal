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
        .animation(Animation.springSmooth, value: audioRecorder.displayText.isEmpty)
    }

    private var overlayContent: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header with status indicator
            HStack(spacing: Spacing.sm) {
                statusIndicator
                statusText
                Spacer()
            }

            // Content area
            if case .streamingNutrition(_, let partialInfo) = audioRecorder.state, !partialInfo.isEmpty {
                ScrollView {
                    Text(partialInfo)
                        .font(.caption)
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: Dimensions.pickerHeight)
            } else if case .completed(let nutritionInfo) = audioRecorder.state {
                ScrollView {
                    Text(nutritionInfo)
                        .font(.caption)
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: Dimensions.pickerHeight)
            } else if case .calculatingNutrition(let transcription) = audioRecorder.state {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(transcription)
                        .font(.captionMedium)
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if case .error(let message) = audioRecorder.state {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundColor(.error)

                    Text(message)
                        .font(.captionMedium)
                        .foregroundColor(.error)
                }
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .stroke(Color.divider.opacity(Opacity.semitransparent), lineWidth: LineWidth.thin)
                )
                .shadow(color: Shadows.large.color, radius: Shadows.large.radius, x: Shadows.large.x, y: Shadows.large.y)
        )
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }
    
    private var statusIndicator: some View {
        Group {
            switch audioRecorder.state {
            case .recording:
                ZStack {
                    Circle()
                        .fill(Color.recording.opacity(Opacity.medium))
                        .frame(width: Dimensions.iconXLarge, height: Dimensions.iconXLarge)

                    Circle()
                        .fill(Color.recording)
                        .frame(width: Dimensions.iconMedium, height: Dimensions.iconMedium)
                        .opacity(audioRecorder.isRecording ? 1 : Opacity.semitransparent)
                        .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                        .animation(Animation.pulse, value: audioRecorder.isRecording)
                }

            case .transcribing, .calculatingNutrition:
                ZStack {
                    Circle()
                        .fill(Color.processing.opacity(Opacity.medium))
                        .frame(width: Dimensions.iconXLarge, height: Dimensions.iconXLarge)

                    ProgressView()
                        .tint(.processing)
                }

            case .streamingNutrition:
                ZStack {
                    Circle()
                        .fill(Color.completed.opacity(Opacity.medium))
                        .frame(width: Dimensions.iconXLarge, height: Dimensions.iconXLarge)

                    Image(systemName: "waveform")
                        .font(.iconSemibold)
                        .foregroundColor(.completed)
                }

            case .completed:
                ZStack {
                    Circle()
                        .fill(Color.completed.opacity(Opacity.medium))
                        .frame(width: Dimensions.iconXLarge, height: Dimensions.iconXLarge)

                    Image(systemName: "checkmark")
                        .font(.iconBold)
                        .foregroundColor(.completed)
                }

            case .error:
                ZStack {
                    Circle()
                        .fill(Color.error.opacity(Opacity.medium))
                        .frame(width: Dimensions.iconXLarge, height: Dimensions.iconXLarge)

                    Image(systemName: "xmark")
                        .font(.iconBold)
                        .foregroundColor(.error)
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
                    .font(.bodySemibold)
                    .foregroundColor(.textPrimary)

            case .transcribing:
                Text("Transcribing...")
                    .font(.bodySemibold)
                    .foregroundColor(.textPrimary)

            case .calculatingNutrition:
                Text("Calculating nutrition...")
                    .font(.bodySemibold)
                    .foregroundColor(.textPrimary)

            case .streamingNutrition:
                Text("Analyzing...")
                    .font(.bodySemibold)
                    .foregroundColor(.textPrimary)

            case .completed:
                Text("Complete")
                    .font(.bodySemibold)
                    .foregroundColor(.success)

            case .error:
                Text("Error")
                    .font(.bodySemibold)
                    .foregroundColor(.error)

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

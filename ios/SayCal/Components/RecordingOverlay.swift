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
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header with status indicator
            HStack(spacing: AppSpacing.sm) {
                statusIndicator
                statusText
                Spacer()
            }

            // Content area
            if case .streamingNutrition(_, let partialInfo) = audioRecorder.state, !partialInfo.isEmpty {
                ScrollView {
                    Text(partialInfo)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
            } else if case .completed(let nutritionInfo) = audioRecorder.state {
                ScrollView {
                    Text(nutritionInfo)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
            } else if case .calculatingNutrition(let transcription) = audioRecorder.state {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(transcription)
                        .font(AppTypography.captionMedium)
                        .foregroundColor(AppColors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if case .error(let message) = audioRecorder.state {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.error)

                    Text(message)
                        .font(AppTypography.captionMedium)
                        .foregroundColor(AppColors.error)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                        .stroke(Color(UIColor.separator).opacity(0.5), lineWidth: 1)
                )
                .shadow(color: AppShadow.large.color, radius: AppShadow.large.radius, x: AppShadow.large.x, y: AppShadow.large.y)
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
    }
    
    private var statusIndicator: some View {
        Group {
            switch audioRecorder.state {
            case .recording:
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .opacity(audioRecorder.isRecording ? 1 : 0.5)
                        .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: audioRecorder.isRecording)
                }
                
            case .transcribing, .calculatingNutrition:
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    ProgressView()
                        .tint(.blue)
                }
                
            case .streamingNutrition:
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "waveform")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                }
                
            case .completed:
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
                
            case .error:
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
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
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.primaryText)

            case .transcribing:
                Text("Transcribing...")
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.primaryText)

            case .calculatingNutrition:
                Text("Calculating nutrition...")
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.primaryText)

            case .streamingNutrition:
                Text("Analyzing...")
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.primaryText)

            case .completed:
                Text("Complete")
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.success)

            case .error:
                Text("Error")
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.error)

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

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
        VStack(alignment: .leading, spacing: 16) {
            // Header with status indicator
            HStack(spacing: 12) {
                statusIndicator
                statusText
                Spacer()
            }
            
            // Content area
            if case .streamingNutrition(_, let partialInfo) = audioRecorder.state, !partialInfo.isEmpty {
                ScrollView {
                    Text(partialInfo)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
            } else if case .completed(let nutritionInfo) = audioRecorder.state {
                ScrollView {
                    Text(nutritionInfo)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
            } else if case .calculatingNutrition(let transcription) = audioRecorder.state {
                VStack(alignment: .leading, spacing: 8) {
                    Text(transcription)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if case .error(let message) = audioRecorder.state {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                    
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(UIColor.separator).opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                
            case .transcribing:
                Text("Transcribing...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                
            case .calculatingNutrition:
                Text("Calculating nutrition...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                
            case .streamingNutrition:
                Text("Analyzing...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                
            case .completed:
                Text("Complete")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.green)
                
            case .error:
                Text("Error")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                
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

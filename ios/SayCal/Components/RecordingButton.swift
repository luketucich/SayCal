import SwiftUI

struct RecordingButton: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {}) {
            ZStack {
                // Background gradient circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(
                        color: shadowColor,
                        radius: audioRecorder.isRecording ? DesignTokens.Shadow.medium.radius : DesignTokens.Shadow.small.radius,
                        y: DesignTokens.Shadow.small.y
                    )
                
                // Icon or progress indicator
                if audioRecorder.isProcessing && !audioRecorder.isRecording {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .disabled(audioRecorder.isProcessing && !audioRecorder.isRecording)
        .scaleEffect(audioRecorder.isRecording ? audioRecorder.currentAudioLevel : 1.0)
        .animation(.easeInOut(duration: 0.1), value: audioRecorder.currentAudioLevel)
        .animation(.spring(response: DesignTokens.AnimationDuration.slow, dampingFraction: 0.6), value: audioRecorder.isRecording)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !audioRecorder.isRecording && !audioRecorder.isProcessing {
                        audioRecorder.startRecording()
                    }
                }
                .onEnded { _ in
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    }
                }
        )
    }
    
    // MARK: - Computed Properties
    
    private var buttonSize: CGFloat {
        audioRecorder.isRecording ? 80 : 64
    }
    
    private var iconSize: CGFloat {
        audioRecorder.isRecording ? 30 : 24
    }
    
    private var iconName: String {
        audioRecorder.isRecording ? "mic.fill" : "mic.fill"
    }
    
    private var gradientColors: [Color] {
        if audioRecorder.isRecording {
            return [Color.red.opacity(DesignTokens.Opacity.veryStrong), Color.red]
        } else {
            return [Color.blue.opacity(DesignTokens.Opacity.veryStrong), Color.blue]
        }
    }

    private var shadowColor: Color {
        audioRecorder.isRecording
            ? Color.red.opacity(DesignTokens.Opacity.medium)
            : Color.blue.opacity(DesignTokens.Opacity.medium)
    }
}

#Preview {
    VStack(spacing: 40) {
        RecordingButton(audioRecorder: {
            let recorder = AudioRecorder()
            recorder.state = .idle
            return recorder
        }())
        
        RecordingButton(audioRecorder: {
            let recorder = AudioRecorder()
            recorder.state = .recording
            return recorder
        }())
    }
    .padding()
    .background(Color(UIColor.systemGray6))
}

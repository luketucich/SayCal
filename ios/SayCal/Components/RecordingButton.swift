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
                        radius: audioRecorder.isRecording ? 20 : 12,
                        y: 6
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
        .animation(Animation.quick, value: audioRecorder.currentAudioLevel)
        .animation(Animation.springResponsive, value: audioRecorder.isRecording)
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
        audioRecorder.isRecording ? Dimensions.recordingButtonActive : Dimensions.recordingButtonIdle
    }

    private var iconSize: CGFloat {
        audioRecorder.isRecording ? Dimensions.recordingIconActive : Dimensions.recordingIconIdle
    }

    private var iconName: String {
        audioRecorder.isRecording ? "mic.fill" : "mic.fill"
    }

    private var gradientColors: [Color] {
        if audioRecorder.isRecording {
            return [Color.recording, Color.recording.opacity(Opacity.strong)]
        } else {
            return [Color.textPrimary, Color.textPrimary.opacity(Opacity.veryStrong)]
        }
    }

    private var shadowColor: Color {
        audioRecorder.isRecording
            ? Color.recording.opacity(Opacity.visible)
            : Color.black.opacity(Opacity.light)
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

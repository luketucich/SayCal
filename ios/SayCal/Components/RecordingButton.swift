import SwiftUI

struct RecordingButton: View {
    @ObservedObject var audioRecorder: AudioRecorder

    var body: some View {
        Button(action: {}) {
            if audioRecorder.isProcessing {
                ProgressView()
                    .tint(Color.buttonPrimaryText)
                    .frame(width: buttonSize, height: buttonSize)
            } else {
                Image(systemName: "mic.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color.buttonPrimaryText)
                    .frame(width: buttonSize, height: buttonSize)
            }
        }
        .disabled(audioRecorder.isProcessing)
        .background(
            Group {
                if #available(iOS 26.0, *) {
                    Circle()
                        .fill(Color.primaryBlue.gradient)
                        .glassEffect()
                        .shadow(
                            color: (audioRecorder.isRecording ? Color.primaryBlue : Color.textTertiary).opacity(0.3),
                            radius: audioRecorder.isRecording ? 20 : 12,
                            y: 6
                        )
                } else {
                    Circle()
                        .fill(Color.primaryBlue)
                        .shadow(
                            color: (audioRecorder.isRecording ? Color.primaryBlue : Color.textTertiary).opacity(0.3),
                            radius: audioRecorder.isRecording ? 20 : 12,
                            y: 6
                        )
                }
            }
        )
        .scaleEffect(audioRecorder.isRecording ? audioRecorder.currentAudioLevel : 1.0)
        .animation(DSAnimation.quick, value: audioRecorder.currentAudioLevel)
        .animation(DSAnimation.spring, value: audioRecorder.isRecording)
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

    // Dynamic button size - larger when recording
    private var buttonSize: CGFloat {
        audioRecorder.isRecording ? 80 : DSSize.buttonLarge
    }

    // Dynamic icon size
    private var iconSize: CGFloat {
        audioRecorder.isRecording ? 28 : 20
    }
}

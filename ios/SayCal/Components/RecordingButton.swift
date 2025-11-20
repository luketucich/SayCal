import SwiftUI

struct RecordingButton: View {
    @ObservedObject var audioRecorder: AudioRecorder

    var body: some View {
        Button(action: {}) {
            if audioRecorder.isProcessing {
                ProgressView()
                    .tint(.white)
                    .frame(width: buttonSize, height: buttonSize)
            } else {
                Image(systemName: "mic.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: buttonSize, height: buttonSize)
            }
        }
        .disabled(audioRecorder.isProcessing)
        .background(
            Group {
                if #available(iOS 26.0, *) {
                    Circle()
                        .fill(DS.Colors.accent.gradient)
                        .glassEffect()
                        .shadowLarge()
                } else {
                    Circle()
                        .fill(DS.Colors.accent)
                        .shadowLarge()
                }
            }
        )
        .scaleEffect(audioRecorder.isRecording ? audioRecorder.currentAudioLevel : 1.0)
        .animation(.easeInOut(duration: 0.1), value: audioRecorder.currentAudioLevel)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioRecorder.isRecording)
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
        audioRecorder.isRecording ? 80 : DS.Layout.buttonHeightLarge
    }

    // Dynamic icon size
    private var iconSize: CGFloat {
        audioRecorder.isRecording ? 28 : DS.Spacing.large
    }
}

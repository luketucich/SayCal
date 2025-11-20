import SwiftUI

struct RecordingButton: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        Button(action: {}) {
            if audioRecorder.isTranscribing {
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
        .disabled(audioRecorder.isTranscribing)
        .background(
            Circle()
                .fill(Color.blue)
                .shadow(
                    color: (audioRecorder.isRecording ? Color.blue : Color.gray).opacity(0.3),
                    radius: audioRecorder.isRecording ? 20 : 12,
                    y: 6
                )
        )
        .scaleEffect(audioRecorder.isRecording ? audioRecorder.currentAudioLevel : 1.0)
        .animation(.easeInOut(duration: 0.1), value: audioRecorder.currentAudioLevel)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioRecorder.isRecording)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !audioRecorder.isRecording && !audioRecorder.isTranscribing {
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
        audioRecorder.isRecording ? 80 : 56
    }
    
    // Dynamic icon size
    private var iconSize: CGFloat {
        audioRecorder.isRecording ? 28 : 20
    }
}

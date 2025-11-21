import SwiftUI

struct RecordingButton: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // Pulsing ring when recording
            if audioRecorder.isRecording {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
            }

            // Main button
            Button(action: {}) {
                ZStack {
                    if audioRecorder.isProcessing && !audioRecorder.isRecording {
                        ProgressView()
                            .tint(.white)
                            .frame(width: buttonSize, height: buttonSize)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: iconSize, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: buttonSize, height: buttonSize)
                            .rotationEffect(.degrees(audioRecorder.isRecording ? 0 : -10))
                    }
                }
            }
            .disabled(audioRecorder.isProcessing && !audioRecorder.isRecording)
            .background(
                Group {
                    if #available(iOS 26.0, *) {
                        Circle()
                            .fill(.blue.gradient)
                            .glassEffect()
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.9), Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .shadow(
                color: buttonShadowColor,
                radius: buttonShadowRadius,
                y: isPressed ? 2 : 6
            )
            .scaleEffect(buttonScale)
            .opacity(audioRecorder.isProcessing && !audioRecorder.isRecording ? 0.6 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioRecorder.isRecording)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
            .animation(.easeInOut(duration: 0.1), value: audioRecorder.currentAudioLevel)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed && !audioRecorder.isRecording && !audioRecorder.isProcessing {
                            isPressed = true
                            HapticManager.shared.medium()
                            audioRecorder.startRecording()
                        }
                    }
                    .onEnded { _ in
                        if audioRecorder.isRecording {
                            isPressed = false
                            audioRecorder.stopRecording()
                        }
                    }
            )
        }
        .frame(width: ringSize, height: ringSize)
    }

    // MARK: - Computed Properties

    private var buttonSize: CGFloat {
        audioRecorder.isRecording ? 80 : 56
    }

    private var iconSize: CGFloat {
        audioRecorder.isRecording ? 28 : 20
    }

    private var ringSize: CGFloat {
        audioRecorder.isRecording ? 100 : 56
    }

    private var buttonScale: CGFloat {
        if audioRecorder.isRecording {
            return audioRecorder.currentAudioLevel
        }
        return isPressed ? 0.95 : 1.0
    }

    private var buttonShadowColor: Color {
        audioRecorder.isRecording
            ? Color.blue.opacity(0.4)
            : Color.gray.opacity(0.3)
    }

    private var buttonShadowRadius: CGFloat {
        audioRecorder.isRecording ? 20 : (isPressed ? 8 : 12)
    }

    private var pulseScale: CGFloat {
        audioRecorder.currentAudioLevel * 1.2
    }

    private var pulseOpacity: Double {
        1.0 - (audioRecorder.currentAudioLevel - 0.85) / 0.65
    }
}

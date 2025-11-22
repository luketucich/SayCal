import SwiftUI

struct RecordingButton: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Environment(\.colorScheme) var colorScheme
    @State private var pulseAnimation = false

    var body: some View {
        Button(action: {}) {
            ZStack {
                // Outer pulse rings (when recording)
                if audioRecorder.isRecording {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        gradientColors[0].opacity(0.3),
                                        gradientColors[1].opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: buttonSize + CGFloat(index * 30), height: buttonSize + CGFloat(index * 30))
                            .opacity(pulseAnimation ? 0 : 0.5)
                            .scaleEffect(pulseAnimation ? 1.4 : 1.0)
                            .animation(
                                Animation.easeOut(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.3),
                                value: pulseAnimation
                            )
                    }
                }

                // Outer glow circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                gradientColors[0].opacity(0.5),
                                gradientColors[1].opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: buttonSize / 2 + 20
                        )
                    )
                    .frame(width: buttonSize + 40, height: buttonSize + 40)
                    .blur(radius: 20)
                    .opacity(audioRecorder.isRecording ? 0.8 : 0.4)

                // Main gradient circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: shadowColor,
                        radius: audioRecorder.isRecording ? 24 : 16,
                        y: audioRecorder.isRecording ? 8 : 6
                    )

                // Icon or progress indicator
                if audioRecorder.isProcessing && !audioRecorder.isRecording {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                } else {
                    ZStack {
                        // Icon background glow
                        Image(systemName: iconName)
                            .font(.system(size: iconSize, weight: .bold))
                            .foregroundStyle(.white)
                            .blur(radius: 8)
                            .opacity(0.6)

                        // Main icon
                        Image(systemName: iconName)
                            .font(.system(size: iconSize, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .disabled(audioRecorder.isProcessing && !audioRecorder.isRecording)
        .scaleEffect(audioRecorder.isRecording ? audioRecorder.currentAudioLevel : 1.0)
        .animation(.easeInOut(duration: 0.1), value: audioRecorder.currentAudioLevel)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: audioRecorder.isRecording)
        .onChange(of: audioRecorder.isRecording) { newValue in
            pulseAnimation = newValue
        }
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
            return [
                Color(red: 1.0, green: 0.3, blue: 0.4),
                Color(red: 1.0, green: 0.5, blue: 0.3)
            ]
        } else {
            return DesignSystem.Colors.primaryGradient
        }
    }

    private var shadowColor: Color {
        audioRecorder.isRecording
            ? Color(red: 1.0, green: 0.3, blue: 0.4).opacity(0.5)
            : DesignSystem.Colors.primary.opacity(0.4)
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

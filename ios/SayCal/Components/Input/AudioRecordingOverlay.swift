import SwiftUI
import AVFoundation

struct AudioRecordingOverlay: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var isPresented: Bool
    var onDismiss: () -> Void
    var onSend: () -> Void

    @State private var animationPhase: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 12) {
                // Stop button on the left
                Button {
                    HapticManager.shared.medium()
                    // Cancel recording without processing
                    if audioRecorder.isRecording {
                        audioRecorder.state = .idle
                    }
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(.tertiarySystemGroupedBackground))
                        )
                }
                .disabled(audioRecorder.state == .transcribing)
                .opacity(audioRecorder.state == .transcribing ? 0.5 : 1.0)

                // Middle section - visualizer, loading, or error state
                ZStack {
                    if audioRecorder.state == .recording {
                        // Audio visualizer - fills available space
                        HStack(spacing: 2) {
                            ForEach(0..<50, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.primary)
                                    .frame(width: 2)
                                    .frame(height: barHeight(for: index, totalBars: 50))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                    } else if audioRecorder.state == .transcribing {
                        // Loading state with bouncing dots
                        HStack(spacing: 10) {
                            Text("Transcribing")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 4) {
                                ForEach(0..<3, id: \.self) { index in
                                    Circle()
                                        .fill(Color.primary)
                                        .frame(width: 6, height: 6)
                                        .offset(y: animationPhase == 0 ? 0 : bounceOffset(for: index))
                                }
                            }
                        }
                    } else if case .error(let message) = audioRecorder.state {
                        // Error state with message and retry button
                        HStack(spacing: 10) {
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)

                            Button {
                                HapticManager.shared.medium()
                                audioRecorder.startRecording()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(Color(.quaternarySystemFill))
                                    )
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)

                // Send button on the right
                Button {
                    HapticManager.shared.medium()
                    onSend()
                    audioRecorder.stopRecording()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(audioRecorder.isRecording ? Color.primary : Color.secondary)
                        .frame(width: 40, height: 40)
                }
                .disabled(!audioRecorder.isRecording)
                .opacity(audioRecorder.isRecording ? 1.0 : 0.5)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 90)  // Position just above tab bar
        }
        .transition(
            .asymmetric(
                insertion: .scale(scale: 0.5).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                removal: .scale(scale: 0.5).combined(with: .opacity).combined(with: .move(edge: .bottom))
            )
        )
        .onAppear {
            if !audioRecorder.isRecording {
                audioRecorder.startRecording()
            }

            // Animate the visualizer
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
        .onChange(of: audioRecorder.state) { _, newState in
            if newState == .transcribing {
                // Reset and start bouncing animation
                animationPhase = 0
                withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                    animationPhase = 1
                }
            }
        }
    }

    private func bounceOffset(for index: Int) -> CGFloat {
        let delay = Double(index) * 0.2
        let phase = (animationPhase - delay).truncatingRemainder(dividingBy: 1.0)
        let bounce = sin(phase * .pi) * -8
        return bounce
    }

    private func barHeight(for index: Int, totalBars: Int) -> CGFloat {
        let minHeight: CGFloat = 3
        let maxHeight: CGFloat = 40

        guard totalBars > 0 else { return minHeight }

        // Create smooth wave motion with multiple frequencies
        let normalizedIndex = Double(index) / Double(totalBars)
        let primaryWave = sin(animationPhase + normalizedIndex * .pi * 2)
        let secondaryWave = sin(animationPhase * 1.3 + normalizedIndex * .pi * 3) * 0.3
        let tertiaryWave = sin(animationPhase * 0.7 + normalizedIndex * .pi * 1.5) * 0.2

        // Combine waves (result is -1 to 1, normalized to 0 to 1)
        let waveValue = (primaryWave + secondaryWave + tertiaryWave) * 0.5 + 0.5

        // Get audio level (now properly 0.0 to 1.0 from AudioRecorderManager)
        let audioLevel = CGFloat(audioRecorder.currentAudioLevel)

        // When silent (audioLevel ~0), bars should be at minimum height
        // When loud (audioLevel ~1), bars should animate fully
        let baselineHeight = minHeight + (audioLevel * 6) // Slight baseline growth
        let dynamicRange = (maxHeight - baselineHeight) * audioLevel

        let height = baselineHeight + (dynamicRange * waveValue)

        return max(minHeight, height)
    }
}

#Preview {
    VStack {
        Spacer()
        AudioRecordingOverlay(
            audioRecorder: {
                let recorder = AudioRecorder()
                recorder.state = .recording
                return recorder
            }(),
            isPresented: .constant(true),
            onDismiss: {},
            onSend: {}
        )
    }
    .background(Color(.systemGray6))
}

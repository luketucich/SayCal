import SwiftUI

struct AudioRecordingOverlay: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var isPresented: Bool
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Audio visualizer
            HStack(spacing: 4) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 3)
                        .frame(height: barHeight(for: index))
                        .animation(
                            .easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.05),
                            value: audioRecorder.isRecording
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)

            Spacer()

            // Send button
            Button {
                HapticManager.shared.medium()
                audioRecorder.stopRecording()
                onSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.blue)
                    )
            }
            .disabled(!audioRecorder.isRecording)
            .opacity(audioRecorder.isRecording ? 1.0 : 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            if !audioRecorder.isRecording {
                audioRecorder.startRecording()
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        if audioRecorder.isRecording {
            let baseHeight: CGFloat = 8
            let maxHeight: CGFloat = 40
            let variation = sin(Double(index) * 0.5 + Date().timeIntervalSince1970 * 2) * 0.5 + 0.5
            return baseHeight + (maxHeight - baseHeight) * variation * CGFloat(audioRecorder.currentAudioLevel)
        }
        return 8
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
            onSend: {}
        )
    }
    .background(Color(.systemGray6))
}

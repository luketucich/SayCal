import SwiftUI
import AVFoundation
import Combine

struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var audioRecorder = AudioRecorder()
    
    var body: some View {
        TabView {
            DailyView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .tint(.primary)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer()
                
                if audioRecorder.isRecording {
                    RecordingExpandedView(audioRecorder: audioRecorder)
                } else {
                    Button(action: {
                        audioRecorder.toggleRecording()
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                    }
                    .applyGlassEffect()
                    .padding(.trailing, 20)
                    .padding(.bottom, 8)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: audioRecorder.isRecording)
            .background(.clear)
        }
        .onAppear {
            audioRecorder.requestPermission()
        }
    }
}

// Helper: Glass Effect with iOS version fallback
extension View {
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear.tint(.blue))
        } else {
            self
                .background(
                    Circle()
                        .fill(.blue.gradient)
                        .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
                )
        }
    }
}

// MARK: - Preview
#Preview {
    MainAppView()
        .environmentObject({
            let manager = UserManager.shared
            return manager
        }())
}

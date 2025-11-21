import SwiftUI
import AVFoundation
import Combine

struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var audioRecorder = AudioRecorder()

    var body: some View {
        ZStack {
            // Main content
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
                    RecordingButton(audioRecorder: audioRecorder)
                        .padding(.trailing, 20)
                        .padding(.bottom, 8)
                }
                .background(.clear)
            }
            .blur(radius: showRecordingWindow ? 3 : 0)
            .disabled(showRecordingWindow)

            // Recording window overlay
            if showRecordingWindow {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Prevent dismissal while processing
                    }
                    .transition(.opacity)

                RecordingWindow(audioRecorder: audioRecorder)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showRecordingWindow)
        .onAppear {
            audioRecorder.requestPermission()
        }
    }

    private var showRecordingWindow: Bool {
        switch audioRecorder.state {
        case .idle:
            return false
        default:
            return true
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

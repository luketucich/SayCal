import SwiftUI
import AVFoundation
import Combine

struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var audioRecorder = AudioRecorder()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab bar with Daily and Profile tabs
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
            .tint(.primary) // Keep icon colors consistent
            
            // Floating microphone button with liquid glass design
            HStack {
                Spacer()
                
                if audioRecorder.isRecording {
                    // Expanded recording view with audio visualizer
                    RecordingExpandedView(audioRecorder: audioRecorder)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    // Collapsed microphone button
                    Button(action: {
                        audioRecorder.toggleRecording()
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                // Liquid glass effect
                                Circle()
                                    .fill(.blue.gradient)
                                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 8)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: audioRecorder.isRecording)
        }
        .onAppear {
            audioRecorder.requestPermission()
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

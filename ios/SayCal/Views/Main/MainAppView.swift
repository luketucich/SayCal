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
        .overlay(alignment: .top) {
            // Transcription text display
            if !audioRecorder.transcriptionText.isEmpty {
                Text(audioRecorder.transcriptionText)
                    .font(.body)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer()
                RecordingButton(audioRecorder: audioRecorder)
                    .padding(.trailing, 20)
                    .padding(.bottom, 8)
            }
            .background(.clear)
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

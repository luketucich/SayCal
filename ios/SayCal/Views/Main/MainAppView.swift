import SwiftUI
import AVFoundation

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
            RecordingOverlay(audioRecorder: audioRecorder)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer()
                RecordingButton(audioRecorder: audioRecorder)
                    .padding(.trailing, Spacing.lg)
                    .padding(.bottom, Spacing.xs)
            }
            .background(.clear)
        }
        .onAppear {
            audioRecorder.requestPermission()
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject({
            let manager = UserManager.shared
            return manager
        }())
}

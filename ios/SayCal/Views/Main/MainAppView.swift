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
        .tint(DS.Colors.label)
        .overlay(alignment: .top) {
            // Transcription text display with scroll view
            if !audioRecorder.displayText.isEmpty {
                ScrollView {
                    Text(audioRecorder.displayText)
                        .font(DS.Typography.body())
                        .foregroundColor(DS.Colors.label)
                        .padding(DS.Spacing.medium)
                }
                .frame(maxHeight: 300)
                .background(DS.Materials.ultraThin)
                .cornerRadius(DS.CornerRadius.large)
                .padding(DS.Spacing.medium)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer()
                RecordingButton(audioRecorder: audioRecorder)
                    .padding(.trailing, DS.Spacing.large)
                    .padding(.bottom, DS.Spacing.xSmall)
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

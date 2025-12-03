import UIKit
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Request notification permission on app launch
        NotificationManager.shared.requestPermission()
        return true
    }

    func application(_ application: UIApplication,
                    handleEventsForBackgroundURLSession identifier: String,
                    completionHandler: @escaping () -> Void) {
        print("🔄 App handling background URL session: \(identifier)")

        // Store the completion handler so the system knows when we're done
        BackgroundNetworkManager.shared.backgroundCompletionHandler = completionHandler
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📱 App became active - checking for meal updates")

        // Trigger UI refresh when app comes to foreground
        DispatchQueue.main.async {
            MealManager.shared.objectWillChange.send()
        }
    }
}

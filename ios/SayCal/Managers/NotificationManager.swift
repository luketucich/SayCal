import Foundation
import UserNotifications

/// Manages local notifications for meal logging events
///
/// **Notifications are sent when:**
/// - Meal analysis completes (success) - even if app is closed
/// - Meal analysis fails - notifies user to retry
///
/// **Permission Request:**
/// Automatically requested on app launch via AppDelegate
class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }

    // MARK: - Meal Notifications

    func sendMealCompletedNotification(mealDescription: String, calories: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Meal Logged!"
        content.body = "\(mealDescription) • \(calories) cal"
        content.sound = .default

        // Deliver immediately
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error.localizedDescription)")
            } else {
                print("📬 Meal completion notification sent")
            }
        }
    }

    func sendMealFailedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Meal Analysis Failed"
        content.body = "We couldn't analyze your meal. Please try again."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error.localizedDescription)")
            } else {
                print("📬 Meal failure notification sent")
            }
        }
    }
}

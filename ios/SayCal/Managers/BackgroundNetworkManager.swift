import Foundation

struct PendingMeal: Codable {
    let transcription: String
    let userId: String
    let timestamp: Double
}

/// Handles nutrition analysis API calls using background URLSession
///
/// **Key Features:**
/// - Continues API calls even when app is suspended or terminated
/// - iOS manages the download and wakes app when complete
/// - Stores pending meals persistently in case of app termination
/// - Automatically updates MealManager when response arrives
///
/// **Background Modes Required:**
/// Enable in Xcode: Signing & Capabilities → Background Modes → Background fetch
class BackgroundNetworkManager: NSObject {
    static let shared = BackgroundNetworkManager()

    private var backgroundSession: URLSession!
    private let sessionIdentifier = "com.saycal.background.nutrition"

    // Store completion handlers for background tasks
    var backgroundCompletionHandler: (() -> Void)?

    // Track pending meal IDs
    private let pendingMealsKey = "pending_background_meals"

    private override init() {
        super.init()

        let configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = true

        backgroundSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        print("🌐 BackgroundNetworkManager initialized")
    }

    // MARK: - Public API

    func analyzeMeal(mealId: String, transcription: String, userId: String) async throws {
        // Use hardcoded Supabase configuration
        let supabaseURL = "https://stzwzlzgroycxpebzkyq.supabase.co"
        let anonKey = "sb_publishable_3jmhHH_JX4KQcT-2i8MpzQ_XtTS9mWC"

        // Construct the edge function URL
        guard let url = URL(string: "\(supabaseURL)/functions/v1/calculate-calories") else {
            throw NSError(domain: "BackgroundNetwork", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "transcribed_meal": transcription,
            "user_id": userId
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Store the pending meal
        storePendingMeal(mealId: mealId, transcription: transcription, userId: userId)

        // Create background task
        let task = backgroundSession.downloadTask(with: request)
        task.taskDescription = mealId // Store meal ID in task description
        task.resume()

        print("🚀 Background task started for meal: \(mealId)")
    }

    // MARK: - Pending Meals Storage

    private func storePendingMeal(mealId: String, transcription: String, userId: String) {
        var pending = getPendingMeals()
        pending[mealId] = PendingMeal(
            transcription: transcription,
            userId: userId,
            timestamp: Date().timeIntervalSince1970
        )

        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: pendingMealsKey)
        }
    }

    private func removePendingMeal(mealId: String) {
        var pending = getPendingMeals()
        pending.removeValue(forKey: mealId)

        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: pendingMealsKey)
        }
    }

    private func getPendingMeals() -> [String: PendingMeal] {
        guard let data = UserDefaults.standard.data(forKey: pendingMealsKey),
              let decoded = try? JSONDecoder().decode([String: PendingMeal].self, from: data) else {
            return [:]
        }
        return decoded
    }
}

// MARK: - URLSession Delegate

extension BackgroundNetworkManager: URLSessionDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let mealId = downloadTask.taskDescription else {
            print("❌ No meal ID found in task description")
            return
        }

        do {
            let data = try Data(contentsOf: location)
            let response = try JSONDecoder().decode(NutritionResponse.self, from: data)

            // Update the meal on main thread
            DispatchQueue.main.async {
                MealManager.shared.updateMeal(id: mealId, nutritionResponse: response)
                self.removePendingMeal(mealId: mealId)
                print("✅ Background task completed for meal: \(mealId)")

                // Send notification with meal details
                if case .success(let analysis) = response {
                    NotificationManager.shared.sendMealCompletedNotification(
                        mealDescription: analysis.description,
                        calories: Int(analysis.totalCalories)
                    )
                }
            }

        } catch {
            print("❌ Failed to process background response: \(error)")

            // Remove the loading meal since it failed
            DispatchQueue.main.async {
                if let meal = MealManager.shared.loggedMeals.first(where: { $0.id == mealId }) {
                    MealManager.shared.deleteMeal(meal)
                }
                self.removePendingMeal(mealId: mealId)

                // Send failure notification
                NotificationManager.shared.sendMealFailedNotification()
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("❌ Background task error: \(error.localizedDescription)")

            if let mealId = task.taskDescription {
                DispatchQueue.main.async {
                    if let meal = MealManager.shared.loggedMeals.first(where: { $0.id == mealId }) {
                        MealManager.shared.deleteMeal(meal)
                    }
                    self.removePendingMeal(mealId: mealId)

                    // Send failure notification
                    NotificationManager.shared.sendMealFailedNotification()
                }
            }
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
            print("🏁 Background URL session finished")
        }
    }
}

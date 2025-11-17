import Foundation
import Supabase
import Combine

@MainActor
class ProfileManager: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: String?

    private let client = SupabaseManager.client

    /// Fetch the user profile for the current authenticated user
    func fetchUserProfile(userId: UUID) async {
        isLoading = true
        error = nil

        do {
            let profile: UserProfile = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
                .value

            userProfile = profile
        } catch {
            self.error = "Failed to load profile: \(error.localizedDescription)"
            print("Error fetching user profile: \(error)")
        }

        isLoading = false
    }

    /// Create a new user profile from quiz input
    func createUserProfile(input: UserProfileInput) async -> Bool {
        isLoading = true
        error = nil

        do {
            let profile: UserProfile = try await client
                .from("user_profiles")
                .insert(input)
                .select()
                .single()
                .execute()
                .value

            userProfile = profile
            isLoading = false
            return true
        } catch {
            self.error = "Failed to create profile: \(error.localizedDescription)"
            print("Error creating user profile: \(error)")
            isLoading = false
            return false
        }
    }

    /// Update an existing user profile
    func updateUserProfile(userId: UUID, input: UserProfileInput) async -> Bool {
        isLoading = true
        error = nil

        do {
            let profile: UserProfile = try await client
                .from("user_profiles")
                .update(input)
                .eq("user_id", value: userId.uuidString)
                .select()
                .single()
                .execute()
                .value

            userProfile = profile
            isLoading = false
            return true
        } catch {
            self.error = "Failed to update profile: \(error.localizedDescription)"
            print("Error updating user profile: \(error)")
            isLoading = false
            return false
        }
    }

    /// Mark onboarding as completed
    func completeOnboarding(userId: UUID) async -> Bool {
        isLoading = true
        error = nil

        do {
            struct OnboardingUpdate: Codable {
                let onboardingCompleted: Bool
            }

            let update = OnboardingUpdate(onboardingCompleted: true)

            let profile: UserProfile = try await client
                .from("user_profiles")
                .update(update)
                .eq("user_id", value: userId.uuidString)
                .select()
                .single()
                .execute()
                .value

            userProfile = profile
            isLoading = false
            return true
        } catch {
            self.error = "Failed to complete onboarding: \(error.localizedDescription)"
            print("Error completing onboarding: \(error)")
            isLoading = false
            return false
        }
    }

    /// Check if user has completed onboarding
    func hasCompletedOnboarding(userId: UUID) async -> Bool {
        do {
            let profile: UserProfile = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
                .value

            userProfile = profile
            return profile.onboardingCompleted
        } catch {
            // If profile doesn't exist, onboarding is not completed
            print("Error checking onboarding status: \(error)")
            return false
        }
    }
}

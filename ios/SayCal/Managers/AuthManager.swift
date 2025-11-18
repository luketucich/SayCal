import Foundation
import Supabase
import Combine

/// AuthManager is the SINGLE PUBLIC INTERFACE for all authentication and profile operations.
/// Views should NEVER directly access UserProfileManager.
///
/// Architecture Pattern (Strict Enforcement):
/// ┌─────────────────────────────────────────┐
/// │ Views (ProfileView, EditProfileView)    │
/// │   - Read: authManager.cachedProfile     │
/// │   - Write: authManager.updateProfile()  │
/// └─────────────────────────────────────────┘
///                    ↓ ↑
/// ┌─────────────────────────────────────────┐
/// │ AuthManager (PUBLIC API)                │
/// │   - Coordinates auth state              │
/// │   - Delegates to UserProfileManager     │
/// │   - Manages profile cache optimization  │
/// └─────────────────────────────────────────┘
///                    ↓ ↑
/// ┌─────────────────────────────────────────┐
/// │ UserProfileManager (INTERNAL)           │
/// │   - Database operations                 │
/// │   - UserDefaults caching                │
/// └─────────────────────────────────────────┘
///
/// Database Fetch Policy:
/// - First login: Fetch from database (no cache exists)
/// - Cache hit: Use UserDefaults cache (fast app startup)
/// - Cache miss/stale: Fetch from database
/// - Manual refresh: Use refreshProfileFromServer()
/// - Profile updates: Automatically sync to database and cache
///
/// This class is focused on authentication logic (sign-in, sign-out, session management)
/// and coordinates all profile-related operations through UserProfileManager.
@MainActor
class AuthManager: ObservableObject {
    // MARK: - Published Properties

    /// Indicates whether the user is currently authenticated
    @Published var isAuthenticated = false

    /// Indicates whether authentication state is being loaded
    @Published private var _isLoading = true

    /// Tracks whether we've completed the initial profile check after authentication
    @Published private var profileCheckComplete = false

    /// Computed property that indicates loading state including profile verification
    var isLoading: Bool {
        _isLoading || !profileCheckComplete
    }

    /// The current authenticated user
    @Published var currentUser: User?

    // MARK: - Private Properties

    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    /// Reference to the UserProfileManager for profile operations
    private let profileManager = UserProfileManager.shared

    // MARK: - Computed Properties

    /// Indicates whether the user has completed onboarding (delegates to UserProfileManager)
    var onboardingCompleted: Bool {
        profileManager.onboardingCompleted
    }

    /// The cached user profile (delegates to UserProfileManager)
    var cachedProfile: UserProfile? {
        profileManager.currentProfile
    }

    // MARK: - Initialization

    init() {
        setupAuthListener()
        setupProfileManagerObserver()
    }

    // MARK: - Profile Manager Observer

    /// Observes changes to the UserProfileManager and triggers AuthManager updates
    private func setupProfileManagerObserver() {
        // When the profile manager's onboardingCompleted changes, notify our observers
        profileManager.$onboardingCompleted
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // When the profile manager's currentProfile changes, notify our observers
        profileManager.$currentProfile
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Auth State Listener

    /// Sets up a listener for authentication state changes.
    /// Automatically loads the user profile when the user logs in.
    private func setupAuthListener() {
        authStateTask = Task {
            for await state in client.auth.authStateChanges {
                // Reset profile check flag at the start of each auth state change
                self.profileCheckComplete = false

                self.isAuthenticated = state.session != nil
                self.currentUser = state.session?.user

                if let session = state.session {
                    print("User authenticated: \(session.user.id)")
                    // Load the user profile from the database
                    await loadUserProfile()
                } else {
                    print("User not authenticated")
                    // Clear profile data when user logs out
                    profileManager.clearCache()
                }

                // Mark profile check as complete after handling auth state
                self.profileCheckComplete = true
                self._isLoading = false
            }
        }
    }

    // MARK: - Profile Loading

    /// Loads the user profile, checking cache first before fetching from database.
    /// Only fetches from database if:
    /// - No cached profile exists
    /// - Cached profile belongs to a different user
    private func loadUserProfile() async {
        guard let userId = currentUser?.id else { return }

        // First check if we have a valid cached profile
        if let cached = profileManager.currentProfile, cached.userId == userId {
            // Cache is valid, no need to fetch from database
            print("✅ Using cached profile for user: \(userId)")
            return
        }

        // Only fetch from database if cache is missing or stale
        print("📥 Fetching profile from database for user: \(userId)")
        _ = await profileManager.loadProfile(for: userId)
    }

    /// Loads the full user profile from database (for external use)
    func loadFullProfile() async -> UserProfile? {
        guard let userId = currentUser?.id else { return nil }
        return await profileManager.loadProfile(for: userId)
    }

    /// Explicitly refreshes profile data from the server.
    /// Use this when you need to ensure you have the latest data from the database,
    /// bypassing the cache.
    func refreshProfileFromServer() async {
        guard let userId = currentUser?.id else { return }
        print("🔄 Explicitly refreshing profile from server for user: \(userId)")
        _ = await profileManager.loadProfile(for: userId)
    }

    // MARK: - Onboarding

    /// Completes the onboarding process and creates a user profile in the database.
    /// IMPORTANT: The database always stores height and weight in metric (cm, kg).
    /// If the user's preference is imperial, we convert their input to metric before saving.
    /// - Parameter state: The onboarding state containing all user inputs
    func completeOnboarding(with state: OnboardingState) async {
        guard let userId = currentUser?.id else { return }

        // Convert to metric if needed (database stores everything in metric)
        let weightKg: Double
        if state.unitsPreference == .imperial {
            weightKg = state.weightLbs.lbsToKg
        } else {
            weightKg = state.weightKg
        }

        let heightCm: Int
        if state.unitsPreference == .imperial {
            heightCm = feetAndInchesToCm(feet: state.heightFeet, inches: state.heightInches)
        } else {
            heightCm = state.heightCm
        }

        // Calculate target calories and macro percentages
        let targetCalories = UserProfileManager.calculateTargetCalories(
            sex: state.sex,
            age: state.age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: state.activityLevel,
            goal: state.goal
        )
        let macros = UserProfileManager.calculateMacroPercentages(for: state.goal)

        // Create the profile using UserProfileManager
        do {
            try await profileManager.createProfile(
                userId: userId,
                unitsPreference: state.unitsPreference,
                sex: state.sex,
                age: state.age,
                heightCm: heightCm,
                weightKg: weightKg,
                activityLevel: state.activityLevel,
                goal: state.goal,
                dietaryPreferences: state.selectedDietaryPreferences.isEmpty ? nil : Array(state.selectedDietaryPreferences),
                allergies: state.selectedAllergies.isEmpty ? nil : Array(state.selectedAllergies),
                targetCalories: targetCalories,
                carbsPercent: macros.carbs,
                fatsPercent: macros.fats,
                proteinPercent: macros.protein
            )
        } catch {
            print("❌ Failed to complete onboarding: \(error)")
        }
    }

    // MARK: - Profile Update

    /// Updates the user profile in both the database and UserDefaults.
    /// Call this method whenever the user makes changes to their profile.
    /// - Parameter updatedProfile: The updated UserProfile object
    func updateProfile(_ updatedProfile: UserProfile) async throws {
        guard let userId = currentUser?.id else {
            throw NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }

        // Delegate to UserProfileManager
        try await profileManager.updateProfile(userId: userId, updatedProfile: updatedProfile)
    }

    // MARK: - Sign Out

    /// Signs out the current user and clears all local state
    func signOut() async {
        do {
            try await client.auth.signOut()
            // Clear profile cache
            profileManager.clearCache()
            print("✅ Sign out successful")
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
        }
    }

    deinit {
        // Cancel auth state listener when AuthManager is deallocated
        authStateTask?.cancel()
    }
}

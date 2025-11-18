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

    @Published var isAuthenticated = false
    @Published private var _isLoading = true
    @Published private var profileCheckComplete = false

    var isLoading: Bool {
        _isLoading || !profileCheckComplete
    }

    @Published var currentUser: User?

    // MARK: - Private Properties

    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private let profileManager = UserProfileManager.shared

    // MARK: - Computed Properties

    var onboardingCompleted: Bool {
        profileManager.onboardingCompleted
    }

    var cachedProfile: UserProfile? {
        profileManager.currentProfile
    }

    // MARK: - Initialization

    init() {
        setupAuthListener()
        setupProfileManagerObserver()
    }

    // MARK: - Profile Manager Observer

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

    // Check cache first, only fetch from database if cache is missing or stale
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

    func loadFullProfile() async -> UserProfile? {
        guard let userId = currentUser?.id else { return nil }
        return await profileManager.loadProfile(for: userId)
    }

    func refreshProfileFromServer() async {
        guard let userId = currentUser?.id else { return }
        print("🔄 Explicitly refreshing profile from server for user: \(userId)")
        _ = await profileManager.loadProfile(for: userId)
    }

    // MARK: - Onboarding

    // Database stores height/weight in metric - convert from imperial if needed
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

    func updateProfile(_ updatedProfile: UserProfile) async throws {
        guard let userId = currentUser?.id else {
            throw NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }

        // Delegate to UserProfileManager
        try await profileManager.updateProfile(userId: userId, updatedProfile: updatedProfile)
    }

    // MARK: - Sign Out

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

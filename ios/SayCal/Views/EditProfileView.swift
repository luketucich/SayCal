import SwiftUI
import Auth

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isEditing: Bool
    @Binding var isSaving: Bool
    @Binding var showSaveSuccess: Bool

    // Local state for editing
    // IMPORTANT: heightCm and weightKg are the authoritative values (stored in database).
    // Imperial values (heightFeet, heightInches, weightLbs) are only for display/editing.
    @State private var unitsPreference: UnitsPreference = .metric
    @State private var sex: Sex = .male
    @State private var age: Int = 25
    @State private var heightCm: Int = 170  // Authoritative metric value
    @State private var heightFeet: Int = 5  // Display-only imperial value
    @State private var heightInches: Int = 7  // Display-only imperial value
    @State private var weightKg: Double = 70.0  // Authoritative metric value
    @State private var weightLbs: Double = 154.0  // Display-only imperial value
    @State private var activityLevel: ActivityLevel = .moderatelyActive
    @State private var goal: Goal = .maintainWeight
    @State private var selectedDietaryPreferences: Set<String> = []
    @State private var selectedAllergies: Set<String> = []

    // Picker states
    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Editing header
                OnboardingHeader(
                    title: "Edit Profile",
                    subtitle: "Update your information"
                )

                VStack(spacing: 24) {
                    // Goal - Moved to top, shows calories first
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(title: "Goal")

                        // Target Calories Display - Shows calories first
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Target Calories")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(UIColor.secondaryLabel))

                                    Text("\(calculateTargetCalories())")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(UIColor.label))

                                    Text("calories per day")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                }

                                Spacer()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.systemGray6))
                            )
                        }

                        VStack(spacing: 12) {
                            ForEach(Goal.allCases, id: \.self) { goalOption in
                                SelectableCard(
                                    title: goalOption.displayName,
                                    subtitle: goalOption.calorieAdjustmentText,
                                    isSelected: goal == goalOption
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        goal = goalOption
                                    }
                                }
                            }
                        }
                    }

                    // Activity Level
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(title: "Activity Level")

                        VStack(spacing: 12) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                SelectableCard(
                                    title: level.displayName,
                                    isSelected: activityLevel == level
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        activityLevel = level
                                    }
                                }
                            }
                        }
                    }

                    // Units Preference
                    VStack(alignment: .leading, spacing: 10) {
                        FormSectionHeader(title: "Units")

                        HStack(spacing: 12) {
                            TogglePill(
                                title: "Metric",
                                isSelected: unitsPreference == .metric,
                                style: .rounded
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    unitsPreference = .metric
                                    syncUnits()
                                }
                            }

                            TogglePill(
                                title: "Imperial",
                                isSelected: unitsPreference == .imperial,
                                style: .rounded
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    unitsPreference = .imperial
                                    syncUnits()
                                }
                            }
                        }
                    }

                    // Sex Selection
                    VStack(alignment: .leading, spacing: 10) {
                        FormSectionHeader(title: "Sex")

                        HStack(spacing: 12) {
                            TogglePill(
                                title: "Male",
                                isSelected: sex == .male,
                                style: .rounded
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    sex = .male
                                }
                            }

                            TogglePill(
                                title: "Female",
                                isSelected: sex == .female,
                                style: .rounded
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    sex = .female
                                }
                            }
                        }
                    }

                    // Age Selector
                    VStack(alignment: .leading, spacing: 10) {
                        FormSectionHeader(title: "Age")

                        FormPickerButton(label: "\(age) years") {
                            HapticManager.shared.light()
                            showAgePicker.toggle()
                        }
                    }

                    // Height Selector
                    VStack(alignment: .leading, spacing: 10) {
                        FormSectionHeader(title: "Height")

                        FormPickerButton(
                            label: unitsPreference == .metric ? "\(heightCm) cm" : "\(heightFeet)' \(heightInches)\""
                        ) {
                            HapticManager.shared.light()
                            showHeightPicker.toggle()
                        }
                    }

                    // Weight Selector
                    VStack(alignment: .leading, spacing: 10) {
                        FormSectionHeader(title: "Weight")

                        FormPickerButton(
                            label: unitsPreference == .metric ? String(format: "%.1f kg", weightKg) : "\(Int(weightLbs)) lbs"
                        ) {
                            HapticManager.shared.light()
                            showWeightPicker.toggle()
                        }
                    }

                    // Dietary Preferences
                    MultiSelectPillGrid(
                        title: "Dietary Preferences",
                        selectedItems: $selectedDietaryPreferences,
                        items: DietaryOptions.dietaryPreferences
                    )

                    // Allergies
                    MultiSelectPillGrid(
                        title: "Allergies",
                        selectedItems: $selectedAllergies,
                        items: DietaryOptions.commonAllergies
                    )
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showAgePicker) {
            PickerSheet(
                title: "Select Age",
                selection: $age,
                range: 13...120,
                suffix: " years",
                isPresented: $showAgePicker
            )
        }
        .sheet(isPresented: $showHeightPicker) {
            if unitsPreference == .metric {
                PickerSheet(
                    title: "Select Height",
                    selection: Binding(
                        get: { heightCm },
                        set: { newValue in
                            heightCm = newValue
                            // Sync imperial values
                            let (feet, inches) = newValue.cmToFeetAndInches
                            heightFeet = feet
                            heightInches = inches
                        }
                    ),
                    range: 100...250,
                    suffix: " cm",
                    isPresented: $showHeightPicker
                )
            } else {
                FeetInchesPickerSheet(
                    title: "Select Height",
                    feet: Binding(
                        get: { heightFeet },
                        set: { newFeet in
                            heightFeet = newFeet
                            // Sync metric value
                            heightCm = feetAndInchesToCm(feet: newFeet, inches: heightInches)
                        }
                    ),
                    inches: Binding(
                        get: { heightInches },
                        set: { newInches in
                            heightInches = newInches
                            // Sync metric value
                            heightCm = feetAndInchesToCm(feet: heightFeet, inches: newInches)
                        }
                    ),
                    isPresented: $showHeightPicker
                )
            }
        }
        .sheet(isPresented: $showWeightPicker) {
            if unitsPreference == .metric {
                WeightPickerSheet(
                    title: "Select Weight",
                    weightKg: Binding(
                        get: { weightKg },
                        set: { newValue in
                            weightKg = newValue
                            // Sync imperial value
                            weightLbs = newValue.kgToLbs
                        }
                    ),
                    isPresented: $showWeightPicker
                )
            } else {
                PickerSheet(
                    title: "Select Weight",
                    selection: Binding(
                        get: { Int(weightLbs) },
                        set: { newValue in
                            weightLbs = Double(newValue)
                            // Sync metric value
                            weightKg = Double(newValue).lbsToKg
                        }
                    ),
                    range: 40...600,
                    suffix: " lbs",
                    isPresented: $showWeightPicker
                )
            }
        }
        .onAppear {
            loadProfileData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveProfile"))) { _ in
            Task {
                await saveProfile()
            }
        }
    }

    // MARK: - Helper Functions

    /// Loads profile data from AuthManager into local state.
    /// The metric values (heightCm, weightKg) are loaded directly from the profile.
    /// Imperial values are calculated from metric for display purposes only.
    private func loadProfileData() {
        guard let profile = authManager.cachedProfile else { return }

        // Load profile data into local state
        unitsPreference = profile.unitsPreference
        sex = profile.sex
        age = profile.age
        heightCm = profile.heightCm  // Authoritative metric value from database
        weightKg = profile.weightKg  // Authoritative metric value from database
        activityLevel = profile.activityLevel
        goal = profile.goal
        selectedDietaryPreferences = Set(profile.dietaryPreferences ?? [])
        selectedAllergies = Set(profile.allergies ?? [])

        // Calculate imperial values from metric for display (not stored)
        let (feet, inches) = heightCm.cmToFeetAndInches
        heightFeet = feet
        heightInches = inches
        weightLbs = weightKg.kgToLbs
    }

    /// Syncs units when user switches between metric and imperial.
    /// IMPORTANT: We always convert FROM metric TO imperial, never the reverse.
    /// When switching to imperial, we calculate imperial from the metric values.
    /// When switching back to metric, we recalculate metric from the current imperial values.
    /// This ensures that the user's edits in imperial are reflected in the metric values.
    private func syncUnits() {
        if unitsPreference == .imperial {
            // Switching to imperial: calculate imperial values from authoritative metric
            let (feet, inches) = heightCm.cmToFeetAndInches
            heightFeet = feet
            heightInches = inches
            weightLbs = weightKg.kgToLbs
        } else {
            // Switching back to metric: update metric from current imperial values
            // (in case user edited in imperial mode)
            heightCm = feetAndInchesToCm(feet: heightFeet, inches: heightInches)
            weightKg = weightLbs.lbsToKg
        }
    }

    /// Calculates target calories using the centralized implementation.
    /// Always uses the metric values (heightCm, weightKg) which are kept in sync.
    private func calculateTargetCalories() -> Int {
        UserProfile.calculateTargetCalories(
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal
        )
    }

    /// Saves the profile to the database via AuthManager.
    /// IMPORTANT: We always save metric values (heightCm, weightKg) to the database.
    /// Imperial values are never persisted - they're calculated on-the-fly for display.
    func saveProfile() async {
        isSaving = true

        guard let userId = authManager.currentUser?.id else {
            isSaving = false
            return
        }

        // Create updated profile using authoritative metric values
        let updatedProfile = UserProfile(
            userId: userId,
            unitsPreference: unitsPreference,
            sex: sex,
            age: age,
            heightCm: heightCm,  // Always save metric (database stores in metric)
            weightKg: weightKg,  // Always save metric (database stores in metric)
            activityLevel: activityLevel,
            dietaryPreferences: selectedDietaryPreferences.isEmpty ? nil : Array(selectedDietaryPreferences),
            allergies: selectedAllergies.isEmpty ? nil : Array(selectedAllergies),
            goal: goal,
            targetCalories: calculateTargetCalories(),
            createdAt: authManager.cachedProfile?.createdAt,
            updatedAt: Date(),
            onboardingCompleted: true
        )

        do {
            try await authManager.updateProfile(updatedProfile)
            isSaving = false
            isEditing = false
            showSaveSuccess = true
        } catch {
            print("Failed to save profile: \(error)")
            isSaving = false
        }
    }
}

import SwiftUI
import Auth

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isEditing: Bool
    @Binding var isSaving: Bool
    @Binding var showSaveSuccess: Bool

    // Local state for editing
    @State private var unitsPreference: UnitsPreference = .metric
    @State private var sex: Sex = .male
    @State private var age: Int = 25
    @State private var heightCm: Int = 170
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 7
    @State private var weightKg: Double = 70.0
    @State private var weightLbs: Double = 154.0
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

                    // Goal
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(title: "Goal")

                        // Target Calories Display
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

    private func loadProfileData() {
        guard let profile = authManager.cachedProfile else { return }

        // Load profile data into local state
        unitsPreference = profile.unitsPreference
        sex = profile.sex
        age = profile.age
        heightCm = profile.heightCm
        weightKg = profile.weightKg
        activityLevel = profile.activityLevel
        goal = profile.goal
        selectedDietaryPreferences = Set(profile.dietaryPreferences ?? [])
        selectedAllergies = Set(profile.allergies ?? [])

        // Sync imperial values from the authoritative metric values
        let (feet, inches) = heightCm.cmToFeetAndInches
        heightFeet = feet
        heightInches = inches
        weightLbs = weightKg.kgToLbs
    }

    private func syncUnits() {
        if unitsPreference == .imperial {
            // Convert metric to imperial
            let (feet, inches) = heightCm.cmToFeetAndInches
            heightFeet = feet
            heightInches = inches
            weightLbs = weightKg.kgToLbs
        } else {
            // Convert imperial to metric
            heightCm = feetAndInchesToCm(feet: heightFeet, inches: heightInches)
            weightKg = weightLbs.lbsToKg
        }
    }

    private func calculateTargetCalories() -> Int {
        // Always use the metric values (which are kept in sync)
        let bmr: Double
        if sex == .male {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) - 161
        }

        let tdee = bmr * activityLevel.activityMultiplier
        let targetCalories = Int(tdee) + goal.calorieAdjustment

        let minimumCalories = sex == .male ? 1500 : 1200
        return max(targetCalories, minimumCalories)
    }

    func saveProfile() async {
        isSaving = true

        // Use the metric values directly (they're already in sync)
        guard let userId = authManager.currentUser?.id else {
            isSaving = false
            return
        }

        let updatedProfile = UserProfile(
            userId: userId,
            unitsPreference: unitsPreference,
            sex: sex,
            age: age,
            heightCm: heightCm,  // Use metric values directly
            weightKg: weightKg,  // Use metric values directly
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

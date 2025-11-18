import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager

    // Editing state
    @State private var isEditing = false

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

    // Loading state
    @State private var isSaving = false
    @State private var showSaveSuccess = false

    var body: some View {
        NavigationStack {
            if let profile = authManager.cachedProfile {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        if !isEditing {
                            // Header section
                            OnboardingHeader(
                                title: "Your Profile",
                                subtitle: "View and manage your information"
                            )
                        } else {
                            // Editing header
                            OnboardingHeader(
                                title: "Edit Profile",
                                subtitle: "Update your information"
                            )
                        }

                        if !isEditing {
                            readOnlyView(profile: profile)
                        } else {
                            editingView()
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
                .background(Color(UIColor.systemBackground))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !isEditing {
                            Button {
                                HapticManager.shared.light()
                                startEditing(with: profile)
                            } label: {
                                Text("Edit")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(UIColor.label))
                            }
                        } else {
                            HStack(spacing: 16) {
                                Button {
                                    HapticManager.shared.light()
                                    isEditing = false
                                } label: {
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }

                                Button {
                                    HapticManager.shared.medium()
                                    Task {
                                        await saveProfile()
                                    }
                                } label: {
                                    if isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.label)))
                                    } else {
                                        Text("Save")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(UIColor.label))
                                    }
                                }
                                .disabled(isSaving)
                            }
                        }
                    }
                }
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
                            selection: $heightCm,
                            range: 100...250,
                            suffix: " cm",
                            isPresented: $showHeightPicker
                        )
                    } else {
                        FeetInchesPickerSheet(
                            title: "Select Height",
                            feet: $heightFeet,
                            inches: $heightInches,
                            isPresented: $showHeightPicker
                        )
                    }
                }
                .sheet(isPresented: $showWeightPicker) {
                    if unitsPreference == .metric {
                        WeightPickerSheet(
                            title: "Select Weight",
                            weightKg: $weightKg,
                            isPresented: $showWeightPicker
                        )
                    } else {
                        PickerSheet(
                            title: "Select Weight",
                            selection: Binding(
                                get: { Int(weightLbs) },
                                set: { weightLbs = Double($0) }
                            ),
                            range: 40...600,
                            suffix: " lbs",
                            isPresented: $showWeightPicker
                        )
                    }
                }
                .alert("Profile Updated", isPresented: $showSaveSuccess) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Your profile has been updated successfully")
                }
            } else {
                VStack {
                    Text("No profile data available")
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Profile")
            }
        }
    }

    @ViewBuilder
    private func readOnlyView(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Basic Info Section
            sectionHeader("Basic Information")
            infoCard {
                infoRow(label: "Sex", value: profile.sex.displayName)
                infoRow(label: "Age", value: "\(profile.age) years")
                infoRow(label: "Units", value: profile.unitsPreference.displayName)
            }

            // Physical Stats Section
            sectionHeader("Physical Stats")
            infoCard {
                if profile.unitsPreference == .imperial {
                    let (feet, inches) = profile.heightCm.cmToFeetAndInches
                    infoRow(label: "Height", value: "\(feet)' \(inches)\"")
                } else {
                    infoRow(label: "Height", value: "\(profile.heightCm) cm")
                }

                if profile.unitsPreference == .imperial {
                    let lbs = profile.weightKg.kgToLbs
                    infoRow(label: "Weight", value: String(format: "%.1f lbs", lbs))
                } else {
                    infoRow(label: "Weight", value: String(format: "%.1f kg", profile.weightKg))
                }
            }

            // Activity & Goals Section
            sectionHeader("Activity & Goals")
            infoCard {
                infoRow(label: "Activity Level", value: profile.activityLevel.displayName)
                infoRow(label: "Goal", value: profile.goal.displayName)
                infoRow(label: "Target Calories", value: "\(profile.targetCalories) cal/day")
            }

            // Dietary Preferences Section
            sectionHeader("Dietary Preferences")
            if let preferences = profile.dietaryPreferences, !preferences.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(preferences, id: \.self) { preference in
                        pillBadge(preference.replacingOccurrences(of: "_", with: " ").capitalized)
                    }
                }
            } else {
                Text("None")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            // Allergies Section
            sectionHeader("Allergies")
            if let allergies = profile.allergies, !allergies.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(allergies, id: \.self) { allergy in
                        pillBadge(allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                    }
                }
            } else {
                Text("None")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            // Sign Out Button
            Button(action: {
                HapticManager.shared.medium()
                Task {
                    await authManager.signOut()
                }
            }) {
                HStack {
                    Spacer()
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                    Spacer()
                }
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 1)
                )
            }
        }
    }

    @ViewBuilder
    private func editingView() -> some View {
        VStack(spacing: 24) {
            // Units Preference
            VStack(alignment: .leading, spacing: 10) {
                Text("Units")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

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
                Text("Sex")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

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
                Text("Age")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

                Button {
                    HapticManager.shared.light()
                    showAgePicker.toggle()
                } label: {
                    HStack {
                        Text("\(age) years")
                            .font(.system(size: 16))
                            .foregroundColor(Color(UIColor.label))

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )
                }
            }

            // Height Selector
            VStack(alignment: .leading, spacing: 10) {
                Text("Height")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

                Button {
                    HapticManager.shared.light()
                    showHeightPicker.toggle()
                } label: {
                    HStack {
                        if unitsPreference == .metric {
                            Text("\(heightCm) cm")
                                .font(.system(size: 16))
                                .foregroundColor(Color(UIColor.label))
                        } else {
                            Text("\(heightFeet)' \(heightInches)\"")
                                .font(.system(size: 16))
                                .foregroundColor(Color(UIColor.label))
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )
                }
            }

            // Weight Selector
            VStack(alignment: .leading, spacing: 10) {
                Text("Weight")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

                Button {
                    HapticManager.shared.light()
                    showWeightPicker.toggle()
                } label: {
                    HStack {
                        if unitsPreference == .metric {
                            Text(String(format: "%.1f kg", weightKg))
                                .font(.system(size: 16))
                                .foregroundColor(Color(UIColor.label))
                        } else {
                            Text("\(Int(weightLbs)) lbs")
                                .font(.system(size: 16))
                                .foregroundColor(Color(UIColor.label))
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )
                }
            }

            // Activity Level
            VStack(alignment: .leading, spacing: 12) {
                Text("Activity Level")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

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
                Text("Goal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

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
                            subtitle: calorieAdjustmentText(for: goalOption),
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
            VStack(alignment: .leading, spacing: 12) {
                Text("Dietary Preferences")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(DietaryOptions.dietaryPreferences, id: \.self) { preference in
                        TogglePill(
                            title: preference.replacingOccurrences(of: "_", with: " ").capitalized,
                            isSelected: selectedDietaryPreferences.contains(preference)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedDietaryPreferences.contains(preference) {
                                    selectedDietaryPreferences.remove(preference)
                                } else {
                                    selectedDietaryPreferences.insert(preference)
                                }
                            }
                        }
                    }
                }
            }

            // Allergies
            VStack(alignment: .leading, spacing: 12) {
                Text("Allergies")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(DietaryOptions.commonAllergies, id: \.self) { allergy in
                        TogglePill(
                            title: allergy.replacingOccurrences(of: "_", with: " ").capitalized,
                            isSelected: selectedAllergies.contains(allergy)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedAllergies.contains(allergy) {
                                    selectedAllergies.remove(allergy)
                                } else {
                                    selectedAllergies.insert(allergy)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color(UIColor.label))
    }

    @ViewBuilder
    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func infoRow(label: String, value: String, isLast: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor.secondaryLabel))

                Spacer()

                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(UIColor.label))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if !isLast {
                Divider()
                    .padding(.leading, 16)
            }
        }
    }

    @ViewBuilder
    private func pillBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(UIColor.label))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        Capsule()
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    )
            )
    }

    // MARK: - Helper Functions

    private func startEditing(with profile: UserProfile) {
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

        // Convert to imperial if needed
        if unitsPreference == .imperial {
            let (feet, inches) = heightCm.cmToFeetAndInches
            heightFeet = feet
            heightInches = inches
            weightLbs = weightKg.kgToLbs
        }

        isEditing = true
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
        // Convert to metric for calculation
        let weightInKg: Double
        let heightInCm: Int

        if unitsPreference == .imperial {
            weightInKg = weightLbs.lbsToKg
            heightInCm = feetAndInchesToCm(feet: heightFeet, inches: heightInches)
        } else {
            weightInKg = weightKg
            heightInCm = heightCm
        }

        // Calculate BMR using Mifflin-St Jeor Equation
        let bmr: Double
        if sex == .male {
            bmr = (10 * weightInKg) + (6.25 * Double(heightInCm)) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightInKg) + (6.25 * Double(heightInCm)) - (5 * Double(age)) - 161
        }

        // Calculate TDEE
        let tdee = bmr * activityLevel.activityMultiplier

        // Adjust based on goal
        let targetCalories = Int(tdee) + goal.calorieAdjustment

        // Ensure minimum safe calories
        let minimumCalories = sex == .male ? 1500 : 1200
        return max(targetCalories, minimumCalories)
    }

    private func calorieAdjustmentText(for goal: Goal) -> String {
        let adjustment = goal.calorieAdjustment
        if adjustment > 0 {
            return "+\(adjustment) calories"
        } else if adjustment < 0 {
            return "\(adjustment) calories"
        } else {
            return "Maintain current weight"
        }
    }

    private func saveProfile() async {
        isSaving = true

        // Convert to metric for database storage
        let finalWeightKg: Double
        let finalHeightCm: Int

        if unitsPreference == .imperial {
            finalWeightKg = weightLbs.lbsToKg
            finalHeightCm = feetAndInchesToCm(feet: heightFeet, inches: heightInches)
        } else {
            finalWeightKg = weightKg
            finalHeightCm = heightCm
        }

        // Create updated profile
        guard let userId = authManager.currentUser?.id else {
            isSaving = false
            return
        }

        let updatedProfile = UserProfile(
            userId: userId,
            unitsPreference: unitsPreference,
            sex: sex,
            age: age,
            heightCm: finalHeightCm,
            weightKg: finalWeightKg,
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

#Preview {
    ProfileView()
        .environmentObject({
            let manager = AuthManager()
            manager.isAuthenticated = true
            manager.isLoading = false
            manager.onboardingCompleted = true
            return manager
        }())
}

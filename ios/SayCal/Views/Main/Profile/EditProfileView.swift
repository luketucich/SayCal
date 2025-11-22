import SwiftUI
import Auth

struct EditProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var isEditing: Bool
    @Binding var isSaving: Bool
    @Binding var showSaveSuccess: Bool
    @Binding var saveAction: (() async -> Void)?

    // Metric values are authoritative (stored in DB), imperial is display-only
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
    @State private var manualCalories: Int? = nil
    @State private var showCaloriePicker = false
    @State private var manualCarbsPercent: Int? = nil
    @State private var manualFatsPercent: Int? = nil
    @State private var manualProteinPercent: Int? = nil
    @State private var showMacroPicker = false
    @State private var editingMacro: MacroType? = nil

    enum MacroType {
        case carbs, fats, protein

        var displayName: String {
            switch self {
            case .carbs: return "Carbs"
            case .fats: return "Fats"
            case .protein: return "Protein"
            }
        }
    }

    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false

    private var currentCalories: Int {
        manualCalories ?? calculateTargetCalories()
    }

    private var currentCarbsPercent: Int {
        manualCarbsPercent ?? calculateMacroPercentages().carbs
    }

    private var currentFatsPercent: Int {
        manualFatsPercent ?? calculateMacroPercentages().fats
    }

    private var currentProteinPercent: Int {
        manualProteinPercent ?? calculateMacroPercentages().protein
    }

    private var hasMacroOverride: Bool {
        manualCarbsPercent != nil || manualFatsPercent != nil || manualProteinPercent != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                OnboardingHeader(
                    title: "Edit Profile",
                    subtitle: "Update your information"
                )

                VStack(spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        FormSectionHeader(title: "Goals")

                        VStack(spacing: Spacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.xxs) {
                                    Text("Your Target Calories")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)

                                    Text("\(currentCalories)")
                                        .font(.largeTitle)
                                        .foregroundColor(.textPrimary)

                                    Text(manualCalories != nil ? "manual override" : "calories per day")
                                        .font(.smallCaption)
                                        .foregroundColor(manualCalories != nil ? .warning : .textTertiary)
                                }

                                Spacer()

                                HStack(spacing: Spacing.sm) {
                                    if manualCalories != nil {
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                manualCalories = nil
                                            }
                                            HapticManager.shared.light()
                                        }) {
                                            Image(systemName: "arrow.counterclockwise")
                                                .font(.bodyMedium)
                                                .foregroundColor(.warning)
                                                .frame(width: Spacing.xxxl, height: Spacing.xxxl)
                                                .background(
                                                    Circle()
                                                        .fill(.warning.opacity(0.15))
                                                )
                                        }
                                    }

                                    Button(action: {
                                        showCaloriePicker = true
                                        HapticManager.shared.light()
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.bodyMedium)
                                            .foregroundColor(.textPrimary)
                                            .frame(width: Spacing.xxxl, height: Spacing.xxxl)
                                            .background(
                                                Circle()
                                                    .fill(Color(UIColor.systemGray5))
                                            )
                                    }
                                }
                            }
                            .padding(Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(Color(UIColor.systemGray6))
                            )
                        }

                        VStack(spacing: Spacing.sm) {
                            HStack(spacing: Spacing.sm) {
                                MacroCard(
                                    title: "Carbs",
                                    percentage: currentCarbsPercent,
                                    color: .blue,
                                    onEdit: {
                                        editingMacro = .carbs
                                        showMacroPicker = true
                                        HapticManager.shared.light()
                                    }
                                )

                                MacroCard(
                                    title: "Fats",
                                    percentage: currentFatsPercent,
                                    color: .orange,
                                    onEdit: {
                                        editingMacro = .fats
                                        showMacroPicker = true
                                        HapticManager.shared.light()
                                    }
                                )

                                MacroCard(
                                    title: "Protein",
                                    percentage: currentProteinPercent,
                                    color: .green,
                                    onEdit: {
                                        editingMacro = .protein
                                        showMacroPicker = true
                                        HapticManager.shared.light()
                                    }
                                )
                            }

                            HStack {
                                if hasMacroOverride {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            manualCarbsPercent = nil
                                            manualFatsPercent = nil
                                            manualProteinPercent = nil
                                        }
                                        HapticManager.shared.light()
                                    }) {
                                        HStack(spacing: Spacing.xs) {
                                            Image(systemName: "arrow.counterclockwise")
                                                .font(.smallCaption)
                                            Text("Reset to recommended")
                                                .font(.smallCaptionMedium)
                                        }
                                        .foregroundColor(.warning)
                                    }
                                    Spacer()
                                } else {
                                    HStack(spacing: Spacing.xs) {
                                        Image(systemName: "info.circle")
                                            .font(.smallCaption)
                                            .foregroundColor(.textTertiary)

                                        Text("Recommended for \(goal.displayName)")
                                            .font(.smallCaption)
                                            .foregroundColor(.textSecondary)
                                    }
                                    Spacer()
                                }
                            }
                        }


                        VStack(spacing: Spacing.sm) {
                            ForEach(Goal.allCases, id: \.self) { goalOption in
                                SelectableCard(
                                    title: goalOption.displayName,
                                    subtitle: goalOption.calorieAdjustmentText,
                                    isSelected: goal == goalOption
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        goal = goalOption
                                        manualCalories = nil
                                        manualCarbsPercent = nil
                                        manualFatsPercent = nil
                                        manualProteinPercent = nil
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        FormSectionHeader(title: "Activity Level")

                        VStack(spacing: Spacing.sm) {
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

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        FormSectionHeader(title: "Units")

                        HStack(spacing: Spacing.sm) {
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

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        FormSectionHeader(title: "Sex")

                        HStack(spacing: Spacing.sm) {
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

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        FormSectionHeader(title: "Age")

                        FormPickerButton(label: "\(age) years") {
                            HapticManager.shared.light()
                            showAgePicker.toggle()
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        FormSectionHeader(title: "Height")

                        FormPickerButton(
                            label: unitsPreference == .metric ? "\(heightCm) cm" : "\(heightFeet)' \(heightInches)\""
                        ) {
                            HapticManager.shared.light()
                            showHeightPicker.toggle()
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        FormSectionHeader(title: "Weight")

                        FormPickerButton(
                            label: unitsPreference == .metric ? String(format: "%.1f kg", weightKg) : "\(Int(weightLbs)) lbs"
                        ) {
                            HapticManager.shared.light()
                            showWeightPicker.toggle()
                        }
                    }

                    MultiSelectPillGrid(
                        title: "Dietary Preferences",
                        selectedItems: $selectedDietaryPreferences,
                        items: DietaryOptions.dietaryPreferences
                    )

                    MultiSelectPillGrid(
                        title: "Allergies",
                        selectedItems: $selectedAllergies,
                        items: DietaryOptions.commonAllergies
                    )
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showCaloriePicker) {
            PickerSheet(
                title: "Select Calorie Goal",
                selection: Binding(
                    get: { manualCalories ?? calculateTargetCalories() },
                    set: { newValue in
                        manualCalories = newValue
                    }
                ),
                range: 1000...5000,
                suffix: " calories",
                isPresented: $showCaloriePicker
            )
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
                    selection: Binding(
                        get: { heightCm },
                        set: { newValue in
                            heightCm = newValue
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
                            heightCm = feetAndInchesToCm(feet: newFeet, inches: heightInches)
                        }
                    ),
                    inches: Binding(
                        get: { heightInches },
                        set: { newInches in
                            heightInches = newInches
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
                            weightKg = Double(newValue).lbsToKg
                        }
                    ),
                    range: 40...600,
                    suffix: " lbs",
                    isPresented: $showWeightPicker
                )
            }
        }
        .sheet(isPresented: $showMacroPicker) {
            if let macro = editingMacro {
                PickerSheet(
                    title: "Select \(macro.displayName) %",
                    selection: Binding(
                        get: {
                            switch macro {
                            case .carbs: return manualCarbsPercent ?? calculateMacroPercentages().carbs
                            case .fats: return manualFatsPercent ?? calculateMacroPercentages().fats
                            case .protein: return manualProteinPercent ?? calculateMacroPercentages().protein
                            }
                        },
                        set: { newValue in
                            switch macro {
                            case .carbs: manualCarbsPercent = newValue
                            case .fats: manualFatsPercent = newValue
                            case .protein: manualProteinPercent = newValue
                            }
                        }
                    ),
                    range: 10...70,
                    suffix: "%",
                    isPresented: $showMacroPicker
                )
            }
        }
        .onAppear {
            loadProfileData()
            saveAction = {
                await self.saveProfile()
            }
        }
    }

    private func loadProfileData() {
        guard let profile = userManager.profile else { return }

        unitsPreference = profile.unitsPreference
        sex = profile.sex
        age = profile.age
        heightCm = profile.heightCm
        weightKg = profile.weightKg
        activityLevel = profile.activityLevel
        goal = profile.goal
        selectedDietaryPreferences = Set(profile.dietaryPreferences ?? [])
        selectedAllergies = Set(profile.allergies ?? [])

        let calculatedCalories = UserManager.calculateTargetCalories(
            sex: profile.sex,
            age: profile.age,
            heightCm: profile.heightCm,
            weightKg: profile.weightKg,
            activityLevel: profile.activityLevel,
            goal: profile.goal
        )
        if profile.targetCalories != calculatedCalories {
            manualCalories = profile.targetCalories
        }

        let calculatedMacros = UserManager.calculateMacroPercentages(for: profile.goal)
        if profile.carbsPercent != calculatedMacros.carbs {
            manualCarbsPercent = profile.carbsPercent
        }
        if profile.fatsPercent != calculatedMacros.fats {
            manualFatsPercent = profile.fatsPercent
        }
        if profile.proteinPercent != calculatedMacros.protein {
            manualProteinPercent = profile.proteinPercent
        }

        let (feet, inches) = heightCm.cmToFeetAndInches
        heightFeet = feet
        heightInches = inches
        weightLbs = weightKg.kgToLbs
    }

    private func syncUnits() {
        if unitsPreference == .imperial {
            let (feet, inches) = heightCm.cmToFeetAndInches
            heightFeet = feet
            heightInches = inches
            weightLbs = weightKg.kgToLbs
        } else {
            heightCm = feetAndInchesToCm(feet: heightFeet, inches: heightInches)
            weightKg = weightLbs.lbsToKg
        }
    }

    private func calculateTargetCalories() -> Int {
        UserManager.calculateTargetCalories(
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal
        )
    }

    private func calculateMacroPercentages() -> (carbs: Int, fats: Int, protein: Int) {
        UserManager.calculateMacroPercentages(for: goal)
    }

    func saveProfile() async {
        isSaving = true

        guard let userId = userManager.currentUser?.id else {
            isSaving = false
            return
        }

        let updatedProfile = UserProfile(
            userId: userId,
            unitsPreference: unitsPreference,
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            dietaryPreferences: selectedDietaryPreferences.isEmpty ? nil : Array(selectedDietaryPreferences),
            allergies: selectedAllergies.isEmpty ? nil : Array(selectedAllergies),
            goal: goal,
            targetCalories: currentCalories,
            carbsPercent: currentCarbsPercent,
            fatsPercent: currentFatsPercent,
            proteinPercent: currentProteinPercent,
            createdAt: userManager.profile?.createdAt,
            updatedAt: Date(),
            onboardingCompleted: true
        )

        do {
            try await userManager.updateProfile(updatedProfile)
            isSaving = false
            isEditing = false
            showSaveSuccess = true
        } catch {
            print("Failed to save profile: \(error)")
            isSaving = false
        }
    }
}

struct MacroCard: View {
    let title: String
    let percentage: Int
    let color: Color
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(title)
                .font(.smallCaptionMedium)
                .foregroundColor(.textSecondary)

            Text("\(percentage)%")
                .font(.title2)
                .foregroundColor(color)

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title3)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(color.opacity(0.1))
        )
    }
}

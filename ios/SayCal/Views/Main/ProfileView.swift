import SwiftUI
import Auth

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showMacrosAsGrams = false

    var body: some View {
        NavigationStack {
            if let profile = userManager.profile {
                List {
                    InteractiveProfileContent(
                        profile: profile,
                        showMacrosAsGrams: $showMacrosAsGrams
                    )
                    .environmentObject(userManager)

                    Section {
                        Button("Sign Out", role: .destructive) {
                            HapticManager.shared.medium()
                            Task { try? await userManager.signOut() }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("No Profile", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
    }
}

// MARK: - Interactive Content
struct InteractiveProfileContent: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile
    @Binding var showMacrosAsGrams: Bool

    @State private var units: UnitsPreference
    @State private var sex: Sex
    @State private var age: Int
    @State private var heightCm: Int
    @State private var weightKg: Double
    @State private var activity: ActivityLevel
    @State private var goal: Goal
    @State private var dietaryPrefs: Set<String>
    @State private var allergies: Set<String>
    @State private var manualCalories: Int?
    @State private var manualCarbs: Int?
    @State private var manualFat: Int?
    @State private var manualProtein: Int?

    @State private var showCalorieSheet = false
    @State private var showMacroSheet = false
    @State private var showGoalSheet = false
    @State private var showActivitySheet = false
    @State private var showSexSheet = false
    @State private var showAgeSheet = false
    @State private var showUnitsSheet = false
    @State private var showHeightSheet = false
    @State private var showWeightSheet = false
    @State private var showDietarySheet = false
    @State private var showAllergySheet = false

    private var carbsGrams: Int { (calories * carbsPercent) / 400 }
    private var fatGrams: Int { (calories * fatsPercent) / 900 }
    private var proteinGrams: Int { (calories * proteinPercent) / 400 }

    private var calculatedCalories: Int {
        UserManager.calculateTargetCalories(sex: sex, age: age, heightCm: heightCm, weightKg: weightKg, activityLevel: activity, goal: goal)
    }
    private var calories: Int { manualCalories ?? calculatedCalories }
    private var defaultMacros: (carbs: Int, fats: Int, protein: Int) { UserManager.calculateMacroPercentages(for: goal) }

    private var carbsPercent: Int { manualCarbs ?? defaultMacros.carbs }
    private var fatsPercent: Int { manualFat ?? defaultMacros.fats }
    private var proteinPercent: Int { manualProtein ?? defaultMacros.protein }

    init(profile: UserProfile, showMacrosAsGrams: Binding<Bool>) {
        self.profile = profile
        self._showMacrosAsGrams = showMacrosAsGrams

        _units = State(initialValue: profile.unitsPreference)
        _sex = State(initialValue: profile.sex)
        _age = State(initialValue: profile.age)
        _heightCm = State(initialValue: profile.heightCm)
        _weightKg = State(initialValue: profile.weightKg)
        _activity = State(initialValue: profile.activityLevel)
        _goal = State(initialValue: profile.goal)
        _dietaryPrefs = State(initialValue: Set(profile.dietaryPreferences ?? []))
        _allergies = State(initialValue: Set(profile.allergies ?? []))

        let calculated = UserManager.calculateTargetCalories(sex: profile.sex, age: profile.age, heightCm: profile.heightCm, weightKg: profile.weightKg, activityLevel: profile.activityLevel, goal: profile.goal)
        _manualCalories = State(initialValue: profile.targetCalories != calculated ? profile.targetCalories : nil)

        let defaultMacros = UserManager.calculateMacroPercentages(for: profile.goal)
        _manualCarbs = State(initialValue: profile.carbsPercent != defaultMacros.carbs ? profile.carbsPercent : nil)
        _manualFat = State(initialValue: profile.fatsPercent != defaultMacros.fats ? profile.fatsPercent : nil)
        _manualProtein = State(initialValue: profile.proteinPercent != defaultMacros.protein ? profile.proteinPercent : nil)
    }

    var body: some View {
        Section {
            Button {
                HapticManager.shared.light()
                showCalorieSheet = true
            } label: {
                HStack {
                    Text("Target Calories")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(calories)")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                HapticManager.shared.light()
                showMacroSheet = true
            } label: {
                HStack {
                    Text("Macros")
                        .foregroundStyle(.primary)
                    Spacer()
                    if showMacrosAsGrams {
                        Text("\(carbsGrams)g • \(fatGrams)g • \(proteinGrams)g")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(carbsPercent)% • \(fatsPercent)% • \(proteinPercent)%")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                HapticManager.shared.light()
                showGoalSheet = true
            } label: {
                HStack {
                    Text("Goal")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(goal.displayName)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                HapticManager.shared.light()
                showActivitySheet = true
            } label: {
                HStack {
                    Text("Activity")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(activity.displayName)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Goals", systemImage: "flag.checkered")
        }
        .listRowBackground(Color.clear)

        Section {
            Button {
                HapticManager.shared.light()
                showSexSheet = true
            } label: {
                HStack {
                    Text("Sex")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(sex.displayName)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                HapticManager.shared.light()
                showAgeSheet = true
            } label: {
                HStack {
                    Text("Age")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(age) years")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                HapticManager.shared.light()
                showUnitsSheet = true
            } label: {
                HStack {
                    Text("Units")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(units.displayName)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Basic Info", systemImage: "person.text.rectangle.fill")
        }
        .listRowBackground(Color.clear)

        Section {
            Button {
                HapticManager.shared.light()
                showHeightSheet = true
            } label: {
                HStack {
                    Text("Height")
                        .foregroundStyle(.primary)
                    Spacer()
                    if units == .imperial {
                        let (ft, inch) = heightCm.cmToFeetAndInches
                        Text("\(ft)' \(inch)\"")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(heightCm) cm")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                HapticManager.shared.light()
                showWeightSheet = true
            } label: {
                HStack {
                    Text("Weight")
                        .foregroundStyle(.primary)
                    Spacer()
                    if units == .imperial {
                        Text(String(format: "%.1f lbs", weightKg.kgToLbs))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(format: "%.1f kg", weightKg))
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Physical Stats", systemImage: "scalemass.fill")
        }
        .listRowBackground(Color.clear)

        Section {
            Button {
                HapticManager.shared.light()
                showDietarySheet = true
            } label: {
                HStack {
                    Text(dietaryPrefs.isEmpty ? "None" : dietaryPrefs.sorted().map { $0.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "))
                        .foregroundStyle(dietaryPrefs.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Dietary Preferences", systemImage: "leaf.fill")
        }
        .listRowBackground(Color.clear)

        Section {
            Button {
                HapticManager.shared.light()
                showAllergySheet = true
            } label: {
                HStack {
                    Text(allergies.isEmpty ? "None" : allergies.sorted().map { $0.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "))
                        .foregroundStyle(allergies.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Allergies", systemImage: "allergens.fill")
        }
        .listRowBackground(Color.clear)

        // MARK: - Sheets
        .sheet(isPresented: $showCalorieSheet) {
            CalorieSheet(
                calories: Binding(
                    get: { calories },
                    set: { manualCalories = $0 == calculatedCalories ? nil : $0 }
                ),
                calculated: calculatedCalories,
                onReset: { manualCalories = nil },
                onSave: { saveProfile() }
            )
            .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $showMacroSheet) {
            MacroSheet(
                carbs: Binding(get: { carbsPercent }, set: { manualCarbs = $0 }),
                fat: Binding(get: { fatsPercent }, set: { manualFat = $0 }),
                protein: Binding(get: { proteinPercent }, set: { manualProtein = $0 }),
                defaults: defaultMacros,
                calories: calories,
                showAsGrams: $showMacrosAsGrams,
                onReset: {
                    manualCarbs = nil
                    manualFat = nil
                    manualProtein = nil
                },
                onSave: { saveProfile() }
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showGoalSheet) {
            GoalPickerSheet(
                selection: $goal,
                onSave: { saveProfile() }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showActivitySheet) {
            ActivityPickerSheet(
                selection: $activity,
                onSave: { saveProfile() }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showSexSheet) {
            SexPickerSheet(
                selection: $sex,
                onSave: { saveProfile() }
            )
            .presentationDetents([.height(240)])
        }
        .sheet(isPresented: $showAgeSheet) {
            AgeSheet(age: $age, onSave: { saveProfile() })
                .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $showUnitsSheet) {
            UnitsPickerSheet(
                selection: $units,
                onSave: { saveProfile() }
            )
            .presentationDetents([.height(240)])
        }
        .sheet(isPresented: $showHeightSheet) {
            HeightSheet(heightCm: $heightCm, units: units, onSave: { saveProfile() })
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showWeightSheet) {
            WeightSheet(weightKg: $weightKg, units: units, onSave: { saveProfile() })
                .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $showDietarySheet) {
            DietaryPreferenceSheet(selectedPreferences: $dietaryPrefs, onSave: { saveProfile() })
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showAllergySheet) {
            AllergySheet(selectedAllergies: $allergies, onSave: { saveProfile() })
                .presentationDetents([.large])
        }
    }

    private func saveProfile() {
        Task {
            do {
                let updatedProfile = UserProfile(
                    userId: profile.userId,
                    unitsPreference: units,
                    sex: sex,
                    age: age,
                    heightCm: heightCm,
                    weightKg: weightKg,
                    activityLevel: activity,
                    dietaryPreferences: Array(dietaryPrefs),
                    allergies: Array(allergies),
                    goal: goal,
                    targetCalories: calories,
                    carbsPercent: carbsPercent,
                    fatsPercent: fatsPercent,
                    proteinPercent: proteinPercent,
                    createdAt: profile.createdAt,
                    updatedAt: profile.updatedAt,
                    onboardingCompleted: profile.onboardingCompleted
                )
                try await userManager.updateProfile(updatedProfile)
            } catch {
                print("Failed to save profile: \(error)")
            }
        }
    }
}

// MARK: - Goal Picker Sheet
struct GoalPickerSheet: View {
    @Binding var selection: Goal
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Goal", selection: $selection) {
                    ForEach(Goal.allCases, id: \.self) { goal in
                        Text(goal.displayName).tag(goal)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .navigationTitle("Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Activity Picker Sheet
struct ActivityPickerSheet: View {
    @Binding var selection: ActivityLevel
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Activity Level", selection: $selection) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .navigationTitle("Activity Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Sex Picker Sheet
struct SexPickerSheet: View {
    @Binding var selection: Sex
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Sex", selection: $selection) {
                    ForEach([Sex.male, Sex.female], id: \.self) { sex in
                        Text(sex.displayName).tag(sex)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .navigationTitle("Sex")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Units Picker Sheet
struct UnitsPickerSheet: View {
    @Binding var selection: UnitsPreference
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Units", selection: $selection) {
                    ForEach([UnitsPreference.metric, UnitsPreference.imperial], id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .navigationTitle("Units")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Age Sheet
struct AgeSheet: View {
    @Binding var age: Int
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Age", selection: $age) {
                    ForEach(13..<121, id: \.self) { age in
                        Text("\(age) years").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle("Age")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Height Sheet
struct HeightSheet: View {
    @Binding var heightCm: Int
    let units: UnitsPreference
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var heightText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Height", text: $heightText)
                            .keyboardType(.numberPad)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .focused($isTextFieldFocused)
                            .onChange(of: heightText) { _, newValue in
                                if units == .imperial {
                                    // Parse feet and inches (e.g., "5'10" or "5 10")
                                    let cleaned = newValue.replacingOccurrences(of: "'", with: " ")
                                        .replacingOccurrences(of: "\"", with: "")
                                        .components(separatedBy: CharacterSet.decimalDigits.inverted)
                                        .filter { !$0.isEmpty }

                                    if cleaned.count >= 2,
                                       let feet = Int(cleaned[0]),
                                       let inches = Int(cleaned[1]) {
                                        heightCm = feetAndInchesToCm(feet: feet, inches: inches)
                                    } else if cleaned.count == 1, let totalInches = Int(cleaned[0]) {
                                        heightCm = feetAndInchesToCm(feet: 0, inches: totalInches)
                                    }
                                } else {
                                    if let cm = Int(newValue.filter { $0.isNumber }) {
                                        heightCm = cm
                                    }
                                }
                            }
                        Text(units == .imperial ? "(ft' in\")" : "cm")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
            .onAppear {
                if units == .imperial {
                    let (ft, inch) = heightCm.cmToFeetAndInches
                    heightText = "\(ft)'\(inch)\""
                } else {
                    heightText = "\(heightCm)"
                }
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Weight Sheet
struct WeightSheet: View {
    @Binding var weightKg: Double
    let units: UnitsPreference
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if units == .metric {
                        Picker("Weight", selection: $weightKg) {
                            ForEach(Array(stride(from: 30.0, through: 300.0, by: 0.5)), id: \.self) { weight in
                                Text(String(format: "%.1f kg", weight)).tag(weight)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                    } else {
                        Picker("Weight", selection: $weightKg) {
                            ForEach(Array(stride(from: 30.0, through: 300.0, by: 0.5)), id: \.self) { weightKg in
                                let lbs = Int(weightKg.kgToLbs)
                                Text("\(lbs) lbs").tag(weightKg)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Calorie Sheet
struct CalorieSheet: View {
    @Binding var calories: Int
    let calculated: Int
    var onReset: () -> Void
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var calorieText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Main calorie display/input
                    HStack {
                        Spacer()
                        TextField("Calories", text: $calorieText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .focused($isTextFieldFocused)
                            .onChange(of: calorieText) { _, newValue in
                                if let value = Int(newValue.filter { $0.isNumber }) {
                                    calories = max(1000, min(5000, value))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)

                    // Quick adjustment buttons
                    HStack(spacing: 12) {
                        Button {
                            HapticManager.shared.light()
                            calories = max(1000, calories - 50)
                            calorieText = "\(calories)"
                        } label: {
                            Text("-50")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                        }

                        Button {
                            HapticManager.shared.light()
                            calories = max(1000, calories - 10)
                            calorieText = "\(calories)"
                        } label: {
                            Text("-10")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                        }

                        Button {
                            HapticManager.shared.light()
                            calories = min(5000, calories + 10)
                            calorieText = "\(calories)"
                        } label: {
                            Text("+10")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                        }

                        Button {
                            HapticManager.shared.light()
                            calories = min(5000, calories + 50)
                            calorieText = "\(calories)"
                        } label: {
                            Text("+50")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("Based on your stats, we recommend \(calculated) calories per day")
                }
            }
            .navigationTitle("Target Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onReset()
                        calorieText = "\(calculated)"
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
            .onAppear {
                calorieText = "\(calories)"
            }
        }
    }
}

// MARK: - Macro Sheet
struct MacroSheet: View {
    @Binding var carbs: Int
    @Binding var fat: Int
    @Binding var protein: Int
    let defaults: (carbs: Int, fats: Int, protein: Int)
    let calories: Int
    @Binding var showAsGrams: Bool
    var onReset: () -> Void
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var carbsGrams: Int { (calories * carbs) / 400 }
    private var fatGrams: Int { (calories * fat) / 900 }
    private var proteinGrams: Int { (calories * protein) / 400 }
    private var total: Int { carbs + fat + protein }

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Show as Grams", isOn: $showAsGrams.animation())

                Section {
                    HStack {
                        Text("Carbs")
                        Spacer()
                        if showAsGrams {
                            Text("\(carbsGrams)g")
                                .foregroundStyle(.secondary)
                        }
                        Text("\(carbs)%")
                            .foregroundStyle(.primary)
                    }
                    Slider(value: Binding(get: { Double(carbs) }, set: { carbs = Int($0) }), in: 0...100, step: 1)

                    HStack {
                        Text("Fat")
                        Spacer()
                        if showAsGrams {
                            Text("\(fatGrams)g")
                                .foregroundStyle(.secondary)
                        }
                        Text("\(fat)%")
                            .foregroundStyle(.primary)
                    }
                    Slider(value: Binding(get: { Double(fat) }, set: { fat = Int($0) }), in: 0...100, step: 1)

                    HStack {
                        Text("Protein")
                        Spacer()
                        if showAsGrams {
                            Text("\(proteinGrams)g")
                                .foregroundStyle(.secondary)
                        }
                        Text("\(protein)%")
                            .foregroundStyle(.primary)
                    }
                    Slider(value: Binding(get: { Double(protein) }, set: { protein = Int($0) }), in: 0...100, step: 1)
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        if total != 100 {
                            Text("Total must equal 100% (currently \(total)%)")
                                .foregroundStyle(.red)
                        } else {
                            Text("Default for \(defaults.carbs)% carbs, \(defaults.fats)% fat, \(defaults.protein)% protein")
                        }
                        Text("Toggle above to switch between percentages and grams")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .navigationTitle("Macros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onReset()
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .disabled(total != 100)
                }
            }
        }
    }
}

// MARK: - Dietary Preference Sheet
struct DietaryPreferenceSheet: View {
    @Binding var selectedPreferences: Set<String>
    var onSave: () -> Void
    @State private var availableOptions = DietaryOptions.dietaryPreferences
    @State private var customInput = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Add custom preference", text: $customInput)
                        .onSubmit {
                            addCustom()
                        }

                    if !customInput.isEmpty {
                        Button("Add \"\(customInput)\"") {
                            addCustom()
                        }
                    }
                }

                Section {
                    ForEach(availableOptions, id: \.self) { pref in
                        Button {
                            HapticManager.shared.light()
                            if selectedPreferences.contains(pref) {
                                selectedPreferences.remove(pref)
                            } else {
                                selectedPreferences.insert(pref)
                            }
                        } label: {
                            HStack {
                                Text(pref.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedPreferences.contains(pref) {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dietary Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private func addCustom() {
        let trimmed = customInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !availableOptions.contains(where: { $0.lowercased() == trimmed.lowercased() }) else { return }

        HapticManager.shared.light()
        availableOptions.insert(trimmed, at: 0)
        selectedPreferences.insert(trimmed)
        customInput = ""
    }
}

// MARK: - Allergy Sheet
struct AllergySheet: View {
    @Binding var selectedAllergies: Set<String>
    var onSave: () -> Void
    @State private var availableOptions = DietaryOptions.commonAllergies
    @State private var customInput = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Add custom allergy", text: $customInput)
                        .onSubmit {
                            addCustom()
                        }

                    if !customInput.isEmpty {
                        Button("Add \"\(customInput)\"") {
                            addCustom()
                        }
                    }
                }

                Section {
                    ForEach(availableOptions, id: \.self) { allergy in
                        Button {
                            HapticManager.shared.light()
                            if selectedAllergies.contains(allergy) {
                                selectedAllergies.remove(allergy)
                            } else {
                                selectedAllergies.insert(allergy)
                            }
                        } label: {
                            HStack {
                                Text(allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedAllergies.contains(allergy) {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Allergies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private func addCustom() {
        let trimmed = customInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !availableOptions.contains(where: { $0.lowercased() == trimmed.lowercased() }) else { return }

        HapticManager.shared.light()
        availableOptions.insert(trimmed, at: 0)
        selectedAllergies.insert(trimmed)
        customInput = ""
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserManager.shared)
}

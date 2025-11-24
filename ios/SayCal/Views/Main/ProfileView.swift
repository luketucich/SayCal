import SwiftUI
import Auth

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var isEditing = false
    @State private var showMacrosAsGrams = false

    var body: some View {
        NavigationStack {
            if let profile = userManager.profile {
                Form {
                    if isEditing {
                        EditProfileContent(
                            profile: profile,
                            isEditing: $isEditing,
                            showMacrosAsGrams: $showMacrosAsGrams
                        )
                        .environmentObject(userManager)
                    } else {
                        ObserveProfileContent(
                            profile: profile,
                            showMacrosAsGrams: $showMacrosAsGrams
                        )

                        Section {
                            Button("Sign Out", role: .destructive) {
                                HapticManager.shared.medium()
                                Task { try? await userManager.signOut() }
                            }
                        }
                    }
                }
                .navigationTitle(isEditing ? "Edit Profile" : "Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if isEditing {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                HapticManager.shared.light()
                                withAnimation { isEditing = false }
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                HapticManager.shared.medium()
                                // Trigger save from child view
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Edit") {
                                HapticManager.shared.light()
                                withAnimation { isEditing = true }
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("No Profile", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
    }
}

// MARK: - Observe Content
struct ObserveProfileContent: View {
    let profile: UserProfile
    @Binding var showMacrosAsGrams: Bool

    private var carbsGrams: Int { (profile.targetCalories * profile.carbsPercent) / 400 }
    private var fatGrams: Int { (profile.targetCalories * profile.fatsPercent) / 900 }
    private var proteinGrams: Int { (profile.targetCalories * profile.proteinPercent) / 400 }

    var body: some View {
        Section {
            LabeledContent("Target Calories", value: "\(profile.targetCalories)")

            Button {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.2)) { showMacrosAsGrams.toggle() }
            } label: {
                HStack {
                    Text("Macros")
                        .foregroundStyle(.primary)
                    Spacer()
                    if showMacrosAsGrams {
                        Text("\(carbsGrams)g • \(fatGrams)g • \(proteinGrams)g")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(profile.carbsPercent)% • \(profile.fatsPercent)% • \(profile.proteinPercent)%")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            LabeledContent("Goal", value: profile.goal.displayName)
            LabeledContent("Activity", value: profile.activityLevel.displayName)
        } header: {
            Label("Goals", systemImage: "target")
        }

        Section {
            LabeledContent("Sex", value: profile.sex.displayName)
            LabeledContent("Age", value: "\(profile.age) years")
            LabeledContent("Units", value: profile.unitsPreference.displayName)
        } header: {
            Label("Basic Info", systemImage: "person.fill")
        }

        Section {
            if profile.unitsPreference == .imperial {
                let (ft, inch) = profile.heightCm.cmToFeetAndInches
                LabeledContent("Height", value: "\(ft)' \(inch)\"")
                LabeledContent("Weight", value: String(format: "%.1f lbs", profile.weightKg.kgToLbs))
            } else {
                LabeledContent("Height", value: "\(profile.heightCm) cm")
                LabeledContent("Weight", value: String(format: "%.1f kg", profile.weightKg))
            }
        } header: {
            Label("Physical Stats", systemImage: "figure.stand")
        }

        Section {
            if let prefs = profile.dietaryPreferences, !prefs.isEmpty {
                Text(prefs.map { $0.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "))
            } else {
                Text("None").foregroundStyle(.secondary)
            }
        } header: {
            Label("Dietary Preferences", systemImage: "leaf.fill")
        }

        Section {
            if let allergies = profile.allergies, !allergies.isEmpty {
                Text(allergies.map { $0.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "))
            } else {
                Text("None").foregroundStyle(.secondary)
            }
        } header: {
            Label("Allergies", systemImage: "exclamationmark.triangle.fill")
        }
    }
}

// MARK: - Edit Content
struct EditProfileContent: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile
    @Binding var isEditing: Bool
    @Binding var showMacrosAsGrams: Bool

    @State private var units: UnitsPreference = .metric
    @State private var sex: Sex = .male
    @State private var age: Int = 25
    @State private var heightCm: Int = 170
    @State private var weightKg: Double = 70.0
    @State private var weightText: String = ""
    @State private var activity: ActivityLevel = .moderatelyActive
    @State private var goal: Goal = .maintainWeight
    @State private var dietaryPrefs: Set<String> = []
    @State private var allergies: Set<String> = []
    @State private var manualCalories: Int?
    @State private var manualCarbs: Int?
    @State private var manualFat: Int?
    @State private var manualProtein: Int?
    @State private var isSaving = false
    @State private var showCalorieSheet = false
    @State private var showMacroSheet = false
    @State private var showDietarySheet = false
    @State private var showAllergySheet = false

    private var calculatedCalories: Int {
        UserManager.calculateTargetCalories(sex: sex, age: age, heightCm: heightCm, weightKg: weightKg, activityLevel: activity, goal: goal)
    }
    private var calories: Int { manualCalories ?? calculatedCalories }
    private var defaultMacros: (carbs: Int, fats: Int, protein: Int) { UserManager.calculateMacroPercentages(for: goal) }

    private var carbsPercent: Int { manualCarbs ?? defaultMacros.carbs }
    private var fatPercent: Int { manualFat ?? defaultMacros.fats }
    private var proteinPercent: Int { manualProtein ?? defaultMacros.protein }

    private var carbsGrams: Int { (calories * carbsPercent) / 400 }
    private var fatGrams: Int { (calories * fatPercent) / 900 }
    private var proteinGrams: Int { (calories * proteinPercent) / 400 }

    var body: some View {
        Section {
            // Calories row
            Button {
                HapticManager.shared.light()
                showCalorieSheet = true
            } label: {
                HStack {
                    Text("Calories")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(calories)")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            // Macros row
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
                        Text("\(carbsPercent)% • \(fatPercent)% • \(proteinPercent)%")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Picker("Goal", selection: $goal) {
                ForEach(Goal.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }

            Picker("Activity", selection: $activity) {
                ForEach(ActivityLevel.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
        } header: {
            Label("Goals", systemImage: "target")
        }

        Section {
            Picker("Sex", selection: $sex) {
                Text("Male").tag(Sex.male)
                Text("Female").tag(Sex.female)
            }
            .pickerStyle(.segmented)

            Picker("Age", selection: $age) {
                ForEach(13..<121, id: \.self) { Text("\($0) years").tag($0) }
            }

            Picker("Units", selection: $units) {
                Text("Metric").tag(UnitsPreference.metric)
                Text("Imperial").tag(UnitsPreference.imperial)
            }
            .pickerStyle(.segmented)
        } header: {
            Label("Basic Info", systemImage: "person.fill")
        }

        Section {
            if units == .metric {
                Picker("Height", selection: $heightCm) {
                    ForEach(100..<251, id: \.self) { Text("\($0) cm").tag($0) }
                }

                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("Weight", text: $weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: weightText) { _, newValue in
                            if let value = Double(newValue) {
                                weightKg = value
                            }
                        }
                    Text("kg")
                        .foregroundStyle(.secondary)
                }
            } else {
                Picker("Height", selection: $heightCm) {
                    ForEach(100..<251, id: \.self) {
                        let (ft, inch) = $0.cmToFeetAndInches
                        Text("\(ft)' \(inch)\"").tag($0)
                    }
                }

                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("Weight", text: $weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: weightText) { _, newValue in
                            if let lbs = Double(newValue) {
                                weightKg = lbs.lbsToKg
                            }
                        }
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Label("Physical Stats", systemImage: "figure.stand")
        }

        Section {
            if dietaryPrefs.isEmpty {
                Text("None").foregroundStyle(.secondary)
            } else {
                ForEach(Array(dietaryPrefs).sorted(), id: \.self) { pref in
                    HStack {
                        Text(pref.replacingOccurrences(of: "_", with: " ").capitalized)
                        Spacer()
                        Button {
                            HapticManager.shared.light()
                            withAnimation { _ = dietaryPrefs.remove(pref) }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                HapticManager.shared.light()
                showDietarySheet = true
            } label: {
                HStack {
                    Label("Add Preference", systemImage: "plus.circle.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Dietary Preferences", systemImage: "leaf.fill")
        }

        Section {
            if allergies.isEmpty {
                Text("None").foregroundStyle(.secondary)
            } else {
                ForEach(Array(allergies).sorted(), id: \.self) { allergy in
                    HStack {
                        Text(allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                        Spacer()
                        Button {
                            HapticManager.shared.light()
                            withAnimation { _ = allergies.remove(allergy) }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                HapticManager.shared.light()
                showAllergySheet = true
            } label: {
                HStack {
                    Label("Add Allergy", systemImage: "plus.circle.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Allergies", systemImage: "exclamationmark.triangle.fill")
        }
        .onAppear { loadProfile() }
        .sheet(isPresented: $showCalorieSheet) {
            CalorieSheet(
                calories: Binding(
                    get: { calories },
                    set: { manualCalories = $0 == calculatedCalories ? nil : $0 }
                ),
                calculated: calculatedCalories,
                onReset: { manualCalories = nil }
            )
            .presentationDetents([.height(320)])
            .interactiveDismissDisabled(false)
        }
        .sheet(isPresented: $showMacroSheet) {
            MacroSheet(
                carbs: Binding(get: { carbsPercent }, set: { manualCarbs = $0 }),
                fat: Binding(get: { fatPercent }, set: { manualFat = $0 }),
                protein: Binding(get: { proteinPercent }, set: { manualProtein = $0 }),
                defaults: defaultMacros,
                calories: calories,
                showAsGrams: $showMacrosAsGrams,
                onReset: {
                    manualCarbs = nil
                    manualFat = nil
                    manualProtein = nil
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showDietarySheet) {
            DietaryPreferenceSheet(selectedPreferences: $dietaryPrefs)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showAllergySheet) {
            AllergySheet(selectedAllergies: $allergies)
                .presentationDetents([.large])
        }
        .onChange(of: isEditing) { _, newValue in
            if !newValue {
                Task { await save() }
            }
        }
        .onChange(of: units) { oldValue, newValue in
            if oldValue == .metric && newValue == .imperial {
                weightText = String(format: "%.0f", weightKg.kgToLbs)
            } else if oldValue == .imperial && newValue == .metric {
                weightText = String(format: "%.1f", weightKg)
            }
        }
    }

    private func loadProfile() {
        units = profile.unitsPreference
        sex = profile.sex
        age = profile.age
        heightCm = profile.heightCm
        weightKg = profile.weightKg
        weightText = units == .metric ? String(format: "%.1f", weightKg) : String(format: "%.0f", weightKg.kgToLbs)
        activity = profile.activityLevel
        goal = profile.goal
        dietaryPrefs = Set(profile.dietaryPreferences ?? [])
        allergies = Set(profile.allergies ?? [])

        let calculated = UserManager.calculateTargetCalories(sex: sex, age: age, heightCm: heightCm, weightKg: weightKg, activityLevel: activity, goal: goal)
        manualCalories = profile.targetCalories != calculated ? profile.targetCalories : nil

        let defaultMacros = UserManager.calculateMacroPercentages(for: goal)
        manualCarbs = profile.carbsPercent != defaultMacros.carbs ? profile.carbsPercent : nil
        manualFat = profile.fatsPercent != defaultMacros.fats ? profile.fatsPercent : nil
        manualProtein = profile.proteinPercent != defaultMacros.protein ? profile.proteinPercent : nil
    }

    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

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
                fatsPercent: fatPercent,
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

// MARK: - Calorie Sheet
struct CalorieSheet: View {
    @Binding var calories: Int
    let calculated: Int
    var onReset: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("Calories: \(calories)", value: $calories, in: 1000...5000, step: 50)
                } footer: {
                    Text("Based on your stats, we recommend \(calculated) calories per day")
                }
            }
            .navigationTitle("Target Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        onReset()
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
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
                            .foregroundStyle(.blue)
                    }
                    Slider(value: Binding(get: { Double(carbs) }, set: { carbs = Int($0) }), in: 0...100, step: 1)
                        .tint(.blue)

                    HStack {
                        Text("Fat")
                        Spacer()
                        if showAsGrams {
                            Text("\(fatGrams)g")
                                .foregroundStyle(.secondary)
                        }
                        Text("\(fat)%")
                            .foregroundStyle(.orange)
                    }
                    Slider(value: Binding(get: { Double(fat) }, set: { fat = Int($0) }), in: 0...100, step: 1)
                        .tint(.orange)

                    HStack {
                        Text("Protein")
                        Spacer()
                        if showAsGrams {
                            Text("\(proteinGrams)g")
                                .foregroundStyle(.secondary)
                        }
                        Text("\(protein)%")
                            .foregroundStyle(.green)
                    }
                    Slider(value: Binding(get: { Double(protein) }, set: { protein = Int($0) }), in: 0...100, step: 1)
                        .tint(.green)
                } footer: {
                    if total != 100 {
                        Text("Total must equal 100% (currently \(total)%)")
                            .foregroundStyle(.red)
                    } else {
                        Text("Default for \(defaults.carbs)% carbs, \(defaults.fats)% fat, \(defaults.protein)% protein")
                    }
                }
            }
            .navigationTitle("Macros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .disabled(total != 100)
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        onReset()
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Dietary Preference Sheet
struct DietaryPreferenceSheet: View {
    @Binding var selectedPreferences: Set<String>
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
                                        .foregroundStyle(.blue)
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
                                        .foregroundStyle(.blue)
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

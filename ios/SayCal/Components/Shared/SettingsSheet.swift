import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, RawRepresentable {
    case device = "device"
    case dark = "dark"
    case light = "light"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .device: return "Device"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .device: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }

    var accentColor: Color {
        return .accentColor
    }
}

struct SettingsSheet: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .device
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let profile = userManager.profile {
                        // Theme Section
                        VStack(alignment: .leading, spacing: 8) {
                            sectionHeader("Appearance", icon: "paintbrush.fill")

                            HStack(spacing: 12) {
                                ForEach(AppTheme.allCases) { theme in
                                    themeButton(theme)
                                }
                            }
                        }

                        // Profile Content
                        InteractiveSettingsContent(profile: profile)
                            .environmentObject(userManager)

                        // Divider
                        Divider()
                            .padding(.vertical, 8)

                        // Sign Out
                        Button {
                            HapticManager.shared.medium()
                            showSignOutConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.red.opacity(0.2), lineWidth: 0.5)
                            )
                        }
                        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                            Button("Sign Out", role: .destructive) {
                                Task { try? await userManager.signOut() }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)

                            Text("No profile found")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 4)
    }

    private func themeButton(_ theme: AppTheme) -> some View {
        Button {
            HapticManager.shared.light()
            selectedTheme = theme
        } label: {
            VStack(spacing: 6) {
                Image(systemName: theme == selectedTheme ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(theme == selectedTheme ? .blue : .secondary)

                Text(theme.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        theme == selectedTheme ? Color.blue.opacity(0.3) : Color.primary.opacity(0.08),
                        lineWidth: theme == selectedTheme ? 1.5 : 0.5
                    )
            )
        }
    }
}

// MARK: - Interactive Settings Content
struct InteractiveSettingsContent: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile

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

    init(profile: UserProfile) {
        self.profile = profile

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
        VStack(spacing: 16) {
            // Goals Section
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Goals", icon: "flag.checkered")

                VStack(spacing: 8) {
                    settingRow("Target Calories", value: "\(calories)") {
                        showCalorieSheet = true
                    }

                    settingRow("Macros", value: "\(carbsPercent)% • \(fatsPercent)% • \(proteinPercent)%") {
                        showMacroSheet = true
                    }

                    settingRow("Goal", value: goal.displayName) {
                        showGoalSheet = true
                    }

                    settingRow("Activity", value: activity.displayName) {
                        showActivitySheet = true
                    }
                }
            }

            // Basic Info Section
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Basic Info", icon: "person.text.rectangle.fill")

                VStack(spacing: 8) {
                    settingRow("Sex", value: sex.displayName) {
                        showSexSheet = true
                    }

                    settingRow("Age", value: "\(age) years") {
                        showAgeSheet = true
                    }

                    settingRow("Units", value: units.displayName) {
                        showUnitsSheet = true
                    }
                }
            }

            // Physical Stats Section
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Physical Stats", icon: "scalemass.fill")

                VStack(spacing: 8) {
                    settingRow("Height", value: {
                        if units == .imperial {
                            let (ft, inch) = heightCm.cmToFeetAndInches
                            return "\(ft)' \(inch)\""
                        } else {
                            return "\(heightCm) cm"
                        }
                    }()) {
                        showHeightSheet = true
                    }

                    settingRow("Weight", value: {
                        if units == .imperial {
                            return String(format: "%.1f lbs", weightKg.kgToLbs)
                        } else {
                            return String(format: "%.1f kg", weightKg)
                        }
                    }()) {
                        showWeightSheet = true
                    }
                }
            }

            // Dietary Preferences Section
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Dietary Preferences", icon: "leaf.fill")

                settingRow("Preferences", value: dietaryPrefs.isEmpty ? "None" : dietaryPrefs.sorted().map { $0.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "), valueColor: dietaryPrefs.isEmpty ? .secondary : .primary) {
                    showDietarySheet = true
                }
            }

            // Allergies Section
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Allergies", icon: "allergens.fill")

                settingRow("Allergies", value: allergies.isEmpty ? "None" : allergies.sorted().map { $0.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", "), valueColor: allergies.isEmpty ? .secondary : .primary) {
                    showAllergySheet = true
                }
            }
        }
        // MARK: - Simplified Picker Sheets
        .sheet(isPresented: $showCalorieSheet) {
            CaloriePickerSheet(
                calories: Binding(
                    get: { calories },
                    set: { manualCalories = $0 == calculatedCalories ? nil : $0 }
                ),
                calculated: calculatedCalories,
                onReset: { manualCalories = nil },
                onSave: { saveProfile() }
            )
        }
        .sheet(isPresented: $showMacroSheet) {
            MacroPickerSheet(
                carbs: Binding(get: { carbsPercent }, set: { manualCarbs = $0 }),
                fat: Binding(get: { fatsPercent }, set: { manualFat = $0 }),
                protein: Binding(get: { proteinPercent }, set: { manualProtein = $0 }),
                defaults: defaultMacros,
                onReset: {
                    manualCarbs = nil
                    manualFat = nil
                    manualProtein = nil
                },
                onSave: { saveProfile() }
            )
        }
        .sheet(isPresented: $showGoalSheet) {
            GoalPickerSheet(selection: $goal, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showActivitySheet) {
            ActivityLevelPickerSheet(selection: $activity, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showSexSheet) {
            SexPickerSheet(selection: $sex, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showAgeSheet) {
            AgePickerSheet(age: $age, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showUnitsSheet) {
            UnitsPickerSheet(selection: $units, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showHeightSheet) {
            HeightPickerSheet(heightCm: $heightCm, units: units, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showWeightSheet) {
            WeightPickerSheet(weightKg: $weightKg, units: units, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showDietarySheet) {
            DietaryPreferencesPickerSheet(selectedPreferences: $dietaryPrefs, onSave: { saveProfile() })
        }
        .sheet(isPresented: $showAllergySheet) {
            AllergiesPickerSheet(selectedAllergies: $allergies, onSave: { saveProfile() })
        }
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 4)
    }

    private func settingRow(_ label: String, value: String, valueColor: Color = .secondary, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)

                Spacer()

                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
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
                    tier: profile.tier,
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

#Preview {
    SettingsSheet()
        .environmentObject(UserManager.shared)
}

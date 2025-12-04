import SwiftUI

// MARK: - Goal Picker
struct GoalPickerContent: View {
    @Binding var selection: Goal

    var body: some View {
        VStack(spacing: 0) {
            Picker("Goal", selection: $selection) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    Text(goal.displayName).tag(goal)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

struct GoalPickerSheet: View {
    @Binding var selection: Goal
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Goal")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                GoalPickerContent(selection: $selection)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Activity Level Picker
struct ActivityLevelPickerContent: View {
    @Binding var selection: ActivityLevel

    var body: some View {
        VStack(spacing: 0) {
            Picker("Activity Level", selection: $selection) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Text(level.displayName).tag(level)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

struct ActivityLevelPickerSheet: View {
    @Binding var selection: ActivityLevel
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Activity Level")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                ActivityLevelPickerContent(selection: $selection)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Activity Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Sex Picker
struct SexPickerContent: View {
    @Binding var selection: Sex

    var body: some View {
        VStack(spacing: 0) {
            Picker("Sex", selection: $selection) {
                ForEach([Sex.male, Sex.female], id: \.self) { sex in
                    Text(sex.displayName).tag(sex)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

struct SexPickerSheet: View {
    @Binding var selection: Sex
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Sex")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                SexPickerContent(selection: $selection)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Sex")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(260)])
    }
}

// MARK: - Age Picker
struct AgePickerContent: View {
    @Binding var age: Int

    var body: some View {
        VStack(spacing: 0) {
            Picker("Age", selection: $age) {
                ForEach(13..<121, id: \.self) { age in
                    Text("\(age) years").tag(age)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

struct AgePickerSheet: View {
    @Binding var age: Int
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Age")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                AgePickerContent(age: $age)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Age")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Units Picker
struct UnitsPickerContent: View {
    @Binding var selection: UnitsPreference

    var body: some View {
        VStack(spacing: 0) {
            Picker("Units", selection: $selection) {
                ForEach([UnitsPreference.metric, UnitsPreference.imperial], id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

struct UnitsPickerSheet: View {
    @Binding var selection: UnitsPreference
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Units")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                UnitsPickerContent(selection: $selection)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Units")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(260)])
    }
}

// MARK: - Height Picker
struct HeightPickerContent: View {
    @Binding var heightCm: Int
    let units: UnitsPreference
    @State private var feet: Int
    @State private var inches: Int

    init(heightCm: Binding<Int>, units: UnitsPreference) {
        self._heightCm = heightCm
        self.units = units

        let (ft, inch) = heightCm.wrappedValue.cmToFeetAndInches
        self._feet = State(initialValue: ft)
        self._inches = State(initialValue: inch)
    }

    var body: some View {
        VStack(spacing: 0) {
            if units == .imperial {
                HStack(spacing: 0) {
                    Picker("Feet", selection: $feet) {
                        ForEach(4..<9, id: \.self) { ft in
                            Text("\(ft) ft").tag(ft)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: feet) { _, _ in
                        heightCm = feetAndInchesToCm(feet: feet, inches: inches)
                    }

                    Picker("Inches", selection: $inches) {
                        ForEach(0..<12, id: \.self) { inch in
                            Text("\(inch) in").tag(inch)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: inches) { _, _ in
                        heightCm = feetAndInchesToCm(feet: feet, inches: inches)
                    }
                }
            } else {
                Picker("Height", selection: $heightCm) {
                    ForEach(120..<230, id: \.self) { cm in
                        Text("\(cm) cm").tag(cm)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
        }
        .onChange(of: heightCm) { _, newValue in
            let (ft, inch) = newValue.cmToFeetAndInches
            feet = ft
            inches = inch
        }
    }
}

struct HeightPickerSheet: View {
    @Binding var heightCm: Int
    let units: UnitsPreference
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Height")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                HeightPickerContent(heightCm: $heightCm, units: units)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Weight Picker
struct WeightPickerContent: View {
    @Binding var weightKg: Double
    let units: UnitsPreference

    var body: some View {
        VStack(spacing: 0) {
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
}

struct WeightPickerSheet: View {
    @Binding var weightKg: Double
    let units: UnitsPreference
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Weight")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                WeightPickerContent(weightKg: $weightKg, units: units)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Calorie Picker
struct CaloriePickerContent: View {
    @Binding var calories: Int

    var body: some View {
        VStack(spacing: 0) {
            Picker("Calories", selection: $calories) {
                ForEach(Array(stride(from: 1000, through: 5000, by: 50)), id: \.self) { cal in
                    Text("\(cal)").tag(cal)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

struct CaloriePickerSheet: View {
    @Binding var calories: Int
    let calculated: Int
    var onReset: () -> Void
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Target Calories")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                CaloriePickerContent(calories: $calories)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Text("Recommended: \(calculated) cal/day")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Target Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        HapticManager.shared.light()
                        onReset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(340)])
    }
}

// MARK: - Macro Picker
struct MacroPickerContent: View {
    @Binding var carbs: Int
    @Binding var fat: Int
    @Binding var protein: Int

    private var total: Int { carbs + fat + protein }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                VStack(spacing: 4) {
                    Text("Carbs")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Picker("Carbs", selection: $carbs) {
                        ForEach(0...100, id: \.self) { val in
                            Text("\(val)%").tag(val)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }

                VStack(spacing: 4) {
                    Text("Fat")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Picker("Fat", selection: $fat) {
                        ForEach(0...100, id: \.self) { val in
                            Text("\(val)%").tag(val)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }

                VStack(spacing: 4) {
                    Text("Protein")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Picker("Protein", selection: $protein) {
                        ForEach(0...100, id: \.self) { val in
                            Text("\(val)%").tag(val)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }
            }

            if total != 100 {
                Text("Total must equal 100% (currently \(total)%)")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.red)
            }
        }
    }
}

struct MacroPickerSheet: View {
    @Binding var carbs: Int
    @Binding var fat: Int
    @Binding var protein: Int
    let defaults: (carbs: Int, fats: Int, protein: Int)
    var onReset: () -> Void
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var total: Int { carbs + fat + protein }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Macros")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                MacroPickerContent(carbs: $carbs, fat: $fat, protein: $protein)
                    .padding(16)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                    .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("Macros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        HapticManager.shared.light()
                        onReset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .disabled(total != 100)
                }
            }
        }
        .presentationDetents([.height(380)])
    }
}

// MARK: - Dietary Preferences Picker
struct DietaryPreferencesPickerContent: View {
    @Binding var selectedPreferences: Set<String>
    @State private var availableOptions = DietaryOptions.dietaryPreferences

    var body: some View {
        VStack(spacing: 8) {
            ForEach(availableOptions.sorted(), id: \.self) { pref in
                Button {
                    HapticManager.shared.light()
                    if selectedPreferences.contains(pref) {
                        selectedPreferences.remove(pref)
                    } else {
                        selectedPreferences.insert(pref)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedPreferences.contains(pref) ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(selectedPreferences.contains(pref) ? .primary : .secondary)

                        Text(pref.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(12)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 8))
        .cardShadow()
                }
            }
        }
    }
}

struct DietaryPreferencesPickerSheet: View {
    @Binding var selectedPreferences: Set<String>
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Dietary Preferences")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)

                ScrollView {
                    DietaryPreferencesPickerContent(selectedPreferences: $selectedPreferences)
                        .padding(16)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Dietary Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(500)])
    }
}

// MARK: - Allergies Picker
struct AllergiesPickerContent: View {
    @Binding var selectedAllergies: Set<String>
    @State private var availableOptions = DietaryOptions.commonAllergies

    var body: some View {
        VStack(spacing: 8) {
            ForEach(availableOptions.sorted(), id: \.self) { allergy in
                Button {
                    HapticManager.shared.light()
                    if selectedAllergies.contains(allergy) {
                        selectedAllergies.remove(allergy)
                    } else {
                        selectedAllergies.insert(allergy)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedAllergies.contains(allergy) ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(selectedAllergies.contains(allergy) ? .primary : .secondary)

                        Text(allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(12)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 8))
        .cardShadow()
                }
            }
        }
    }
}

struct AllergiesPickerSheet: View {
    @Binding var selectedAllergies: Set<String>
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Allergies")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)

                ScrollView {
                    AllergiesPickerContent(selectedAllergies: $selectedAllergies)
                        .padding(16)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Allergies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.medium()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
        .presentationDetents([.height(500)])
    }
}

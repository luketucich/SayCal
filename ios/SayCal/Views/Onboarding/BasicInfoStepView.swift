import SwiftUI

struct BasicInfoStepView: View {
    @Binding var age: String
    @Binding var heightCm: String
    @Binding var weightKg: String
    @Binding var sex: Sex?
    @Binding var unitsPreference: UnitsPreference

    @FocusState private var focusedField: Field?

    private enum Field {
        case age, height, weight
    }

    var isValid: Bool {
        guard let ageInt = Int(age), ageInt >= 13 && ageInt <= 120 else { return false }

        if unitsPreference == .metric {
            guard let height = Double(heightCm), height >= 100 && height <= 250 else { return false }
            guard let weight = Double(weightKg), weight >= 30 && weight <= 300 else { return false }
        } else {
            // For imperial, convert from display values
            guard let heightInches = Double(heightCm), heightInches >= 48 && heightInches <= 96 else { return false }
            guard let weightLbs = Double(weightKg), weightLbs >= 66 && weightLbs <= 660 else { return false }
        }

        return sex != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Let's get to know you")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("This information helps us personalize your experience and calculate accurate calorie targets.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Units Preference
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preferred Units")
                        .font(.headline)

                    Picker("Units", selection: $unitsPreference) {
                        Text("Metric (kg, cm)").tag(UnitsPreference.metric)
                        Text("Imperial (lbs, in)").tag(UnitsPreference.imperial)
                    }
                    .pickerStyle(.segmented)
                }

                // Age
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.headline)

                    TextField("Enter your age", text: $age)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .age)
                }

                // Sex
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sex")
                        .font(.headline)

                    Text("Used for accurate calorie calculations")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        SexButton(
                            title: "Male",
                            icon: "figure.stand",
                            isSelected: sex == .male,
                            action: { sex = .male }
                        )

                        SexButton(
                            title: "Female",
                            icon: "figure.stand.dress",
                            isSelected: sex == .female,
                            action: { sex = .female }
                        )
                    }
                }

                // Height
                VStack(alignment: .leading, spacing: 8) {
                    Text("Height")
                        .font(.headline)

                    HStack {
                        TextField(
                            unitsPreference == .metric ? "cm" : "inches",
                            text: $heightCm
                        )
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .height)

                        Text(unitsPreference == .metric ? "cm" : "in")
                            .foregroundColor(.secondary)
                    }

                    if unitsPreference == .imperial, let inches = Double(heightCm) {
                        let feet = Int(inches / 12)
                        let remainingInches = Int(inches.truncatingRemainder(dividingBy: 12))
                        Text("\(feet)' \(remainingInches)\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.headline)

                    HStack {
                        TextField(
                            unitsPreference == .metric ? "kg" : "lbs",
                            text: $weightKg
                        )
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .weight)

                        Text(unitsPreference == .metric ? "kg" : "lbs")
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}

struct SexButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : .accentColor)

                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack {
        BasicInfoStepView(
            age: .constant("25"),
            heightCm: .constant("175"),
            weightKg: .constant("70"),
            sex: .constant(.male),
            unitsPreference: .constant(.metric)
        )
    }
}

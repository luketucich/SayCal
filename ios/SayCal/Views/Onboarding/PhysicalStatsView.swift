import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your physical stats")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("We'll use this to calculate your caloric needs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sex")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)

                        SexPickerContent(selection: $state.sex)
                            .padding(16)
                            .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                            .onChange(of: state.sex) { _, _ in
                                HapticManager.shared.light()
                            }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)

                        AgePickerContent(age: $state.age)
                            .padding(16)
                            .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                            .onChange(of: state.age) { _, _ in
                                HapticManager.shared.light()
                            }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)

                        HeightPickerContent(heightCm: $state.heightCm, units: state.unitsPreference)
                            .padding(16)
                            .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                            .onChange(of: state.heightCm) { _, _ in
                                HapticManager.shared.light()
                            }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)

                        WeightPickerContent(weightKg: $state.weightKg, units: state.unitsPreference)
                            .padding(16)
                            .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                            .onChange(of: state.weightKg) { _, _ in
                                HapticManager.shared.light()
                            }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color.appBackground)

            OnboardingFooter(onBack: { state.previousStep() }) {
                state.nextStep()
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhysicalStatsView(state: OnboardingState())
    }
}

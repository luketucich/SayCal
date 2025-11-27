import SwiftUI

struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your units")
                    .font(.system(size: 28, weight: .bold))

                Text("Select your preferred measurement system")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            List {
                Section {
                    Picker("Units", selection: $state.unitsPreference) {
                        Text("Metric (kg, cm)").tag(UnitsPreference.metric)
                        Text("Imperial (lbs, ft)").tag(UnitsPreference.imperial)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .onChange(of: state.unitsPreference) { _, _ in
                        HapticManager.shared.light()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)

            OnboardingFooter(showBack: false) {
                state.nextStep()
            }
        }
    }
}

#Preview {
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}

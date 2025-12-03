import SwiftUI

struct RecipesView: View {
    @Binding var showSettings: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "frying.pan")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)

                    Text("No recipes yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .padding(.top, 68)
            }
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    RecipesView(showSettings: .constant(false))
}

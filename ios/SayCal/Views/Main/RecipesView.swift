import SwiftUI

struct RecipesView: View {
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ContentUnavailableView(
                        "No Recipes Yet",
                        systemImage: "frying.pan",
                        description: Text("Your saved recipes will appear here")
                    )
                    .padding(.top, 100)
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    RecipesView(showSettings: .constant(false))
}

import SwiftUI

struct SearchBarEvents: View {
    @Binding var searchText: String
    @Binding var searchRadius: Double
    @Binding var selectedCategories: Set<String>
    let onApply: () -> Void
    let availableCategories: [(key: String, label: String, icon: String, color: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Rayon de recherche
            VStack(alignment: .leading) {
                Text("Rayon de recherche :")
                    .font(.headline)

                HStack {
                    Slider(value: $searchRadius, in: 1...100, step: 1)
                    Text("\(Int(searchRadius)) km")
                        .frame(width: 50, alignment: .trailing)
                }
            }

            // Filtres par catégories
            VStack(alignment: .leading) {
                Text("Catégories :")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(availableCategories, id: \.key) { category in
                            Button(action: {
                                if selectedCategories.contains(category.key) {
                                    selectedCategories.remove(category.key)
                                } else {
                                    selectedCategories.insert(category.key)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                    Text(category.label)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedCategories.contains(category.key) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // Bouton Appliquer
            Button("Appliquer les filtres") {
                onApply()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding(.horizontal)
    }
}

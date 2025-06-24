import SwiftUI

struct SearchBarEvents: View {
    @Binding var searchText: String
    @Binding var searchRadius: Double
    @Binding var selectedCategories: Set<String>
    @Binding var isSearchExpanded: Bool
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

            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 2) {
                    Text("Catégories :")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(availableCategories.filter { selectedCategories.contains($0.key) }, id: \.key) { category in
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)

                                    Button(action: {
                                        selectedCategories.remove(category.key)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: category.color).opacity(0.7))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }

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
                                        .foregroundColor(
                                            selectedCategories.contains(category.key) ? Color.gray.opacity(0.6) : Color(hex: category.color)
                                        )
                                    
                                    Text(category.label)
                                        .foregroundColor(
                                            selectedCategories.contains(category.key) ? Color.gray.opacity(0.6) : Color(hex: category.color)
                                        )
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    selectedCategories.contains(category.key)
                                        ? Color.gray.opacity(0.1)
                                        : Color(hex: category.color).opacity(0.25)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            }
                        }
                    }
                }
            }

            // Bouton Appliquer
            Button("Appliquer les filtres") {
                onApply()
                withAnimation {
                    isSearchExpanded = false
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding(.horizontal)
    }
}

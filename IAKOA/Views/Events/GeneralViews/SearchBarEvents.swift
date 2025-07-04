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
            VStack(alignment: .leading) {
                Text("Rayon de recherche :")
                    .font(.headline)

                HStack {
                    Slider(value: $searchRadius, in: 10...100, step: 10)
                    Text("\(Int(searchRadius)) km")
                        .frame(width: 50, alignment: .trailing)
                }
            }

            VStack(alignment: .leading) {
                let columns = [
                    GridItem(.adaptive(minimum: 50), spacing: 8)
                ]

                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
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
                        .frame(width: 42, height: 22)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: category.color).opacity(0.7))
                        .clipShape(Capsule())
                    }
                }


                HStack {
                    DisclosureGroup("Choisir des catégories") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(availableCategories, id: \.key) { category in
                                    Button(action: {
                                        if selectedCategories.contains(category.key) {
                                            selectedCategories.remove(category.key)
                                        } else {
                                            selectedCategories.insert(category.key)
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: category.icon)
                                                .foregroundColor(
                                                    selectedCategories.contains(category.key)
                                                    ? .gray
                                                    : Color(hex: category.color)
                                                )

                                            Text(category.label)
                                                .foregroundColor(
                                                    selectedCategories.contains(category.key)
                                                    ? .gray
                                                    : Color(hex: category.color)
                                                )
                                                .fontWeight(.medium)

                                            if selectedCategories.contains(category.key) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }

                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedCategories.contains(category.key)
                                            ? Color.gray.opacity(0.2)
                                            : Color(hex: category.color).opacity(0.2)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(height: 220)
                    }
                    .font(.headline)
                    .foregroundColor(Color.blueIakoa)
                    .padding(.vertical, 8)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                }
            }
            HStack(spacing: 12) {
                Button("Appliquer les filtres") {
                    onApply()
                    withAnimation {
                        isSearchExpanded = false
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Supprimer les filtres") {
                    searchText = ""
                    searchRadius = 30
                    selectedCategories = []
                    withAnimation {
                        isSearchExpanded = false
                    }
                    onApply()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
            .padding(.top, 4)
            
            Divider()
                .background(Color.gray.opacity(0.3))

        }
        .padding(.horizontal)
    }
}

// SearchBarEvents.swift
import SwiftUI
import CoreLocation

struct City: Identifiable, Hashable {
    let id: String // code INSEE
    let name: String
    let postalCodes: [String]
    let latitude: Double
    let longitude: Double
}

class CitySearchViewModel: ObservableObject {
    @Published var suggestions: [City] = []
    @Published var isLoading = false

    func searchCities(query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        isLoading = true
        let urlString = "https://geo.api.gouv.fr/communes?nom=\(query)&fields=nom,codesPostaux,code,centre&boost=population&limit=10"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                guard let data = data else { return }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    self.suggestions = json.compactMap { dict in
                        guard let code = dict["code"] as? String,
                              let nom = dict["nom"] as? String,
                              let codesPostaux = dict["codesPostaux"] as? [String],
                              let centre = dict["centre"] as? [String: Any],
                              let coordinates = centre["coordinates"] as? [Double],
                              coordinates.count == 2
                        else { return nil }
                        return City(
                            id: code,
                            name: nom,
                            postalCodes: codesPostaux,
                            latitude: coordinates[1],
                            longitude: coordinates[0]
                        )
                    }
                }
            }
        }.resume()
    }
}

struct SearchBarEvents: View {
    @Binding var searchText: String
    @Binding var searchCity: String
    @Binding var searchRadius: Double
    @Binding var selectedCategories: Set<String>
    var onApply: (() -> Void)? = nil
    let availableCategories: [(key: String, label: String, icon: String, color: String)]

    @StateObject private var cityVM = CitySearchViewModel()
    @State private var cityQuery: String = ""
    @State private var selectedCity: City? = nil

    var body: some View {
        VStack(spacing: 12) {
            // Recherche ville
            VStack(alignment: .leading) {
                TextField("Ville ou code postal", text: $cityQuery)
                    .onChange(of: cityQuery) { _, newValue in
                        cityVM.searchCities(query: newValue)
                    }
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                if !cityVM.suggestions.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(cityVM.suggestions) { city in
                                Button(action: {
                                    selectedCity = city
                                    searchCity = city.name
                                    cityQuery = city.name
                                    cityVM.suggestions = []
                                }) {
                                    HStack {
                                        Text(city.name)
                                        Spacer()
                                        Text(city.postalCodes.first ?? "")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                    .frame(maxHeight: 150)
                }
            }

            // Filtres catégories
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(availableCategories, id: \.key) { category in
                        let isSelected = selectedCategories.contains(category.key)
                        Button(action: {
                            if isSelected {
                                selectedCategories.remove(category.key)
                            } else {
                                selectedCategories.insert(category.key)
                            }
                        }) {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(isSelected ? .white : .primary)
                                Text(category.label)
                                    .foregroundColor(isSelected ? .white : .primary)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(isSelected ? Color.blue : Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 300) // limite la hauteur si besoin



            // Rayon
            HStack {
                Text("📍 Rayon : \(Int(searchRadius)) km")
                    .font(.subheadline)
                Slider(value: $searchRadius, in: 5...50, step: 5)
            }

            // Bouton Appliquer
            Button(action: {
                onApply?()
            }) {
                Text("Appliquer les filtres")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

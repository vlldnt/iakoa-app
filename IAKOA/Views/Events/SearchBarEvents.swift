import SwiftUI
import Combine
import CoreLocation

struct SearchBarEvents: View {
    @Binding var searchText: String
    @Binding var searchCity: String
    @Binding var searchRadius: Double
    @Binding var selectedCategories: Set<String>
    let onApply: () -> Void
    let availableCategories: [(key: String, label: String, icon: String, color: String)]
    @Binding var selectedCity: City?

    @State private var citySuggestions: [City] = []
    @State private var cancellable: AnyCancellable?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Rayon :")
                Slider(value: $searchRadius, in: 1...100, step: 1)
                Text("\(Int(searchRadius)) km")
            }

            VStack(alignment: .leading) {
                Text("Ville :")
                TextField("Entrez une ville", text: $searchCity)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchCity) { _, newValue in
                        fetchCitySuggestions(query: newValue)
                    }

                if !citySuggestions.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading) {
                            ForEach(citySuggestions.prefix(4), id: \.self) { city in
                                Button(action: {
                                    searchCity = city.nom
                                    selectedCity = city
                                    citySuggestions = []
                                }) {
                                    HStack {
                                        Text(city.nom)
                                        Spacer()
                                        Text("\(city.codesPostaux.first ?? "")")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding(4)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 100)
                }
            }

            VStack(alignment: .leading) {
                Text("Catégories :")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(availableCategories, id: \.key) { cat in
                            Button(action: {
                                if selectedCategories.contains(cat.key) {
                                    selectedCategories.remove(cat.key)
                                } else {
                                    selectedCategories.insert(cat.key)
                                }
                            }) {
                                HStack {
                                    Image(systemName: cat.icon)
                                    Text(cat.label)
                                }
                                .padding(6)
                                .background(selectedCategories.contains(cat.key) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }

            Button("Appliquer les filtres") {
                onApply()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }

    private func fetchCitySuggestions(query: String) {
        guard query.count >= 2 else {
            citySuggestions = []
            return
        }

        let urlString = "https://geo.api.gouv.fr/communes?nom=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&fields=nom,codesPostaux,centre&boost=population&limit=10"

        guard let url = URL(string: urlString) else { return }

        cancellable?.cancel()
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [City].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { cities in
                self.citySuggestions = Array(cities.prefix(4))
            }
    }
}

// MARK: - Ville
struct City: Codable, Hashable {
    let nom: String
    let codesPostaux: [String]
    let centre: Coordinates

    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centre.coordinates[1], longitude: centre.coordinates[0])
    }
}

struct Coordinates: Codable, Hashable {
    let type: String
    let coordinates: [Double]
}

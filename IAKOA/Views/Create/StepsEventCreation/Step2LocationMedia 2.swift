import SwiftUI
import MapKit

struct Step2LocationMedia: View {
    enum DateMode: String, CaseIterable, Identifiable {
        case single = "Un jour"
        case range = "Plusieurs jours"
        var id: String { rawValue }
    }

    @Binding var eventDate: Date
    @Binding var eventAddress: String
    @Binding var eventPrice: String

    @StateObject private var addressSearch = AddressSearchService()
    @State private var isEditingAddress = false

    @State private var dateMode: DateMode = .single
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()

    var body: some View {
        VStack(spacing: 5) {
            Form {
                Section(header: Text("Date de l'événement")) {
                    Picker("Mode", selection: $dateMode) {
                        ForEach(DateMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                                .font(.system(size: 14))
                            
                        }
                    }
                    .pickerStyle(.segmented)

                    if dateMode == .single {
                        SingleDatePickerView(selectedDate: $eventDate)
                    } else {
                        DateRangeSelector(startDate: $startDate, endDate: $endDate)
                    }
                }

                Section(header: Text("Adresse de l'événement")) {
                    ZStack(alignment: .top) {
                        TextField("Adresse (France uniquement)", text: $eventAddress, onEditingChanged: { editing in
                            isEditingAddress = editing
                        })
                        .onChange(of: eventAddress) { _, newValue in
                            addressSearch.updateSearch(query: newValue)
                        }
                        .font(.system(size: 14))
                        .padding(.trailing, 8)

                        if isEditingAddress && !addressSearch.searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(addressSearch.searchResults, id: \.self) { completion in
                                    AddressSuggestionRow(completion: completion) {
                                        eventAddress = completion.title + (completion.subtitle.isEmpty ? "" : ", \(completion.subtitle)")
                                        isEditingAddress = false
                                        addressSearch.searchResults = []
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.top, 38)
                        }
                    }
                }

                Section(header: Text("Prix de l'événement (€)")) {
                    TextField("Prix (optionnel)", text: $eventPrice)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 14))
                }
            }
        }
    }
}
#Preview {
    Step2LocationMedia(eventDate: .constant(Date()),
                          eventAddress: .constant(""),
                            eventPrice: .constant(""))
}

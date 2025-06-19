import CoreLocation
import MapKit
import Foundation
import SwiftUI

class AddressSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    private var searchCompleter: MKLocalSearchCompleter
    
    override init() {
        searchCompleter = MKLocalSearchCompleter()
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        
        let franceCenter = CLLocationCoordinate2D(latitude: 46.603354, longitude: 1.888334)
        let franceSpan = MKCoordinateSpan(latitudeDelta: 7.0, longitudeDelta: 10.0)
        searchCompleter.region = MKCoordinateRegion(center: franceCenter, span: franceSpan)
    }
    
    func updateSearch(query: String) {
        searchCompleter.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = Array(completer.results.prefix(5))
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Erreur autocomplete adresse: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.searchResults = []
        }
    }
}

struct AddressSuggestionRow: View {
    let completion: MKLocalSearchCompletion
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(completion.title)
                .fontWeight(.medium)
            if !completion.subtitle.isEmpty {
                Text(completion.subtitle)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 60)
        .background(Color.white)
        .onTapGesture { onSelect() }
        Divider()
    }
}

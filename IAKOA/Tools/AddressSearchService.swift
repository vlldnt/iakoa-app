class AddressSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    private var searchCompleter: MKLocalSearchCompleter
    
    override init() {
        searchCompleter = MKLocalSearchCompleter()
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        
        // Région centrée sur la France
        let franceCenter = CLLocationCoordinate2D(latitude: 46.603354, longitude: 1.888334)
        let franceSpan = MKCoordinateSpan(latitudeDelta: 7.0, longitudeDelta: 10.0)
        searchCompleter.region = MKCoordinateRegion(center: franceCenter, span: franceSpan)
    }
    
    func updateSearch(query: String) {
        searchCompleter.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Erreur autocomplete adresse: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.searchResults = []
        }
    }
}
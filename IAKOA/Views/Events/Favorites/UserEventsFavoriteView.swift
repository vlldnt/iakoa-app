import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserEventsFavoriteView: View {
    @State private var favoriteEvents: [Event] = []
    @State private var isLoading = true
    
    var body: some View {
        Text("Évènements favoris")
        
    }
}

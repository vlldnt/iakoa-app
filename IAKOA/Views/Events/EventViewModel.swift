
import Foundation
import FirebaseFirestore

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []

    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
            if let error = error {
                print("Erreur de récupération : \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            DispatchQueue.main.async {
                self.events = documents.compactMap { Event(document: $0) }
            }
        }
    }
}

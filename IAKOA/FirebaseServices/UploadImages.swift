import UIKit
import FirebaseStorage

func uploadImages(_ images: [UIImage], completion: @escaping ([String]) -> Void) {
    var links: [String] = []
    let dispatchGroup = DispatchGroup()

    for image in images {
        dispatchGroup.enter()

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            dispatchGroup.leave()
            continue
        }
        let storageRef = Storage.storage().reference().child("event_images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Erreur upload image : \(error.localizedDescription)")
                dispatchGroup.leave()
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    links.append(url.absoluteString)
                }
                dispatchGroup.leave()
            }
        }
    }

    dispatchGroup.notify(queue: .main) {
        completion(links)
    }
}

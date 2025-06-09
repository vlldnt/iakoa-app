import UIKit
import FirebaseStorage

func resizeAndCompressImage(_ image: UIImage, maxDimension: CGFloat = 1024, compressionQuality: CGFloat = 0.4) -> Data? {
    let size = image.size
    let aspectRatio = size.width / size.height
    
    var newSize: CGSize
    
    if size.width > size.height {
        // Paysage : largeur = maxDimension, hauteur ajustée
        newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
    } else {
        // Portrait ou carré : hauteur = maxDimension, largeur ajustée
        newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage?.jpegData(compressionQuality: compressionQuality)
}

func uploadImages(_ images: [UIImage], completion: @escaping ([String]) -> Void) {
    var links: [String] = []
    let dispatchGroup = DispatchGroup()

    for image in images {
        dispatchGroup.enter()

        guard let imageData = resizeAndCompressImage(image) else {
            print("Erreur lors du redimensionnement ou compression de l'image")
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

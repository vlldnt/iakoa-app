import UIKit
import FirebaseStorage
import SDWebImage
import SDWebImageWebPCoder

/// Convertit une UIImage en WebP compressé
func convertToWebP(_ image: UIImage, quality: CGFloat = 0.2) -> Data? {
    let options: [SDImageCoderOption: Any] = [
        .encodeCompressionQuality: quality
    ]
    return SDImageWebPCoder.shared.encodedData(with: image, format: .webP, options: options)
}

/// Redimensionne une image avant conversion
func resizeImage(_ image: UIImage, maxDimension: CGFloat = 640) -> UIImage {
    let size = image.size
    let aspectRatio = size.width / size.height

    let newSize: CGSize = size.width > size.height ?
        CGSize(width: maxDimension, height: maxDimension / aspectRatio) :
        CGSize(width: maxDimension * aspectRatio, height: maxDimension)

    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}

/// Upload une liste d'images compressées en WebP vers Firebase Storage
func uploadImages(_ images: [UIImage], completion: @escaping ([String]) -> Void) {
    var links: [String] = []
    let dispatchGroup = DispatchGroup()

    for image in images {
        dispatchGroup.enter()

        let resized = resizeImage(image)
        guard let imageData = convertToWebP(resized) else {
            dispatchGroup.leave()
            continue
        }

        let fileName = UUID().uuidString + ".webp"
        let storageRef = Storage.storage().reference().child("event_images/\(fileName)")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Erreur d'upload : \(error.localizedDescription)")
                dispatchGroup.leave()
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    links.append(url.absoluteString)
                } else {
                    print("Erreur URL : \(error?.localizedDescription ?? "inconnue")")
                }
                dispatchGroup.leave()
            }
        }
    }

    dispatchGroup.notify(queue: .main) {
        completion(links)
    }
}

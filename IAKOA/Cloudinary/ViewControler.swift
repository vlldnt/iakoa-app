import UIKit
import Cloudinary

class ViewController: UIViewController {

    let cloudName: String = "dosmcugs4"

    var cloudinary: CLDCloudinary!

    override func viewDidLoad() {
        super.viewDidLoad()
        initCloudinary()
    }
    private func initCloudinary() {
        let config = CLDConfiguration(cloudName: cloudName, secure: true)
        cloudinary = CLDCloudinary(configuration: config)
    }

}

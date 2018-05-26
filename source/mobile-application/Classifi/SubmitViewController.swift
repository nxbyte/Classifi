/*
 Developer : Warren Seto
 Classes   : SubmitViewController
 Project   : Classifi App (v1)
 */

import UIKit
import AVFoundation
import Photos

class SubmitViewController: UIViewController
{
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var capturedLabel: UILabel!
    
    var imageData:UIImage!
    var imageLabel:String!
    var imageScore:Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updatePreferredContentSizeWithTraitCollection(self.traitCollection)

        capturedImage.image = imageByCroppingImage(image: imageData, size: CGSize(width: 256, height: 256))
        
        capturedLabel.text = "\(imageLabel!) \(imageScore!)"
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        // Update the size of the presented view controller on rotation
        self.updatePreferredContentSizeWithTraitCollection(newCollection)
    }
    
    // Sets the size for the presented view controller for any orientation
    func updatePreferredContentSizeWithTraitCollection(_ traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 135 : 500)
    }
    
    /*  */
    func checkPhotoLibraryAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void))
    {
        switch PHPhotoLibrary.authorizationStatus()
        {
        // The user has previously granted access to the photo library.
        case .authorized:
            completionHandler(true)
            
        // The user has not yet been presented with the option to grant photo library access so request access.
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ status in
                completionHandler((status == .authorized))
            })
            
            /* .denied -> The user has previously denied access. */
            /* .restricted ->             // The user doesn't have the authority to request access e.g. parental restriction. */
        default:
            completionHandler(false)
        }
    }
    
    @IBAction func savePicture(_ sender: Any) {
        
        self.checkPhotoLibraryAuthorization({ authorized in
            guard authorized else {
                return
            }
            
            PHPhotoLibrary.shared().performChanges ({
                let creationRequest = PHAssetCreationRequest.forAsset()
                
                creationRequest.addResource(with: PHAssetResourceType.photo, data: UIImageJPEGRepresentation(self.capturedImage.image!, 1.0)!, options: nil)
            },
                                                    completionHandler: {
                                                        success, error in
                                                        
            })
        })
    }
    
    @IBAction func uploadPicture(_ sender: Any) {
        
        let EXTERNAL_ENDPOINT_URL = ""
        
        var request = URLRequest(url: URL(string: EXTERNAL_ENDPOINT_URL)!)
        request.httpMethod = "POST" //set http method as POST
        
        let payload:[String:String] = [
            "name": imageLabel,
            "image": UIImageJPEGRepresentation(imageData, 0.5)!.base64EncodedString(options: .lineLength64Characters),
            "score": "\(String(format:"%.2f", imageScore))"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { (data, res, err) in
            self.dismiss(animated: true, completion: nil)
        }.resume()
    }
    
    private func imageByCroppingImage(image : UIImage, size : CGSize) -> UIImage {
        
        let minPixel = min(image.cgImage!.width, image.cgImage!.height),
        maxPixel = max(image.cgImage!.width, image.cgImage!.height),
        cropRect = CGRect(x: (maxPixel - minPixel) / 2, y: 0, width: minPixel, height: minPixel)
        
        return UIImage(cgImage: image.cgImage!.cropping(to: cropRect)!, scale: 0, orientation: image.imageOrientation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  QRCodeController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase

class QRCodeController: UIViewController {
    var mediaDict: [String: String] = [:]
    @IBOutlet weak var qrView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        name.text = Auth.auth().currentUser?.displayName
        print(mediaDict)
        if let ciQR = self.generateQr(medias: mediaDict) {
            qrView.image = UIImage(ciImage: ciQR)
            qrView.layer.magnificationFilter = CALayerContentsFilter(rawValue: kCISamplerFilterNearest)
        } else {
            self.presentAlert(withTitle: "Error", message: "Could not generate QR code")
        }
        
    }
    

    func generateQr(medias : Dictionary<String, String>) -> CIImage? {
        let dict = medias
        do {
            
               let data = try JSONEncoder().encode(dict)
               if let validData = String(data: data,encoding: .utf8){
                   print(validData)
               }
               
               if let filter = CIFilter(name: "CIQRCodeGenerator"){
                   filter.setValue(data, forKey: "inputMessage")
                   filter.setValue("Q", forKey: "inputCorrectionLevel")
                   let transform = CGAffineTransform(scaleX: 5, y: 5)
                   if let output = filter.outputImage?.transformed(by: transform){
                    switch traitCollection.userInterfaceStyle {
                        case .light, .unspecified:
                            // light mode detected
                            return output
                        case .dark:
                            // dark mode detected
                            return output.inverted?.blackTransparent
                    }
                   }
               }
           } catch {
               print(error.localizedDescription)
           }
           return nil
       }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
extension CIImage {
    /// Inverts the colors and creates a transparent image by converting the mask to alpha.
    /// Input image should be black and white.
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }

    /// Inverts the colors.
    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }

        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }

    /// Converts all black to transparent.
    var blackTransparent: CIImage? {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }

    /// Applies the given color as a tint color.
    func tinted(using color: UIColor) -> CIImage?
    {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }

        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage

        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)

        return filter.outputImage!
    }
}


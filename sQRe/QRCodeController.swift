//
//  QRCodeController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit

class QRCodeController: UIViewController {
    var user: User?
    var qrImage: CIImage!
    @IBOutlet weak var qrView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let filter = CIFilter(name: "CIQRCodeGenerator")
        let name = user?.name?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let email = user?.email?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let phone_number = user?.name?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let dict = ["name": name, "email": email, "phone_number": phone_number]
        do {
             let filtered_dict = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
            filter?.setValue(filtered_dict, forKey: "inputMessage")
        } catch  {
            
        }
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let output = filter?.outputImage?.transformed(by: transform)
        qrView.image = UIImage(ciImage: output!)
        // Do any additional setup after loading the view.
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

//
//  user.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import Foundation
import UIKit
class User {
    var name: String?
    var email: String?
    var phone_number: String?
    var user_id: String?
    //Constructor
    init(name: String, email: String, phone_number: String, user_id: String) {
        self.name = name
        self.email = email
        self.phone_number = phone_number
        self.user_id = user_id
    }
    func generateQr() -> UIImage {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        let name = self.name?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let email = self.email?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let phone_number = self.phone_number?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let user_id = self.user_id?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let dict = ["name": name, "email": email, "phone_number": phone_number, "user_id": user_id]
        do {
            let filtered_dict = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
            filter?.setValue(filtered_dict, forKey: "inputMessage")
        } catch  {
            
        }
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let output = filter?.outputImage?.transformed(by: transform)
        return UIImage(ciImage: output!)
    }

    
}

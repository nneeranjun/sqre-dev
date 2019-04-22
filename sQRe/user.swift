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
    func generateQr() -> CIImage? {
        /*
        let name1 = name?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let email1 = email?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let phone_number1 = phone_number?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let user_id1 = user_id?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let dict = ["name": name1, "email": email1, "phone_number": phone_number1, "user_id": user_id1]
 
        do {
            let filtered_dict = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
            filter?.setValue(filtered_dict, forKey: "inputMessage")
        } catch  {
            
        }
 */
        let dict = ["name": name, "email": email, "phone_number": phone_number, "user_id": user_id]
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
                    return output
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    
}

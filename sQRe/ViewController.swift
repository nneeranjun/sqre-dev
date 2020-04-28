//
//  ViewController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    var user: User!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phone_number_field: UITextField!
    
    @IBOutlet weak var facebookField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.view.backgroundColor = UIColor.clear
        
    }
    //MARK: Actions
    @IBAction func generateQR(_ sender: UIButton) {
        let name = nameField.text
        let email = emailField.text
        let phone_number = phone_number_field.text
        let facebook = facebookField.text
        /*AF.request("http://127.0.0.1:5000/register", method: .post, parameters: params, encoding: JSONEncoding.default).responseString { response in
                switch response.result {
                case .success:
                    let user_id = response.result.value
                    self.user = User(name: name!, email: email!, phone_number: phone_number!, facebook: facebook!, user_id: user_id!)
                    self.performSegue(withIdentifier: "qrSegue", sender: self)
                case .failure:
                    print("Error")
            }
        }*/
        let user_id = "13123123123"
        self.user = User(name: name!, email: email!, phone_number: phone_number!, facebook: facebook!, user_id: user_id)
        self.performSegue(withIdentifier: "qrSegue", sender: self)
        
        
    }
    
    //END Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is QRCodeController {
            //Pass user object
            let qr_controller = segue.destination as? QRCodeController
        }
    }
    

    
}


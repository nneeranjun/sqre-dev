//
//  ViewController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var user: User?
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phone_number_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    //MARK: Actions
    @IBAction func generateQR(_ sender: UIButton) {
        user = User(name: nameField.text!, email: emailField.text!, phone_number: phone_number_field.text!)
        performSegue(withIdentifier: "qrSegue", sender: self)
    }
    
    //END Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is QRCodeController {
            //Pass user object
            let qr_controller = segue.destination as? QRCodeController
            qr_controller?.user = user
        }
    }
    
}


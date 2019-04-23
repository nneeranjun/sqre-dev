//
//  ScannedViewController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/22/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit

class ScannedViewController: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
   
    var scanned_info: Dictionary<String, String>!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        name.text = scanned_info["name"]
        phoneNumber.text = scanned_info["phone_number"]
        email.text = scanned_info["email"]
        
    }
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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

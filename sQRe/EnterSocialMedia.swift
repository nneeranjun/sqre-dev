//
//  EnterSocialMedia.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/10/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase

class EnterSocialMedia: UIViewController {

    

    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var twitter: UITextField!
    @IBOutlet weak var instagram: UITextField!
    @IBOutlet weak var snapchat: UITextField!
    @IBOutlet weak var venmo: UITextField!
    @IBOutlet weak var facebookURL: UITextField!
    @IBOutlet weak var linkedinURL: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    //@IBOutlet weak var fbButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func saveMedia(_ sender: Any) {
        let db = Firestore.firestore()
        if !verifyUrl(urlString: facebookURL.text) && facebookURL.text != "" {
            let alert = UIAlertController(title: "Facbeook URL is not valid", message: "Please re-enter a valid Facebook URL", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        } else if !verifyUrl(urlString: linkedinURL.text) && linkedinURL.text != "" {
            let alert = UIAlertController(title: "Linkedin URL is not valid", message: "Please re-enter a valid Linkedin URL", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        } else if !isPhoneNumber(phoneNumber: phoneNumber.text!) && phoneNumber.text != "" {
            let alert = UIAlertController(title: "Phone Number not valid", message: "Please re-enter a valid phone number", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        db.collection("users").document((Auth.auth().currentUser?.uid)!).setData([
            "Snapchat": snapchat.text ?? "",
            "Instagram": instagram.text ?? "",
            "Twitter": twitter.text ?? "",
            "Linkedin": linkedinURL.text ?? "",
            "Venmo": venmo.text ?? "",
            "Facebook": facebookURL.text ?? "",
            "Phone Number": phoneNumber.text ?? "",
            "Score": 0
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                self.performSegue(withIdentifier: "AfterEnteringSocialSegue", sender: nil)
            }
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func isPhoneNumber(phoneNumber: String) -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: phoneNumber, options: [], range: NSRange(location: 0, length: phoneNumber.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phoneNumber.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }

}

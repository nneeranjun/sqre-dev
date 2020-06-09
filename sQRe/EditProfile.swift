//
//  EditProfile.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 6/6/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import TweeTextField
import Firebase

class EditProfile: UIViewController {
    var media: String!
    var value: String!
    
    @IBOutlet weak var input: TweeAttributedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Your " + media
        // Do any additional setup after loading the view.
        input.clearButtonMode = .whileEditing
        input.infoAnimationDuration = 0.7
        input.infoTextColor = .systemRed
        input.infoFontSize = 13
                
        input.activeLineColor = .systemBlue
        input.activeLineWidth = 1
        input.animationDuration = 0.3
                
        input.lineColor = .secondaryLabel
        input.lineWidth = 1
        
                
        input.placeholderDuration = 0.3
        input.placeholderColor = .tertiaryLabel
        
        if media == "Linkedin" || media == "Facebook" {
            input.tweePlaceholder = media + " URL"
        } else if media == "Phone Number" || media == "Name" || media == "Email" || media == "Password" {
            input.tweePlaceholder = media
        } else {
            input.tweePlaceholder = media + " Username"
        }
        
        if media == "Phone Number" {
            input.keyboardType = .numberPad
        }
        
        if value != "" {
            input.text = value
            self.input.becomeFirstResponder()
        }
    }
    

    
    @IBAction func save(_ sender: Any) {
        
        let value = input.text ?? ""
        if verifyInput(input: value, media: media) {
            //Loading indicator
            self.input.resignFirstResponder()
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.startAnimating();
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            
            //Update data in database
            let db = Firestore.firestore()
            let docref = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
            docref.updateData([media: value]) { err in
                if let err = err {
                    //Error here
                    print(err.localizedDescription)
                } else {
                    alert.dismiss(animated: true) {
                        let success = UIAlertController(title: "Successfully uploaded", message: "", preferredStyle: .alert)
                        //let checkmark = UIImage.checkmark
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                            self.navigationController?.topViewController!.dismiss(animated: true, completion: nil)
                            
                        })
                        //let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
                        //imageView.image = checkmark
                        success.addAction(ok)
                        //success.view.addSubview(imageView)
                        self.present(success, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Invalid " + media, message: "Enter a valid " + media, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
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
       
       func verifyInput(input: String, media: String) -> Bool {
           if media == "Linkedin" || media == "Facebook" {
               return verifyUrl(urlString: input)
           } else if media == "Phone Number" {
               return isPhoneNumber(phoneNumber: input)
           } else {
            return !input.contains(" ")
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

}

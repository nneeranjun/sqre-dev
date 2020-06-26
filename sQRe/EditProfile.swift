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
        print(value)
        
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
        } else if media == "Phone Number" || media == "Name" || media == "Email" {
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
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        input.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if verifyInput(input: textField.text ?? "", media: self.media) && textField.text != self.value {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            print("valid")
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            print("invalid")
        }
        return
    }
    
    func disableSaveButton() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    @IBAction func save(_ sender: Any) {
        self.disableSaveButton()
        let val = input.text ?? ""
        
        self.input.resignFirstResponder()
        let alert = self.presentLoadingIndicator()
        
        if media == "Name" {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = val
            changeRequest?.commitChanges { (error) in
                if error != nil {
                    print("Error updating name")
                    alert.dismiss(animated: true) {
                        self.presentAlertWithHandler(withTitle: "Error Updating Profile", message: "") { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    print("Succesfully updated profile item")
                    self.value = val
                    alert.dismiss(animated: true) {
                        self.presentAlertWithHandler(withTitle: "Successfully Updated Profile", message: "") { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        } else {
            if verifyInput(input: val, media: media) {
                //Update data in database
                let db = Firestore.firestore()
                
                let docref = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
                docref.updateData([media: val]) { (error) in
                    if error != nil {
                        //Error here
                        print("ERROR HERE: " + error.debugDescription)
                        alert.dismiss(animated: true) {
                            self.presentAlertWithHandler(withTitle: "Error Updating Profile", message: "") { _ in
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    } else {
                        print("No error")
                        self.value = val
                        alert.dismiss(animated: true) {
                            alert.dismiss(animated: true) {
                                self.presentAlertWithHandler(withTitle: "Successfully Updated Profile", message: "") { _ in
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            } else {
                alert.dismiss(animated: true) {
                    let alert = UIAlertController(title: "Invalid " + self.media, message: "Enter a valid " + self.media, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
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
           } else if media == "Name" {
            return true
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
extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}


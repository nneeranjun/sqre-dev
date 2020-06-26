//
//  ForgotPassword.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 6/13/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import TweeTextField
import Firebase

class ForgotPassword: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var input: TweeAttributedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        input.returnKeyType = .done
        input.becomeFirstResponder()
        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        input.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
    }
    
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text!.isValidEmail {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            print("valid")
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            print("invalid")
        }
        return
    }
    
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        input.resignFirstResponder()
        return true
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        input.resignFirstResponder()
        let email = input.text!
        if !email.isValidEmail {
            //Error
            print("Invalid email")
        } else {
            let loading = self.presentLoadingIndicator()
            Auth.auth().sendPasswordReset(withEmail: email, completion: {error in
                if let err = error {
                    //Display error message
                    loading.dismiss(animated: true) {
                    print("Error: ", err.localizedDescription)
                        self.presentAlert(withTitle: "Email Does not Exist", message: "Please enter a valid email")
                    }
                 
                } else {
                    loading.dismiss(animated: true) {
                    //Reset email successfully sent, display this to user
                        let alert = UIAlertController(title: "Password Reset Email Sent", message: "Please check your email: " + email, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: {_ in
                            self.dismiss(animated: true, completion: nil)
                        })
                         alert.addAction(ok)
                         self.present(alert, animated: true, completion: nil)
                        
                        self.presentAlertWithHandler(withTitle: "Password Reset Email Sent", message: "Please check your email: " + email) {_ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            })
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

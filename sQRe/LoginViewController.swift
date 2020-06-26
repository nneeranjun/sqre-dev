//
//  LoginViewController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/7/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
class LoginViewController: UIViewController, FUIAuthDelegate {
    
    @IBAction func forgotPassword(_ sender: Any) {
        self.performSegue(withIdentifier: "forgotPassword", sender: self)
    }
    @IBAction func loginButton(_ sender: Any) {
        
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.authViewController().modalPresentationStyle = .fullScreen
        authUI?.delegate = self
        //self.modalPresentationStyle = .fullScreen
        let providers: [FUIAuthProvider] = [
          FUIGoogleAuth(),
          FUIEmailAuth()
        ]
        authUI?.providers = providers
        let authViewController = authUI?.authViewController()

        
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    
    
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        if error != nil {
            print("Could not log in user:")
            self.presentAlert(withTitle: "Error", message: "Login Unsuccessful. Try again.")
            
        } else {
           print("Login successful for:")
            
           //Check if user has just registered
            //self.performSegue(withIdentifier: "scannerSegue", sender: nil)
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

extension UIViewController {
    func presentAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentAlertWithHandler(withTitle title: String, message : String, handler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentLoadingIndicator() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        return alert
    }
    
    
}




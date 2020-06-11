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
    var alert: UIAlertController!
    
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
            self.alert.dismiss(animated: true, completion: nil)
        } else {
           print("Login successful for:")
           //Check if user has just registered
            //self.performSegue(withIdentifier: "scannerSegue", sender: nil)
            self.alert.dismiss(animated: true, completion: nil)
        }
    }
           
    
    override func viewWillDisappear(_ animated: Bool) {
        //Auth.auth().removeStateDidChangeListener(handle!)
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



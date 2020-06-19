//
//  Settings.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 6/10/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class Settings: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let settingsData = ["Sign Out", "Privacy Policy", "About"]
    var credential : AuthCredential! = nil
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
        cell.backgroundColor = .tertiarySystemBackground
        cell.textLabel?.text = settingsData[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch settingsData[indexPath.row] {
        case "Sign Out":
            signOut()
        case "Reset / Change Password":
            resetPassword()
        default:
            return
    
        }
    }
    
    
    
    func signOut() {
        let confirm = UIAlertController(title: "Sign Out", message: "Are you sure you would like to sign out?", preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                //Error handle here
                  print ("Error signing out: %@", signOutError)
                }
            })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                confirm.dismiss(animated: true, completion: nil)
        })
            //let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
            //imageView.image = checkmark
            confirm.addAction(yes)
            confirm.addAction(cancel)
            //success.view.addSubview(imageView)
            self.present(confirm, animated: true, completion: nil)
    }
    
    func resetPassword() {
        let confirm = UIAlertController(title: "Reset / Change Password", message: "Are you sure you would like to reset / change your password?", preferredStyle: .actionSheet)
               let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                       Auth.auth().sendPasswordReset(withEmail: (Auth.auth().currentUser?.email)!, completion: {error in
                           if let err = error {
                               //Display error message
                               print("Error: ", err.localizedDescription)
                            
                           } else {
                               //Reset email successfully sent, display this to user
                                let alert = UIAlertController(title: "Password Reset Email Set", message: "Please check your email: " + (Auth.auth().currentUser?.email)!, preferredStyle: .alert)
                                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alert.addAction(ok)
                                self.present(alert, animated: true, completion: nil)
                           }
                       })
                   })
               let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                       confirm.dismiss(animated: true, completion: nil)
               })
                   //let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
                   //imageView.image = checkmark
                   confirm.addAction(yes)
                   confirm.addAction(cancel)
                   //success.view.addSubview(imageView)
                   self.present(confirm, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        
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

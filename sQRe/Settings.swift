//
//  Settings.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 6/10/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase

class Settings: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let settingsData = ["Sign Out", "Delete Account", "Reset / Change Password", "Change Email", "Privacy Policy", "About"]
    
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
        case "Delete Account":
            deleteAccount()
        default:
            return
    
        }
    }
    
    func deleteAccount() {
        let confirm = UIAlertController(title: "Delete Account", message: "Are you sure you would like to delete your account?", preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
               /*  let user = Auth.auth().currentUser
                var credential: AuthCredential

                // Prompt the user to re-provide their sign-in credentials
             
                
                
                
                user?.reauthenticate(with: credential) { error in
                  if let error = error {
                    // An error happened.
                  } else {
                    // User re-authenticated.
                  }
                }
             */
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            //let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
            //imageView.image = checkmark
            confirm.addAction(yes)
            confirm.addAction(cancel)
            //success.view.addSubview(imageView)
            self.present(confirm, animated: true, completion: nil)
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

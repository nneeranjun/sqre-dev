//
//  ScannedViewController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/22/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import FirebaseUI
import Firebase

class ScannedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CNContactViewControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var noAtSymbol = ["Facebook", "Email", "Linkedin", "Phone Number"]
    var scanned_info: Dictionary<String, String>!
    var mediaInfo: [String: String] = [:]
    var scannedUID: String!
    var scannedName: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view. 
        tableView.allowsSelection = true
        print(scanned_info)
        scannedUID = scanned_info["UID"]
        scannedName = scanned_info["Name"]
        self.title = scannedName
        for (key, val) in scanned_info {
            if key != "UID" && key != "Name" {
                mediaInfo[key] = val
            }
        }
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.borderWidth = 5
        profileImage.layer.borderColor = UIColor.systemFill.cgColor
        tableView.tableFooterView = UIView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let storage = Storage.storage()
        print(scannedUID)
        let storageReference = storage.reference().child("profile_pictures/" + scannedUID)
        let placeHolder = UIImage(named: "profile-placeholder")
        storageReference.listAll { (result, error) in
          if let err = error {
            // ...
            print(err.localizedDescription)
            return
          }
            
          for item in result.items {
            // The items under storageReference.
            self.profileImage.sd_setImage(with: item, placeholderImage: placeHolder)
            print("Image successfully processed")
            break
          }
        }
    }
    
    /*@IBAction func addFacebook(_ sender: Any) {
        let url: URL = URL(string: "https://www.facebook.com/nilay.neeranjun")!
        let fbIdUrl: URL = URL(string: "fb://profile/100000100573857")!
        if (UIApplication.shared.canOpenURL(fbIdUrl)) {
            UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        print("success")
    }
 */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaInfo.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allMedias = Array(mediaInfo.keys)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath) as! SocialTableViewCell
        if noAtSymbol.contains(allMedias[indexPath.row]) {
            cell.mediaTag.text = mediaInfo[allMedias[indexPath.row]]!
        } else {
             cell.mediaTag.text = "@" + mediaInfo[allMedias[indexPath.row]]!
        }
        cell.mediaLogo.image = UIImage(named: allMedias[indexPath.row])
        cell.selectionStyle = .default
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal, title: "Copy",
          handler: { (action, view, completionHandler) in
          // Update data source when user taps action
          let allMedias = Array(self.mediaInfo.keys)
          let media = allMedias[indexPath.row]
          UIPasteboard.general.string = self.mediaInfo[media]
          completionHandler(true)
            let alert = UIAlertController(title: "Copied To Clipboard", message: "", preferredStyle: .alert)
            self.present(alert, animated: true)
            Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        })
        action.backgroundColor = UIColor(hexaString: "#25ED9F")
        action.image = UIImage(systemName: "doc.on.clipboard")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SocialTableViewCell
        let mediaTag = cell.mediaTag.text
        let allMedias = Array(mediaInfo.keys)
        if mediaTag!.count > 1 {
            switch allMedias[indexPath.row] {
            case "Snapchat":
                let url: URL = URL(string: "snapchat://add/" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                let fbIdUrl: URL = URL(string: "https://www.snapchat.com/add/" + mediaTag!)!
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
                }
            case "Phone Number":
                //Direct to filled out contact or just add contact?
                let contact = CNMutableContact()
                let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :mediaTag!))
                contact.phoneNumbers = [homePhone]
                //contact.imageData = data // Set image data here
                let vc = CNContactViewController(forNewContact:contact)
                vc.delegate = self
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            case "Instagram":
                let url: URL = URL(string: "instagram://user?username=" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                  let fbIdUrl: URL = URL(string: "http://instagram.com/" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                  if (UIApplication.shared.canOpenURL(fbIdUrl)) {
                      UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
                  } else {
                      UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case "Facebook":
                print("Pressed facebook")
                let url: URL = URL(string: mediaTag ?? "")!
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case "Linkedin":
                let url: URL = URL(string: mediaTag ?? "")!
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }

            case "Twitter":
                let url: URL = URL(string: "twitter://user?screen_name=" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                let fbIdUrl: URL = URL(string: "https://twitter.com/" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
                }

            default:
                print("unrecognized media")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
    }
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
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
extension String{
    func subString(from: Int, to: Int) -> String {
       let startIndex = self.index(self.startIndex, offsetBy: from)
       let endIndex = self.index(self.startIndex, offsetBy: to - 1)
       return String(self[startIndex...endIndex])
    }
}

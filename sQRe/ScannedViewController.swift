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
import Firebase

class ScannedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CNContactViewControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var noAtSymbol = ["Facebook", "Email", "Linkedin", "Phone Number"]
    var scanned_info: Dictionary<String, String>!
    var mediaInfo: [String: String] = [:]
    var scannedUID: String!
    var scannedName: String!
    @IBOutlet weak var score: UILabel!
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view. 
        tableView.allowsSelection = true
        scannedUID = scanned_info["UID"]
        scannedName = scanned_info["Name"]
        name.text = scannedName
        for (key, val) in scanned_info {
            if key != "UID" && key != "Name" && key != "Score" {
                mediaInfo[key] = val
            }
        }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(scanned_info["UID"]!)

           docRef.getDocument { (document, error) in
               if let document = document, document.exists {
                   self.score.text = "— " + String(document.data()!["Score"] as! Int) + " —"
               } else {
                   print("Document does not exist")
               }
           }
        tableView.tableFooterView = UIView()
        
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
        let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 25, height: 25))
        imageView.image = UIImage(named:"Add")
        imageView.contentMode = .scaleAspectFit
        cell.accessoryView = imageView
        cell.selectionStyle = .none
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
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
                if (UIApplication.shared.canOpenURL(fbIdUrl)) {
                    UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                tableView.deselectRow(at: indexPath, animated: true)
                return
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
                tableView.deselectRow(at: indexPath, animated: true)
                return
            case "Instagram":
                let url: URL = URL(string: "instagram://user?username=" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                  let fbIdUrl: URL = URL(string: "http://instagram.com/" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                  if (UIApplication.shared.canOpenURL(fbIdUrl)) {
                      UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
                  } else {
                      UIApplication.shared.open(url, options: [:], completionHandler: nil)
                  }
                  tableView.deselectRow(at: indexPath, animated: true)
            return
            case "Facebook":
                let url: URL = URL(string: mediaTag!.subString(from: 1, to: mediaTag!.count))!
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                tableView.deselectRow(at: indexPath, animated: true)
                return
            case "Linkedin":
               let url: URL = URL(string: mediaTag!.subString(from: 1, to: mediaTag!.count))!
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                tableView.deselectRow(at: indexPath, animated: true)
                return
            case "Twitter":
                let url: URL = URL(string: "twitter://user?screen_name=" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                let fbIdUrl: URL = URL(string: "https://twitter.com/" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                if (UIApplication.shared.canOpenURL(fbIdUrl)) {
                    UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                tableView.deselectRow(at: indexPath, animated: true)
                return
            case "Venmo":
                let url: URL = URL(string: "venmo://users/" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                let fbIdUrl: URL = URL(string: "https://venmo.com/" + mediaTag!.subString(from: 1, to: mediaTag!.count))!
                if (UIApplication.shared.canOpenURL(fbIdUrl)) {
                    UIApplication.shared.open(fbIdUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                tableView.deselectRow(at: indexPath, animated: true)
                return
            default:
                return
            }
        }
        
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

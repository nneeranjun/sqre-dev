//
//  SelectSharedMediaTableViewController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/10/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase

class SelectSharedMediaTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let allMedias = ["Snapchat", "Instagram", "Phone Number", "Twitter", "Linkedin", "Email", "Facebook", "Venmo"]
    var availableMedias : [String] = ["Email"]
    var selected : [String] = []
    var mediaDict : [String: String] = [:]
    
    @IBOutlet weak var select_all_button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func generateQR(_ sender: Any) {
        
        if tableView.indexPathsForSelectedRows == nil {
            let alert = UIAlertController(title: "Cannot Generate QR", message: "Select one or more medias", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        } else {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
            for index in tableView.indexPathsForSelectedRows! {
                selected.append(availableMedias[index.row])
            }
            

            let db = Firestore.firestore()
                   let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
                   docRef.getDocument { (document, error) in
                    if let err = error {
                        self.presentAlert(withTitle: "Error", message: "An error occurred loading your social media. Please try again.")
                        return
                    }
                       if let document = document, document.exists {
                        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

                                   let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                                   loadingIndicator.hidesWhenStopped = true
                                   loadingIndicator.startAnimating();

                                   alert.view.addSubview(loadingIndicator)
                        self.present(alert, animated: true, completion: nil)
                           var mediaDict : [String: String] = [:]
                           mediaDict["UID"] = Auth.auth().currentUser?.uid
                           let dataDescription = document.data()
                        mediaDict["Name"] = Auth.auth().currentUser?.displayName
                           for media in self.selected {
                                if media == "Email" {
                                    mediaDict["Email"] = Auth.auth().currentUser?.email
                                } else {
                                   mediaDict[media] = (dataDescription![media]! as! String)
                                }
                           }
                        
                        self.mediaDict = mediaDict
                        print(mediaDict)
                        alert.dismiss(animated: true) {
                            self.performSegue(withIdentifier: "qrSegue", sender: self)
                        }
                       } else {
                            
                           print("Document does not exist")
                           self.dismiss(animated: true, completion: nil)
                        
                       }
        }
    }
    }
    
    @IBAction func select_all(_ sender: Any) {
        if self.select_all_button.titleLabel?.text == "Select All" {
            for i in 0...tableView.numberOfRows(inSection: 0) - 1 {
                let ip = IndexPath(row: i, section: 0)
                self.tableView.selectRow(at: ip, animated: true, scrollPosition: .none)
                self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: ip)
            }
        } else {
            for i in 0...tableView.numberOfRows(inSection: 0) - 1 {
                let ip = IndexPath(row: i, section: 0)
                self.tableView.deselectRow(at: ip, animated: true)
                self.tableView.delegate?.tableView?(self.tableView, didDeselectRowAt: ip)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableMedias.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMediaCell", for: indexPath) as! SelectSharedMediaCell
        cell.mediaName.text = availableMedias[indexPath.row]
        cell.socialLogo.image = UIImage(named: availableMedias[indexPath.row])
        cell.selectionStyle = .none
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.mediaName.font = UIFont.boldSystemFont(ofSize: 15)
        cell.isUserInteractionEnabled = true
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if tableView.indexPathsForSelectedRows?.count == tableView.numberOfRows(inSection: 0) {
            self.select_all_button.setTitle("Deselect All", for: .normal)
        } else {
            self.select_all_button.setTitle("Select All", for: .normal)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        if tableView.indexPathsForSelectedRows?.count == tableView.numberOfRows(inSection: 0) {
            select_all_button.titleLabel?.text = "Deselect All"
            self.select_all_button.setTitle("Deselect All", for: .normal)
        } else {
            select_all_button.titleLabel?.text = "Select All"
            self.select_all_button.setTitle("Select All", for: .normal)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        let db = Firestore.firestore()
               let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
               docRef.getDocument { (document, error) in
                   if let document = document, document.exists {
                       for media in self.allMedias {
                        let data = document.data()
                        let val = data![media]
                        if val != nil && val as! String != "" {
                            print(media)
                            self.availableMedias.append(media)
                        }
                       }
                    print(self.availableMedias)
                       self.tableView.reloadData()
                   }
               }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
       
    }
    


    // MARK: - Table view data source

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let qr_controller = segue.destination as! UINavigationController
        let secondC = qr_controller.viewControllers.first as! QRCodeController
        secondC.mediaDict = self.mediaDict
            
    }
    

}

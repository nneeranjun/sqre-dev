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
    var availableMedias : [String] = []
    var selected : [String] = []
    var mediaDict : [String: String] = [:]
    
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
           
            for index in tableView.indexPathsForSelectedRows! {
                selected.append(allMedias[index.row])
            }
            let db = Firestore.firestore()
                   let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
                   docRef.getDocument { (document, error) in
                       if let document = document, document.exists {
                        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

                                   let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                                   loadingIndicator.hidesWhenStopped = true
                                   loadingIndicator.style = UIActivityIndicatorView.Style.gray
                                   loadingIndicator.startAnimating();

                                   alert.view.addSubview(loadingIndicator)
                        self.present(alert, animated: true, completion: nil)
                           var mediaDict : [String: String] = [:]
                           mediaDict["UID"] = Auth.auth().currentUser?.uid
                           let dataDescription = document.data()
                        mediaDict["Score"] = String(dataDescription!["Score"] as! IntegerLiteralType)
                        mediaDict["Name"] = Auth.auth().currentUser?.displayName
                           for media in self.selected {
                                if media == "Email" {
                                    mediaDict["Email"] = Auth.auth().currentUser?.email
                                } else {
                                   mediaDict[media] = (dataDescription![media]! as! String)
                                }
                           }
                        
                        self.mediaDict = mediaDict
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
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMedias.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMediaCell", for: indexPath) as! SelectSharedMediaCell
        cell.mediaName.text = allMedias[indexPath.row]
        cell.socialLogo.image = UIImage(named: allMedias[indexPath.row])
        cell.selectionStyle = .none
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.isUserInteractionEnabled = false
        cell.mediaName.font = UIFont.boldSystemFont(ofSize: 15)
        
        if availableMedias.contains(allMedias[indexPath.row]) || allMedias[indexPath.row] == "Email" {
            cell.isUserInteractionEnabled = true
        } else {
            cell.mediaName.text = "(Missing Info)"
        }
        
        
        
        

        // Configure the cell...

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
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
        if segue.destination is QRCodeController {
            
                   //Pass user object
            let qr_controller = segue.destination as? QRCodeController
            qr_controller?.mediaDict = self.mediaDict
            
            }
    }
    

}

//
//  LoadScansViewController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/19/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class LoadScansViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var data_scanner: [Dictionary<String, Any>] = []
    var data_scanned: [Dictionary<String, Any>] = []
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var last_viewed_scanner: QueryDocumentSnapshot!
    var last_viewed_scanned: QueryDocumentSnapshot!
    var selectedScanForShow: Int = -1
    
    @IBAction func segControlChanged(_ sender: Any) {
        self.tableView.reloadData()
    }

    
    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        let db = Firestore.firestore()
        let first =  db.collection("scans").whereField("scanner_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "time_stamp", descending: true).limit(to: 25)
        

        first.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreving cities: \(error.debugDescription)")
                return
            }

            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                return
            }
            for doc in snapshot.documents {
                if doc.documentID != "EsrAgktVjcG7Ru3zVLv9" {
                    self.data_scanner.append(doc.data())
                }
            }
            self.last_viewed_scanner = lastSnapshot
            self.tableView.reloadData()
        }
            
            let second =  db.collection("scans").whereField("scanned_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "time_stamp", descending: true).limit(to: 25)
            

            second.addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error retreving cities: \(error.debugDescription)")
                    return
                }

                guard let lastSnapshot = snapshot.documents.last else {
                    // The collection is empty.
                    print("Empty")
                    return
                }
                for doc in snapshot.documents {
                    if doc.documentID != "EsrAgktVjcG7Ru3zVLv9" {
                        self.data_scanned.append(doc.data())
                    }
                }
                self.last_viewed_scanned = lastSnapshot
                self.tableView.reloadData()
            }
        
            
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segControl.selectedSegmentIndex == 0 {
            return data_scanner.count
        } else {
            return data_scanned.count
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segControl.selectedSegmentIndex == 0 {
            return "I've Scanned"
        } else {
            return "Scanned Me"
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadScannedCell", for: indexPath) as! ViewScannedCell
        if segControl.selectedSegmentIndex == 0 {
            cell.name.text = (data_scanner[indexPath.row]["scanned_info"] as! Dictionary<String, String>)["Name"]
            cell.date.text = convertTime(timeStamp: data_scanner[indexPath.row]["time_stamp"] as! Timestamp)
            let storage = Storage.storage()
            let scanned_uid = data_scanner[indexPath.row]["scanned_id"] as! String
            let pathReference = storage.reference(withPath: "profile_pictures/" + scanned_uid)
            let placeHolder = UIImage(named: "profile-placeholder")
            cell.profileImage.sd_setImage(with: pathReference, placeholderImage: placeHolder)
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.name.text = (data_scanned[indexPath.row]["scanner_name"] as! String)
            cell.date.text = convertTime(timeStamp: data_scanned[indexPath.row]["time_stamp"] as! Timestamp)
            let storage = Storage.storage()
            let scanned_uid = data_scanned[indexPath.row]["scanner_id"] as! String
            let pathReference = storage.reference(withPath: "profile_pictures/" + scanned_uid)
            let placeHolder = UIImage(named: "profile-placeholder")
            cell.profileImage.sd_setImage(with: pathReference, placeholderImage: placeHolder)
            cell.accessoryType = .none
        }
       
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width / 2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.borderWidth = 2
        cell.profileImage.layer.borderColor = UIColor.init(hexaString: "#25ED9F").cgColor
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segControl.selectedSegmentIndex == 0 {
            selectedScanForShow = indexPath.row
            performSegue(withIdentifier: "PrevScannedSegue", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        selectedScanForShow = -1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let db = Firestore.firestore()
        if segControl.selectedSegmentIndex == 0 {
            if indexPath.row == self.data_scanner.count - 1 {
                let first =  db.collection("scans").whereField("scanner_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "time_stamp", descending: true).limit(to: 25).start(afterDocument: last_viewed_scanner)
                
                first.addSnapshotListener { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print("Error retreving cities: \(error.debugDescription)")
                        return
                    }

                    guard let lastSnapshot = snapshot.documents.last else {
                        // The collection is empty.
                        return
                        
                    }
                    for doc in snapshot.documents {
                        if doc.documentID != "EsrAgktVjcG7Ru3zVLv9" {
                            self.data_scanner.append(doc.data())
                        }
                    }
                    self.last_viewed_scanner = lastSnapshot
                    self.tableView.reloadData()
                
                // Use the query for pagination.
                    
                }
                
            }
        } else {
            if indexPath.row == self.data_scanned.count - 1 {
                let first =  db.collection("scans").whereField("scanned_id", isEqualTo: Auth.auth().currentUser?.uid).order(by: "time_stamp", descending: true).limit(to: 25).start(afterDocument: last_viewed_scanned)
                
                first.addSnapshotListener { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print("Error retreving cities: \(error.debugDescription)")
                        return
                    }

                    guard let lastSnapshot = snapshot.documents.last else {
                        // The collection is empty.
                        return
                        
                    }
                    for doc in snapshot.documents {
                        if doc.documentID != "EsrAgktVjcG7Ru3zVLv9" {
                            self.data_scanned.append(doc.data())
                        }
                    }
                    self.last_viewed_scanned = lastSnapshot
                    self.tableView.reloadData()
                // Use the query for pagination.
                }
                
            }
        }
    }
    
    func convertTime(timeStamp: Timestamp) -> String {
        let time = abs(NSInteger(timeStamp.dateValue().timeIntervalSinceNow))
        let daysSinceNow = time / (3600 * 24)
        let hrsSinceNow = time  / 3600
        let minSinceNow = (time / 60) % 60
        let secSinceNow = time % 60
        print(daysSinceNow)
        if daysSinceNow >= 1 && daysSinceNow <= 500 {
            return daysSinceNow.description + "d"
        } else if hrsSinceNow >= 1 && hrsSinceNow <= 23 {
            return hrsSinceNow.description + "h"
        } else if minSinceNow >= 1 && minSinceNow <= 59 {
            return minSinceNow.description + "m"
        } else if secSinceNow >= 1 && secSinceNow <= 59 {
            return secSinceNow.description + "s"
        } else {
            return timeStamp.dateValue().description
        }
    }
    

    
   
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is ScannedViewController {
            //Pass user object
            let scanned_controller = segue.destination as? ScannedViewController
            print(selectedScanForShow, " This is selected scan index")
            scanned_controller?.scanned_info = (data_scanner[selectedScanForShow]["scanned_info"] as! Dictionary<String, String>)
        }
    }
    

}

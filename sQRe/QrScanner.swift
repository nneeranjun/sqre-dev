//
//  QrScanner.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/26/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class QrScanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var video = AVCaptureVideoPreviewLayer()
    var scanned_info = Dictionary<String, String>()
    var times_scanned = 0
    var isHolding = false
    @IBAction func goToSettings(_ sender: Any) {
        performSegue(withIdentifier: "GoToScans", sender: self)
        
    }
    
    
    
    
    @IBAction func viewProfile(_ sender: Any) {
        //performSegue(withIdentifier: "GoProfile", sender: self)
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        //self.navigationController?.navigationBar.backIndicatorImage = UIImage(
        //creating session
        let session = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print("error")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = UIScreen.main.bounds
        video.videoGravity = .resizeAspectFill
        view.layer.addSublayer(video)
        session.startRunning()
        
        // Do any additional setup after loading the view.
    }
    //TODO: Need to figure out how to only allow sQRe qr codes...
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if isHolding {
            print("holding")
            if metadataObjects != nil && metadataObjects.count != 0 {
                print("Scanned")
                let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedbackgenerator.prepare()
                impactFeedbackgenerator.impactOccurred()
                if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                    if object.type == AVMetadataObject.ObjectType.qr {
                        if let validData = object.stringValue?.data(using: .utf8) {
                            do {
                                scanned_info = try JSONDecoder().decode([String:String].self,from:validData)
                                //prepare for segue
                                //ADD Scanned Here
                                //Incrememnt both users scores
                                let db = Firestore.firestore()
                                let ref = db.collection("scans").addDocument(data: [
                                    "time_stamp": Firebase.Timestamp.init(),
                                    "scanner_id": Auth.auth().currentUser?.uid as Any,
                                    "scanned_id": scanned_info["UID"] as Any,
                                    "scanned_info": scanned_info,
                                    "scanner_name": Auth.auth().currentUser?.displayName as Any
                                ]) { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    } else {
                                        print(Auth.auth().currentUser!.uid + " scanned" + self.scanned_info["UID"]!)
                                        
                                    }
                                }
                                
                                //incrementing user1's score
                                let user1 = db.collection("users").document(Auth.auth().currentUser!.uid)
                                // Set the "capital" field of the city 'DC'
                        
                                print("Returned correctly as Integer")
                                // do what you need to do with myInt
                                user1.updateData([
                                    "Score": FirebaseFirestore.FieldValue.increment(Int64(1))
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                        print("Update score for: ", Auth.auth().currentUser?.uid as Any)
                                    }
                                }
                               //incrementing user2's score
                                let user2 = db.collection("users").document(scanned_info["UID"]!)
                                        // Set the "capital" field of the city 'DC'
                                
                                        print("Returned correctly as Integer")
                                        // do what you need to do with myInt
                                        user2.updateData([
                                            "Score": FirebaseFirestore.FieldValue.increment(Int64(1))
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                            } else {
                                                print("Document successfully updated")
                                                print("Update score for: ", Auth.auth().currentUser?.uid as Any)
                                            }
                                        }
     
                                
                                self.performSegue(withIdentifier: "scannedSegue", sender: self)
                                self.isHolding = false
                            } catch {
                                
                            }
                        }
                        
                        
                    }
                }
            }
 
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(downSwipe(sender:)))
        downSwipe.direction = .up
        view.addGestureRecognizer(downSwipe)
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(holdDown(sender:)))
        view.addGestureRecognizer(holdGesture)
        
        
    }
    
    @objc func downSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            print("Swiped down")
            performSegue(withIdentifier: "generateQR", sender: self)
            
        }
    }
    @objc func holdDown(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            isHolding = true
        } else if sender.state == .ended {
            isHolding = false
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "generateSegue" {
            print("going to qr generator")
        }
        if segue.destination is ScannedViewController {
            //Pass user object
            let scanned_controller = segue.destination as? ScannedViewController
            scanned_controller?.scanned_info = scanned_info
        } else {
            let scanned_controller = segue.destination as? ViewController
        }
        
    }
    
    
    

    

}

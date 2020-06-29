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
    var flashOn = false
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBAction func goToSettings(_ sender: Any) {
        performSegue(withIdentifier: "GoToScans", sender: self)
    }
    
    @IBOutlet weak var flashlight: UIBarButtonItem!
    
    @IBOutlet weak var indicatorLabel: UILabel!
    
    
    @IBOutlet weak var swipeIndicator: UIButton!
    
    @IBAction func swipeIndicator(_ sender: Any) {
        self.performSegue(withIdentifier: "generateQR", sender: self)
    }
    
    
    
    @IBAction func viewProfile(_ sender: Any) {
        performSegue(withIdentifier: "GoProfile", sender: self)
    }
    
    func toggleTorch(on: Bool) -> Bool {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
        else { return false}

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
            return true
        } catch {
            print("Torch could not be used")
            return false
        }
    }
    
    @IBAction func toggleFlashlight(_ sender: Any) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        //TODO: toggle flashlight
       
        let result = self.toggleTorch(on: !flashOn)
        if flashOn {
            if result {
                self.flashlight.image = UIImage(systemName: "flashlight.off.fill")
                self.flashlight.tintColor = .white
            }
            self.flashOn = !result
        } else {
            if result {
                self.flashlight.image = UIImage(systemName: "flashlight.on.fill")
                self.flashlight.tintColor = UIColor(hexaString: "#25ED9F")
            }
            self.flashOn = result
        }
        
    }
    
    
    
    func startCamera() {
        self.cameraButton.isHidden = true
        self.view.sendSubviewToBack(self.cameraButton)
        let session = AVCaptureSession()
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
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
            self.view.bringSubviewToFront(swipeIndicator)
            self.view.bringSubviewToFront(indicatorLabel)
            session.startRunning()
        }
    }
    
    func isCameraEnabled() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    func requestCameraAccess() {
        let settingsURL = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(settingsURL)
            {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
    }
    
    @IBAction func requestCameraAccess(_ sender: Any) {
        requestCameraAccess()
    }
    

    @objc func willResignActive(_ notification: Notification) {
        // code to execute
        self.flashlight.image = UIImage(systemName: "flashlight.off.fill")
        self.flashlight.tintColor = .white
        self.flashOn = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)

        self.cameraButton.isHidden = true
        if isCameraEnabled() {
            //already authorized
            print("Authorized")
            startCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Granted access")
                DispatchQueue.main.async {
                    self.startCamera()
                }
            } else {
                print("Denied access")
                DispatchQueue.main.async {
                    self.cameraButton.isHidden = false
                    self.view.bringSubviewToFront(self.cameraButton)
                }
            }
            }
            
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.flashlight.image = UIImage(systemName: "flashlight.off.fill")
        self.flashlight.tintColor = .white
        self.flashOn = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "arrow.left")?.withTintColor(UIColor.systemBackground)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.left")?.withTintColor(UIColor.systemBackground)
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = nil

    }
    
    
    //TODO: Need to figure out how to only allow sQRe qr codes...
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if isHolding {
            print("holding")
            if metadataObjects != nil && metadataObjects.count != 0 {
                print(scanned_info)
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
                                        self.presentAlert(withTitle: "Error", message: "An error occurred with your scan")
                                        print("Error adding document: \(err)")
                                    } else {
                                        print(Auth.auth().currentUser!.uid + " scanned" + self.scanned_info["UID"]!)
                                        
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
        super.viewDidAppear(animated)
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(downSwipe(sender:)))
        downSwipe.direction = .up
        view.addGestureRecognizer(downSwipe)
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(holdDown(sender:)))
        view.addGestureRecognizer(holdGesture)
    }

    
    
    @objc func downSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            print("Swiped up")
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
        if segue.destination is ScannedViewController {
            //Pass user object
            let scanned_controller = segue.destination as? ScannedViewController
            scanned_controller?.scanned_info = scanned_info
        }
        if self.flashOn {
            let _ = self.toggleTorch(on: false)
            self.flashlight.image = UIImage(systemName: "flashlight.off.fill")
            self.flashlight.tintColor = .white
            self.flashOn = false
        }
        
    }
    
    
    
    

    

}

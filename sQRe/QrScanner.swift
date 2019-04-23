//
//  QrScanner.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/26/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit
import AVFoundation

class QrScanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var video = AVCaptureVideoPreviewLayer()
    var scanned_info = Dictionary<String, String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        session.startRunning()
        // Do any additional setup after loading the view.
    }
    //TODO: Need to figure out how to only allow sQRe qr codes...
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects != nil && metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    if let validData = object.stringValue?.data(using: .utf8) {
                        do {
                            scanned_info = try JSONDecoder().decode([String:String].self,from:validData)
                            //prepare for segue
                            self.performSegue(withIdentifier: "scannedSegue", sender: self)
                        } catch {
                            
                        }
                    }
                    
                    
                }
            }
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
    }
    

}

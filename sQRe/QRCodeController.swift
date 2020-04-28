//
//  QRCodeController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase

class QRCodeController: UIViewController {
    var mediaDict: [String: String] = [:]
    @IBOutlet weak var qrView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var score: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //qrView.image = UIImage(ciImage: generateQr(medias: getMediaInfo(selected: selected))!)
        //add Score here

        name.text = Auth.auth().currentUser?.displayName
        qrView.image = UIImage(ciImage: self.generateQr(medias: mediaDict)!)
        qrView.layer.magnificationFilter = CALayerContentsFilter(rawValue: kCISamplerFilterNearest)
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.score.text = String(document.data()!["Score"] as! Int)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func generateQr(medias : Dictionary<String, String>) -> CIImage? {
           let dict = medias
           
           do {
               let data = try JSONEncoder().encode(dict)
               if let validData = String(data: data,encoding: .utf8){
                   print(validData)
               }
               
               if let filter = CIFilter(name: "CIQRCodeGenerator"){
                   filter.setValue(data, forKey: "inputMessage")
                   filter.setValue("Q", forKey: "inputCorrectionLevel")
                   let transform = CGAffineTransform(scaleX: 5, y: 5)
                   if let output = filter.outputImage?.transformed(by: transform){
                       return output
                   }
               }
           } catch {
               print(error.localizedDescription)
           }
           return nil
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

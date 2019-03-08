//
//  QRCodeController.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit

class QRCodeController: UIViewController {
    var user: User?
    var qrImage: CIImage!
    @IBOutlet weak var qrView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrView.image = user?.generateQr()
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

//
//  ViewScannedCell.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/18/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit

class ViewScannedCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}

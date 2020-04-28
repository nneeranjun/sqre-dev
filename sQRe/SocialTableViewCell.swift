//
//  SocialViewCellTableViewCell.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 1/18/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Contacts

class SocialTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mediaLogo: UIImageView!
    
    @IBOutlet weak var mediaTag: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

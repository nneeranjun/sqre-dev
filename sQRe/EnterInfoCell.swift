//
//  EnterInfoCell.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/30/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit

class EnterInfoCell: UITableViewCell {
    @IBOutlet weak var mediaTag: UILabel!
    @IBOutlet weak var mediaLogo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

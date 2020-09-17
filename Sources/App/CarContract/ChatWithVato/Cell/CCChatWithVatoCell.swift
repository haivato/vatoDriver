//
//  CCChatWithVatoCell.swift
//  FC
//
//  Created by Phan Hai on 31/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class CCChatWithVatoCell: UITableViewCell {
    @IBOutlet weak var lbContentChat: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

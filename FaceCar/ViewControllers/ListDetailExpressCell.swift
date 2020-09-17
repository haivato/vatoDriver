//
//  ListDetailExpressCell.swift
//  FC
//
//  Created by MacbookPro on 11/5/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ListDetailExpressCell: UITableViewCell {

    @IBOutlet weak var icExpress: UIImageView!
    @IBOutlet weak var viewStatusTrip: UIView!
    @IBOutlet weak var icTripStatus: UIImageView!
    @IBOutlet weak var lbTripStatus: UILabel!
    @IBOutlet weak var vLineAbove: UIView!
    @IBOutlet weak var lbNameClient: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var heightIMGStatusTrip: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        heightIMGStatusTrip.constant = 18
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

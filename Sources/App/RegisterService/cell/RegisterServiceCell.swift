//
//  RegisterServiceCell.swift
//  FC
//
//  Created by MacbookPro on 4/27/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class RegisterServiceCell: UITableViewCell {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lbNameCar: UILabel!
    @IBOutlet weak var lbNumberCar: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            imgCheck.image = UIImage(named: "ic_form_checkbox_checked")
            self.vContent.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
        } else {
            imgCheck.image = UIImage(named: "ic_form_checkbox_uncheck")
            self.vContent.backgroundColor = .white
        }
    }
    func updateUI (model: CarInfo) {
        self.lbNameCar.text = model.marketName
        self.lbNumberCar.text = model.plate
    }
    
}

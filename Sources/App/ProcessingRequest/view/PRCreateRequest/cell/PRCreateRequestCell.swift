//
//  CreateRequestCell.swift
//  FC
//
//  Created by MacbookPro on 4/3/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

enum TypeRegisterServiceCell {
    case processRequest
    case registerService
}

class PRCreateRequestCell: UITableViewCell {

    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbNew: UILabel!
    @IBOutlet weak var lbNoteImage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lbNoteImage.text = ""
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
    
    func updateUI(model: ListServiceVehicel) {
        self.lbTitle.text = model.displayName
        if let isNew = model.isNew {
             self.lbNew.text = (isNew) ? "MỚI" : ""
        }
        if model.status == .APPROVE {
            self.vContent.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9803921569, alpha: 1)
            self.imgCheck.image = UIImage(named: "ic_checked_light")
        } else {
            self.imgCheck.image = UIImage(named: "ic_form_checkbox_uncheck")
            self.vContent.backgroundColor = .white
        }
        
    }
    
}

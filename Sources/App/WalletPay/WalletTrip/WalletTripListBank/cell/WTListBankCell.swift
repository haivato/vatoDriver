//
//  WTListBankCell.swift
//  FC
//
//  Created by MacbookPro on 5/22/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class WTListBankCell: UITableViewCell {

    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var nameBank: UILabel!
    @IBOutlet weak var lbContentBank: UILabel!
    @IBOutlet weak var imgBank: UIImageView!
    @IBOutlet weak var vContent: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgBank.clipsToBounds = true
        imgBank.layer.cornerRadius = imgBank.frame.size.height / 2
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
    func updateUI(model: BankInfoServer) {
        nameBank.text = model.bankShortName
        lbContentBank.text = model.bankName
        imgBank.kf.setImage(with: model.icon)
    }
    
}

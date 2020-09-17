//
//  WalletTripCell.swift
//  FC
//
//  Created by MacbookPro on 5/20/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Kingfisher
import Eureka
import FwiCoreRX
import FwiCore
import SnapKit

class WalletTripCell: Eureka.Cell<String>, CellType, UITextFieldDelegate {

    @IBOutlet weak var vLineLeading: NSLayoutConstraint!
    @IBOutlet weak var imgBank: UIImageView!
    @IBOutlet weak var lbNameBank: UILabel!
    @IBOutlet weak var imgInvaild: UIImageView!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var vContent: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgBank.clipsToBounds = true
        self.imgBank.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
               imgCheck.image = UIImage(named: "ic_form_checkbox_checked")
               self.vContent.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
            self.imgInvaild.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
           } else {
               imgCheck.image = UIImage(named: "ic_form_checkbox_uncheck")
               self.vContent.backgroundColor = .white
            self.imgInvaild.backgroundColor = .white
           }
    }
    func updateUI(model: UserBankInfo) {
        self.lbAccount.text = "Số TK: " + model.bankAccount
        self.lbNameBank.text = model.bankInfo?.bankShortName
        self.imgBank.kf.setImage(with: model.bankInfo?.icon)
        if model.verified ?? false {
            self.imgInvaild.image = UIImage(named: "ic_bank_valid")
        } else {
            self.imgInvaild.image = UIImage(named: "ic_bank_invalid")
        }
//
    }
    
}

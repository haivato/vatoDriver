//
//  FoodHeaderViewDetail.swift
//  FC
//
//  Created by MacbookPro on 4/20/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class FoodHeaderViewDetail: UIView {

    @IBOutlet weak var lbCode: UILabel!
    @IBOutlet weak var lbPromotion: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbTextPromotion: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var vNotMoney: UIView!
    @IBOutlet weak var lbNotMoney: UILabel!
    @IBOutlet weak var hviewNotMoney: NSLayoutConstraint!
    @IBOutlet weak var lbTextPromotionShip: UILabel!
    @IBOutlet weak var lbPromotionShip: UILabel!
    @IBOutlet weak var lbPaid: UILabel!
    @IBOutlet weak var vLineTotal: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lbTextPromotion.text = "Khuyến mãi"
        lbPromotion.text = "\(0.currency)"
        lbNotMoney.textColor = #colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        vNotMoney.clipsToBounds = true
        lbTextPromotionShip.text = ""
        lbTextPromotionShip.sizeToFit()
        lbTextPromotionShip.adjustsFontSizeToFitWidth = true
        lbPaid.text = ""
    }
    
    func updateUI(item: FCBooking) {
        
    }

}

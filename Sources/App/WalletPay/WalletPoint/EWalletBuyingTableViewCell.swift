//
//  EWalletBuyingTableViewCell.swift
//  FC
//
//  Created by admin on 5/19/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit


class EWalletBuyingTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var hLabel: UILabel!
    @IBOutlet weak var tLabel: UILabel!
    @IBOutlet weak var indicator: UIButton!
    @IBOutlet weak var radioImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        radioImage.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayCell(_ type: PaymentCardType) {
        tLabel.isHidden = true
        switch type {
        case .atm:
            imgView.image = #imageLiteral(resourceName: "ic_napas_atm")
            hLabel.text = "Liên kết thẻ nội địa ATM"
        case .visa:
            imgView.image = #imageLiteral(resourceName: "ic_napas_visa")
            hLabel.text = "Liên kết thẻ Visa/ Master/ JCB"
        default:
            break
        }
    }
    
    func displayCell(tu: TopUpMethod, balance: Double?) {
       
        tLabel.isHidden = true
        hLabel.text = tu.name
        imgView.image = UIImage(named: tu.topUpType?.imgLocal ?? "")
        
        if tu.topUpType == TopupType.none {
            tLabel.isHidden = false
            tLabel.text = "Số dư khả dụng: " +  (balance ?? 0).currency
        }
    }
    
    func displayCell(ca: Card) {
        imgView.image = UIImage(named: ca.type.imgLocal)

        hLabel.text = ca.brand
        tLabel.isHidden = false
//        let number = ca.number ?? ""
//        let last = number.prefix(4)
//        let text = "**** \(last)"
        tLabel.text = ca.number
    }
    
    func displayCell(_ element: Any, balance: Double?) {
        if let topup = element as? TopUpMethod {
            displayCell(tu: topup, balance: balance)
        }
        if let card = element as? Card {
            displayCell(ca: card)
        }
    }
}

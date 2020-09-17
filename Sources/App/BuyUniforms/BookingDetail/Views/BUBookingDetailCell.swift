//
//  BUBookingDetailCell.swift
//  FC
//
//  Created by vato. on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka

final class BUBookingDetailCellEureka: Row<BUBookingDetailCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<BUBookingDetailCell>(nibName: "BUBookingDetailCell")
    }
}

class BUBookingDetailCell: Eureka.Cell<String>, CellType {
    typealias Value = String
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var btnChangeMethod: UIButton?
    @IBOutlet weak var lblMethod: UILabel?
    @IBOutlet weak var bgMethod: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func display(mBasket: BasketModel) {
        let views = stackView.arrangedSubviews
        if !views.isEmpty {
            views.forEach { (v) in
                stackView.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
        }
        var totalPrice: Double  = 0
        mBasket.forEach { (item) in
            let v = BUInfoOrderView.loadXib()
            v.titleLabel.text = item.key.name
            v.quantityLabel.text = "x\(item.value.quantity)"
            let price = Double(item.value.quantity) * (item.key.finalPrice ?? 0)
            totalPrice += price
            v.priceLabel.text = price.currency
            stackView.addArrangedSubview(v)
        }
        
        self.priceLabel.text = totalPrice.currency
        
    }
    
}

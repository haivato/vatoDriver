//
//  FoodPriceTableViewCell.swift
//  FC
//
//  Created by vato. on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka

final class FoodPriceCellEureka: Row<FoodPriceTableViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<FoodPriceTableViewCell>(nibName: "FoodPriceTableViewCell")
    }
}

class FoodPriceTableViewCell: Eureka.Cell<String>, CellType {
    typealias Value = String
    
    @IBOutlet weak var promotionLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        promotionLabel.text = 0.currency
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func display(booking: FCBookInfo?) {
        let str = booking?.embeddedPayload
        let model = FoodOderModel.decodeFromString(string: str)
        let price = (model?.grandTotal ?? 0) - (model?.feeShip ?? 0)
        totalPriceLabel.text = max(price, 0).currency
    }
}

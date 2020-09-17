//
//  FoodAddressTableViewCell.swift
//  FC
//
//  Created by vato. on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka

final class FoodAddressCellEureka: Row<FoodAddressTableViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<FoodAddressTableViewCell>(nibName: "FoodAddressTableViewCell")
    }
}

class FoodAddressTableViewCell: Eureka.Cell<String>, CellType {
    typealias Value = String
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func display(booking: FCBookInfo) {
        pickupLabel.text = booking.startAddress
        destinationLabel.text = booking.endAddress
    }
}

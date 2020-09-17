//
//  FoodListItemTableViewCell.swift
//  FC
//
//  Created by vato. on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka

final class FoodListItemCellEureka: Row<FoodListItemTableViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<FoodListItemTableViewCell>(nibName: "FoodListItemTableViewCell")
    }
}

class FoodListItemTableViewCell: Eureka.Cell<String>, CellType {
    typealias Value = String
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func display(booking: FCBookInfo?) {
        let str = booking?.embeddedPayload
        let model = FoodOderModel.decodeFromString(string: str)
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        model?.orderItems?.forEach { (item) in
            let v = FoodItemView.loadXib()
            v.display(item: item)
            stackView.addArrangedSubview(v)
        }
    }
    
}

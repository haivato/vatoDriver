//
//  FoodNoteTableViewCell.swift
//  FC
//
//  Created by vato. on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka

final class FoodNoteCellEureka: Row<FoodNoteTableViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<FoodNoteTableViewCell>(nibName: "FoodNoteTableViewCell")
    }
}

class FoodNoteTableViewCell: Eureka.Cell<String>, CellType {
    typealias Value = String
    
    @IBOutlet weak var noteLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func display(text: String?) {
        noteLable.text = text
    }
}

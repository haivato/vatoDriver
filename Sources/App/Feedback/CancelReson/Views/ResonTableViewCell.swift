//
//  ResonTableViewCell.swift
//  FC
//
//  Created by vato. on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka

final class ResonCellEureka: Row<ResonTableViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<ResonTableViewCell>(nibName: "ResonTableViewCell")
    }
}

class ResonTableViewCell: Eureka.Cell<String>, CellType {
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imgCheck?.image = UIImage(named: isSelected ? "ic_check-1" : "ic_uncheck-1" )
        // Configure the view for the selected state
    }
    
}

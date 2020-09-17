//
//  NoteTableViewCell.swift
//  FC
//
//  Created by vato. on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka

final class NoteCellEureka: Row<NoteTableViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<NoteTableViewCell>(nibName: "NoteTableViewCell")
    }
}

class NoteTableViewCell: Eureka.Cell<String>, CellType {
    typealias Value = String
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imgCheck?.image = UIImage(named: isSelected ? "ic_check-1" : "ic_uncheck-1" )
//        self.textView.isHidden = !selected
        self.textView.alpha = selected ? 1 : 0.3
        self.textView.isUserInteractionEnabled = selected ? true : false
        // Configure the view for the selected state
    }
    
}

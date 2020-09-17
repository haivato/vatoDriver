//
//  QuickSupportTVC.swift
//  FC
//
//  Created by khoi tran on 1/14/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class QuickSupportTVC: UITableViewCell, UpdateDisplayProtocol {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), position: .bottom)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupDisplay(item: QuickSupportRequest?) {
        self.titleLabel.text = "\(item?.index ?? 1). " + (item?.title ?? "")
        self.descriptionLabel.text = item?.description
    }
}

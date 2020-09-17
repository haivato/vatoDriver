//
//  PlaceTableHeaderView.swift
//  NowCRM
//
//  Created by tksu on 10/11/18.
//  Copyright © 2018 foody. All rights reserved.
//

import UIKit

class PlaceTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
    
    func displayWithText(text: String) {
        self.titleLabel.text = text
    }
}

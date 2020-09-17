//
//  QSResponseTVC.swift
//  FC
//
//  Created by khoi tran on 1/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import SnapKit

class QSResponseTVC: UITableViewCell, UpdateDisplayProtocol {

    private lazy var responseView = QSResponseView.loadXib()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        responseView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupDisplay(item: QuickSupportItemResponse?) {
        guard let it = item else {
            return
        }
        
        responseView.setupDisplay(item: it)
        responseView.layoutIfNeeded()
        self.contentView.layoutIfNeeded()
    }
}

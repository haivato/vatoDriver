//
//  QuickResponseView.swift
//  FC
//
//  Created by khoi tran on 1/16/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Kingfisher

class QSResponseView: UIView, UpdateDisplayProtocol {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupDisplay(item: QuickSupportItemResponse?) {
        
        self.titleLabel.text = item?.fullName
        self.messageLabel.text = item?.content
        if let createdDate = item?.createdAt {
            createdAtLabel.text = createdDate.string(from: "HH:mm dd/MM/yyyy")
        }
        
        avatarImageView.image = UIImage(named: "avatar-placeholder")
        if let avatarUrl = item?.avatarUrl,
            let url = URL(string: avatarUrl) {
            avatarImageView.kf.setImage(with: url)
        }
    }
}

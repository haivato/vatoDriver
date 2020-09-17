//
//  QSRequestTVC.swift
//  FC
//
//  Created by khoi tran on 1/15/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Kingfisher

class QSRequestTVC: UITableViewCell, UpdateDisplayProtocol {
    @IBOutlet weak var requesTitleLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var requestMessageLabel: UILabel!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var requestImageView: UIView!
    
    @IBOutlet weak var responseStackView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        codeLabel.text = ""
        // Configure the view for the selected state
    }
    
    func setupDisplay(item: QuickSupportModel?) {
        requesTitleLabel.text = item?.title
        if let createdDate = item?.createdAt {
            createdDateLabel.text = createdDate.string(from: "HH:mm dd/MM/yyyy")
        }
        
        requestMessageLabel.text = item?.content
        statusLabel.text = item?.status?.string()
        statusLabel.textColor = item?.status?.titleColor()
        statusView.backgroundColor = item?.status?.bgColor()
        
        if let images = item?.images, !images.isEmpty {
            requestImageView.isHidden = false
            for view in imageStackView.arrangedSubviews {
                imageStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            for image in images {
                let options: KingfisherOptionsInfo = [.fromMemoryCacheOrRefresh, .transition(.fade(0.3))]
                let imageView = UIImageView.create {
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                    $0.cornerRadius = 6
                    $0.kf.setImage(with: URL(string: image), placeholder: nil, options: options)
                    $0.snp.makeConstraints { (make) in
                        make.width.equalTo(80)
                    }
                }
                
                imageStackView.addArrangedSubview(imageView)
            }
        } else {
            requestImageView.isHidden = true
        }
        
        if let response = item?.lastComment {
            responseStackView.isHidden = false
            for view in responseStackView.arrangedSubviews {
                imageStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            let view = QSResponseView.loadXib()
            view.setupDisplay(item: response)
            responseStackView.addArrangedSubview(view)
        } else {
            responseStackView.isHidden = true
        }
    }
}


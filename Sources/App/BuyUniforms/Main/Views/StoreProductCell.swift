//  File name   : StoreProductCell.swift
//
//  Author      : Dung Vu
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol StoreProductDisplayProtocol: ImageDisplayProtocol {
    var name: String? { get }
    var description: String? { get }
    var productPrice: Double? { get }
    var price: Double? { get }
}

class StoreProductCell<E: Equatable>: Eureka.Cell<E>, CellType, UpdateDisplayProtocol where E: StoreProductDisplayProtocol {
    var lblTitle: UILabel?
    var lblDescription: UILabel?
    var lblPrice: UILabel!
    var productImageView: UIImageView!
    var stackView: UIStackView!
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        let productImageView = UIImageView(frame: .zero)
        productImageView >>> contentView >>> {
            $0.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 6
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 96, height: 96))
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.bottom.equalTo(-16).priority(.high)
            })
        }
        self.productImageView = productImageView
        let lblTitle = UILabel(frame: .zero)
        lblTitle >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        self.lblTitle = lblTitle
        
        let lblDescription = UILabel(frame: .zero)
        lblDescription >>> {
            $0.numberOfLines = 2
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
        self.lblDescription = lblDescription
        
        let stackView = UIStackView(arrangedSubviews: [lblTitle, lblDescription])
        stackView >>> contentView >>> {
            $0.distribution = .fillProportionally
            $0.axis = .vertical
            $0.spacing = 4
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(productImageView.snp.top)
                make.left.equalTo(productImageView.snp.right).offset(16)
                make.right.equalTo(-16)
            })
        }
        self.stackView = stackView
        
        let lblPrice = UILabel(frame: .zero)
        lblPrice >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            
            $0.snp.makeConstraints({ (make) in
                make.bottom.equalTo(productImageView.snp.bottom)
                make.left.equalTo(stackView.snp.left).priority(.high)
            })
        }
        self.lblPrice = lblPrice
        
    }
    
    func setupDisplay(item: E?) {
        lblTitle?.text = item?.name
        lblDescription?.text = item?.description
        lblPrice?.text = "\(item?.price?.roundPrice().currency ?? "")"
        productImageView?.setImage(from: item, placeholder: nil, size: CGSize(width: 96, height: 96))
    }
}

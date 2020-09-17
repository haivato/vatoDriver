//  File name   : StoreProductSelectCell.swift
//
//  Author      : Dung Vu
//  Created date: 11/22/19
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

final class StoreProductSelectCell: UITableViewCell, UpdateDisplayProtocol {
    private var lblTitle: UILabel?
    private var lblDescription: UILabel?
    private var lblPrice: UILabel!
    private var productImageView: UIImageView!
    private var stackView: UIStackView!
    private (set) var editView: StoreEditMenuView!
    private (set) var btnEdit: UIButton!
    private lazy var disposeBag = DisposeBag()
    private (set) lazy var lblQuantity: UILabel = UILabel(frame: .zero)
    private lazy var lblSpecialPrice: UILabel = UILabel(frame: .zero)
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        
        
        self.addSeperator(with: UIEdgeInsets(top: 0, left: 128, bottom: 0, right: 0), position: .bottom)
        let editView = StoreEditMenuView(frame: .zero)
        editView.setContentHuggingPriority(.required, for: .horizontal)
        editView.setContentCompressionResistancePriority(.required, for: .horizontal)
//        editView.isSelected = false
        
        editView >>> {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.height.equalTo(28)
            })
        }
        self.editView = editView
        lblPrice >>> {
            $0.lineBreakMode = .byTruncatingMiddle
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        lblQuantity >>>  {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        }
        
        let s1 = UIStackView(arrangedSubviews: [lblPrice, lblQuantity, editView])
        s1 >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.alignment = .bottom
            $0.spacing = 5
        }
        
        let s2 = UIStackView(arrangedSubviews: [lblSpecialPrice, s1])
        s2 >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 0
            
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(stackView.snp.left)
                make.bottom.right.equalTo(-16)
            }
        }
        
        setupRX()
    }
    
    private func setupRX() {
        
    }
    
    func display(item: DisplayProduct, number: BasketStoreValueProtocol?) {
//        self.editView.isSelected = number != nil
        let number = number?.quantity ?? 0
        self.lblQuantity.text = number > 0 ? "x\(number)" : ""
    }
    
     func setupDisplay(item: DisplayProduct?) {
        lblTitle?.text = item?.name
        lblDescription?.text = item?.description
        lblPrice?.text = "\(item?.price?.roundPrice().currency ?? "")"
        productImageView?.setImage(from: item, placeholder: nil, size: CGSize(width: 96, height: 96))
        
        let isSpecial = item?.isAppliedSpecialPrice ?? false
        lblSpecialPrice.isHidden = !isSpecial
        let text = item?.productPrice?.currency ?? ""
        let att = text.attribute >>>
            .font(f: UIFont.systemFont(ofSize: 12, weight: .regular)) >>> .color(c: Color.battleshipGrey) >>> .strike(v: 1)
        lblSpecialPrice.attributedText = att
    }
}


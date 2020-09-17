//  File name   : TopupRow.swift
//
//  Author      : Dung Vu
//  Created date: 11/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Eureka


struct TopupCellModel: Equatable {
    let item: TopupLinkConfigureProtocol
    
    var card: Card?
    
    static func ==(lhs: TopupCellModel, rhs: TopupCellModel) -> Bool {
        return lhs.item.type == rhs.item.type
    }
}

final class TopupCell: Cell<TopupCellModel>, CellType {
    
    // MARK: Class's public methods
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
    }

    
    override func setup() {
        super.setup()
        
        // General setup
        height = { return 64.0 }
        backgroundColor = .clear
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil
//        separatorInset = .zero
        separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
        
        borderImageView >>> contentView >>> {
            $0.backgroundColor = EurekaConfig.separatorColor
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(15.0)
                $0.trailing.equalToSuperview()
                $0.height.equalTo(1.0)
                $0.bottom.equalToSuperview()
            }
        }
        borderImageView.isHidden = true
        
        bankSelectView >>> contentView >>> {
            $0.isExclusiveTouch = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    override func update() {
        super.update()
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil
        backgroundColor = .white
        if row.value?.item is DummyMethodProtocol {
            var imgName = ""
            if let type = row.value?.item.topUpType {
                if type == .momoPay {
                    imgName = "ic_momo"
                } else if type == .zaloPay {
                    imgName = "zalo"
                } else if type == .none {
                    imgName = "ic_wallet_cash"
                }
            }
            if let _ = row.value?.card?.brand, let cardType = row.value?.card?.type {
                if cardType == .atm {
                    imgName = "ic_napas_atm"
                } else if cardType == .visa {
                    imgName = "ic_napas_visa"
                }
                else if cardType == .master {
                   imgName = "ic_mastercard"
                }
            }
            bankSelectView.iconImg?.image = UIImage(named: imgName)
            
        } else {
            bankSelectView.urlImage = URL.init(withOptional: row.value?.item.iconURL)
        }
        
        bankSelectView.title = row.value?.item.name
        if let n = row.value?.card?.number {
            bankSelectView.subTitle = n
        }
    }
    
    func updateSubTitle(sTitle: String) {
        bankSelectView.subTitle = sTitle
    }

    
    /// Class's private properties
    private lazy var borderImageView = UIImageView(image: nil)
    private (set)lazy var bankSelectView = BankSelectControl(with: nil, title: nil, isSelected: false)
}


final class TopupRow: Row<TopupCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
    }
    
    func hide(arrow hidding: Bool) {
        cell.bankSelectView.arrowImg?.isHidden = hidding
    }
}

extension URL {
     init?(withOptional path: String?) {
        guard let v = path else {
            return nil
        }
        self.init(string: v)
    }
}

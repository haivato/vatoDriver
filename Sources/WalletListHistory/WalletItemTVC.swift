//  File name   : WalletItemTVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit

extension WalletItemDisplayProtocol {
    var prefix: String {
        guard amount > 0 else {
            return ""
        }
        return increase ? "+" : "-"
    }
    
    var color: UIColor {
        return increase ? #colorLiteral(red: 0, green: 0.4235294118, blue: 0.2392156863, alpha: 1) : #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
    }
}

final class WalletItemTVC: UITableViewCell {

    private var lblTitle: UILabel?
    private var lblDescription: UILabel?
    private var lblPrice: UILabel?
    private var lblDate: UILabel?
    
    /// Class's public properties.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup() {
        let lblDate = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(16)
                })
        }
        
        self.lblDate = lblDate
        
        let lblPrice = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textAlignment = .right
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.right.equalTo(-16)
                    make.top.equalTo(16)
                })
        }
        
        self.lblPrice = lblPrice
        
        let lblDescription = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            $0.numberOfLines = 2
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblDate.snp.bottom).offset(12)
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalTo(-12).priority(.high)
                })
        }
        self.lblDescription = lblDescription
    }

    
    func setupDisplay(by item: WalletItemDisplayProtocol) {
        let date = Date(timeIntervalSince1970: item.transactionDate / 1000)
        self.lblDate?.text = date.string(from: "HH:mm") + " | ID: \(item.id)"
        self.lblPrice?.textColor = item.color
        self.lblPrice?.text = "\(item.prefix)\(item.amount.currency)"
        self.lblTitle?.text = item.title
        self.lblDescription?.text = item.description
//        self.contentView.layoutSubviews()
//        let delta = (self.lblPrice?.bounds.width ?? 0) + 42
//        self.lblDescription?.snp.updateConstraints({ (make) in
//            make.right.equalTo(-delta)
//        })
        
        
    }
}

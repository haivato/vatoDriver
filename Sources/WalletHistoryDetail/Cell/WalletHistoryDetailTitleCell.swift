//  File name   : WalletHistoryDetailTitleCell.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Eureka
import SnapKit

struct WalletHistoryItemDisplay: Equatable {
    let title: String
    let value: String
    let color: UIColor?
}

class WalletHistoryDetailBaseCell: Cell<WalletHistoryItemDisplay>, CellType {
    lazy var lblTitle: UILabel = UILabel(frame: .zero)
    lazy var lblValue: UILabel = UILabel(frame: .zero)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.textLabel?.isHidden = true
        self.detailTextLabel?.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        height = { return UITableView.automaticDimension }
    }
    
    override func update() {
        super.update()
        let v = self.row.value
        lblTitle.text = v?.title
        lblValue.text = v?.value
        if let color = v?.color {
            lblValue.textColor = color
        }
    }
}

final class WalletHistoryDetailTitleCell: WalletHistoryDetailBaseCell {
    override func setup() {
        super.setup()
        self.contentView.backgroundColor = .white
        lblTitle >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.textAlignment = .center
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(21)
                })
        }
        
        lblValue >>> {
            $0.font = UIFont.boldSystemFont(ofSize: 32)
            $0.textColor = #colorLiteral(red: 0, green: 0.4235294118, blue: 0.2392156863, alpha: 1)
            $0.textAlignment = .center
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(lblTitle.snp.bottom).offset(15)
                    make.bottom.equalToSuperview().offset(-32).priority(.high)
                })
        }
    }
}

final class WalletHistoryDetailItemCell: WalletHistoryDetailBaseCell {
    override func setup() {
        super.setup()
        height = { return 56 }
        lblTitle >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.textAlignment = .left
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(16)
                })
        }
        
        lblValue >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .black
            $0.textAlignment = .right
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.centerY.equalToSuperview()
                    make.right.equalTo(-16)
                })
        }
    }
}

final class WalletHistoryDetailDescriptionCell: WalletHistoryDetailBaseCell {
    override func setup() {
        super.setup()
        lblTitle >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .black
            $0.textAlignment = .left
            $0.numberOfLines = 0
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(21)
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalToSuperview().offset(-21).priority(.high)
                })
        }
    }
}



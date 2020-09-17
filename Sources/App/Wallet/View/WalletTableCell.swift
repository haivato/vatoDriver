//  File name   : WalletTableCell.swift
//
//  Author      : Dung Vu
//  Created date: 5/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore
import SnapKit
import RxSwift
import Eureka

enum WalleCellType: Int, CaseIterable {
    case cash
    case credit
    case reward
    case promotion
    
    static var allCases: [WalleCellType] {
        return [.cash, .credit]
    }
    
    var description: (title: String, sub: String, icon: String) {
        switch self {
        case .cash:
            return ("Doanh thu chuyến đi", "Có thể rút được", "ic_wallet_cash")
        case .credit:
            return ("Điểm nhận chuyến", "Mua điểm để nhận chuyến", "ic_wallet_point")
        case .reward:
            return ("Điểm thưởng", "Được quy đổi thành doanh thu (Tích luỹ theo chương trình thưởng của VATO", "ic_wallet_promotion")
        case .promotion:
            return ("Khuyến mãi", "Được thanh toán thành doanh thu (sau khi soát xét gian lận)", "ic_wallet_reward")
        
        }
    }
}

final class WalletTableCell: Eureka.Cell<WalleCellType>, CellType, UpdateDisplayProtocol {
    private lazy var iconView = UIImageView(frame: .zero)
    private lazy var lblTitle = UILabel(frame: .zero)
    private lazy var lblMoney = UILabel(frame: .zero)
    private lazy var lblDescription = UILabel(frame: .zero)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        iconView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints { (make) in
                make.left.top.equalTo(16)
                make.size.equalTo(CGSize(width: 48, height: 48))
            }
        }
        
        let arrowView = UIImageView(frame: .zero)
        arrowView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-8)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
        }
        
        lblTitle >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        lblMoney >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        lblDescription >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.numberOfLines = 0
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblTitle, lblMoney, lblDescription])
        
        stackView >>> contentView >>> {
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 4
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(iconView.snp.top)
                make.left.equalTo(iconView.snp.right).offset(16).priority(.high)
                make.right.equalTo(arrowView.snp.left).offset(-16).priority(.high)
                make.bottom.equalTo(-16).priority(.high)
            }
        }
    }
    
    func setupDisplay(item: WalleCellType?) {
        guard let i = item?.description else { return }
        iconView.image = UIImage(named: i.icon)
        lblTitle.text = i.title
        lblMoney.text = "-"
        lblDescription.text = i.sub
    }
}


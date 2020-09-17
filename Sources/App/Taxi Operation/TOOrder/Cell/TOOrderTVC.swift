//  File name   : TOOrderTVC.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore

final class TOOrderTVC: UITableViewCell, UpdateDisplayProtocol {
    /// Class's public properties.
    private lazy var lblLocation: UILabel = UILabel(frame: .zero)
    private lazy var lblDescription: UILabel = UILabel(frame: .zero)
    private lazy var arrowView: UIImageView = UIImageView(image: UIImage(named: "ic_chevron_right"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        arrowView >>> contentView >>> {
            $0.contentMode = .center
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
                make.right.equalTo(-16)
                make.centerY.equalToSuperview()
            }
        }
        
        lblLocation >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
        
        lblDescription >>> {
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
    
        let stackView = UIStackView(arrangedSubviews: [lblLocation, lblDescription])
        
        stackView >>> contentView >>> {
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 3
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.bottom.equalTo(-16)
                make.right.equalTo(arrowView.snp.left).offset(-5)
            }
        }
        
    }
    
    /// Class's private properties.
    func setupDisplay(item: TOOrderProtocol?) {
        lblLocation.text = item?.nameLocation
        lblDescription.attributedText = item?.attribute
    }
}


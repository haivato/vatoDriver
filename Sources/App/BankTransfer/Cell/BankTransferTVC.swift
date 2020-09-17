//  File name   : BankTransferTVC.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class BankTransferTVC: UITableViewCell {
    /// Class's public properties.
    private(set) lazy var iconImageView = UIImageView()
    private(set) lazy var titleLabel = UILabel()

    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }

    /// Class's private properties.
}

// MARK: Class's public methods
extension BankTransferTVC {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }
}

// MARK: Class's private methods
private extension BankTransferTVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none

        imageView?.isHidden = true
        textLabel?.isHidden = true

        iconImageView >>> contentView >>> { $0.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 44, height: 44))
        }}

        titleLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16.0)

            $0.snp.makeConstraints {
                $0.centerY.equalTo(iconImageView)
                $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
                $0.trailing.equalToSuperview()
            }
        }
    }
}

//  File name   : BankPushCell.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

final class BankPushCell: PushSelectorCell<BankInfo> {
    /// Class's public properties.
    private(set) lazy var titleLabel = UILabel()

    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
    }

    // MARK: Class's public methods
    override func setup() {
        super.setup()

        // General setup
        height = EurekaConfig.defaultHeight
        backgroundColor = .clear
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil

        borderImageView >>> contentView >>> {
            $0.backgroundColor = EurekaConfig.separatorColor
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(15.0)
                $0.trailing.equalToSuperview()
                $0.height.equalTo(1.0)
                $0.bottom.equalToSuperview()
            }
        }

        detailLabel >>> contentView >>> {
            $0.font = EurekaConfig.detailFont
            $0.textColor = EurekaConfig.detailColor
            $0.snp.makeConstraints {
                $0.leading.equalTo(borderImageView.snp.leading)
                $0.bottom.equalTo(borderImageView.snp.top)
                $0.width.greaterThanOrEqualTo(0.0)
                $0.height.equalTo(30.0)
            }
        }

        titleLabel >>> contentView >>> {
            $0.font = EurekaConfig.titleFont
            $0.textColor = EurekaConfig.titleColor
            $0.snp.makeConstraints {
                $0.leading.equalTo(detailLabel.snp.leading)
                $0.trailing.equalTo(detailLabel.snp.trailing)
                $0.bottom.equalTo(detailLabel.snp.top)
                $0.height.equalTo(25.0)
                $0.top.greaterThanOrEqualToSuperview()
            }
        }

        arrowImageView >>> contentView >>> {
            $0.contentMode = .center
            $0.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.top)
                $0.leading.equalTo(detailLabel.snp.trailing).offset(10.0)
                $0.trailing.equalToSuperview().inset(15.0)
                $0.bottom.equalTo(detailLabel.snp.bottom)
                $0.width.equalTo(16.0)
            }
        }
    }

    override func update() {
        super.update()
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil

        if row.isValid {
            titleLabel.text = row.title
            titleLabel.textColor = EurekaConfig.titleColor
        }
        titleLabel.font = EurekaConfig.titleFont

        detailLabel.text = row.value?.bankShortName
        detailLabel.font = EurekaConfig.detailFont
        detailLabel.textColor = EurekaConfig.detailColor
    }

    /// Class's private properties.
    private lazy var borderImageView = UIImageView(image: nil)
    private lazy var arrowImageView = UIImageView(image: #imageLiteral(resourceName: "ic_chevron_right"))
    private lazy var detailLabel = UILabel()
}

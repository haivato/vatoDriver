//  File name   : BankCell.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

class BankCellModel: Comparable, Equatable {
    var isSelected = false
    var bankInfo: BankInfo?
    var userBankInfo: UserBankInfo

    init(bankInfo: BankInfo? = nil, userBankInfo: UserBankInfo) {
        self.bankInfo = bankInfo
        self.userBankInfo = userBankInfo
    }

    static func < (lhs: BankCellModel, rhs: BankCellModel) -> Bool {
        return lhs.userBankInfo.bankCode == rhs.userBankInfo.bankCode
    }

    static func == (lhs: BankCellModel, rhs: BankCellModel) -> Bool {
        return lhs.userBankInfo.id == rhs.userBankInfo.id
    }
}

final class BankCell: Cell<BankCellModel>, CellType {

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
        height = { return 50.0 }
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

        bankSelectView >>> contentView >>> {
            $0.isExclusiveTouch = true
            $0.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalTo(borderImageView.snp.leading)
                $0.trailing.equalTo(borderImageView.snp.trailing)
                $0.bottom.equalTo(borderImageView.snp.top)
            }
        }
    }

    override func update() {
        super.update()
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil

        bankSelectView.urlImage = row.value?.bankInfo?.icon
        bankSelectView.title = row.value?.bankInfo?.bankShortName
        bankSelectView.isSelected = row.value?.isSelected ?? false
    }

    /// Class's private properties.
    private lazy var borderImageView = UIImageView(image: nil)
    private lazy var bankSelectView = BankSelectControl(with: nil, title: nil, isSelected: false)
}

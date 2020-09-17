//  File name   : BankPushRow.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import Kingfisher

final class BankPushRow: _PushRow<BankPushCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        title = "Ngân hàng"
        selectorTitle = "Chọn Ngân Hàng"
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return SelectorBankVC<SelectorRow<BankPushCell>>.init(style: .plain)
        }, onDismiss: { vc in
            let _ = vc.navigationController?.popViewController(animated: true)
        })

        onRowValidationChanged({ (cell, row) -> Void in
            if !row.isValid, let validationMessage = row.validationErrors.first?.msg {
                cell.titleLabel.textColor = .red
                cell.titleLabel.text = validationMessage
            }
        })
    }
}

final class BankSelectCell: ListCheckCell<BankInfo> {
    override var accessoryType: UITableViewCell.AccessoryType {
        set {}
        get {
            return .none
        }
    }
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        height = { return 75 }

        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 16, height: 16)))
        imageView.image = nil
        imageView.highlightedImage = #imageLiteral(resourceName: "ic_check")
        imageView.contentMode = .scaleAspectFit
     
        self.accessoryView = imageView
        
        logoImageView >>> contentView >>> {
            $0.image = #imageLiteral(resourceName: "ic_bank")
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.size.equalTo(40.0)
                $0.leading.equalToSuperview().inset(15.0)
            }
        }

        let containerView = UIView()
        containerView >>> contentView >>> { $0.snp.makeConstraints {
            $0.centerY.equalTo(logoImageView.snp.centerY)
            $0.leading.equalTo(logoImageView.snp.trailing).offset(10.0)
            $0.trailing.equalToSuperview()
        }}

        titleLabel >>> containerView >>> { $0.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }}
        detailLabel >>> containerView >>> {
            $0.numberOfLines = 2
            $0.lineBreakMode = .byWordWrapping
            $0.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(5.0)
                $0.leading.equalTo(titleLabel.snp.leading)
                $0.trailing.equalTo(titleLabel.snp.trailing)
                $0.bottom.equalToSuperview()
            }
        }
    }

    override func update() {
        super.update()

        guard let value = (row as? BankSelectRow)?.selectableValue else {
            return
        }
        logoImageView.kf.setImage(with: value.icon)

        titleLabel.text = value.bankShortName
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)

        detailLabel.text = value.bankName
        detailLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)        
        let imgView = self.accessoryView as? UIImageView
        imgView?.isHighlighted = self.row.value != nil
    }

    private lazy var logoImageView = UIImageView()
    private lazy var detailLabel = UILabel()
    private lazy var titleLabel = UILabel()
}

final class BankSelectRow: Row<BankSelectCell>, SelectableRowType, RowType {
    public var selectableValue: BankInfo?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] v in
            self.cell.row.value = v
            return nil
        }
    }
    
}

final class SelectorBankVC<OptionsRow>: SelectorViewController<OptionsRow> where OptionsRow : OptionsProviderRow,  OptionsRow.OptionsProviderType.Option == BankInfo  {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chọn ngân hàng"
        navigationItem.leftBarButtonItems = [backItem]
    }

    override func setupForm(with options: [BankInfo]) {
        self.tableView.allowsMultipleSelection = false
        let section = Section()
        defer { form +++ section }
        for option in options {
            section <<< BankSelectRow() { [weak self] in
                $0.value = (self?.row.value == option ? option : nil)
                $0.selectableValue = option

                $0.onCellSelection({ (_, row) in
                    guard let w = self else {
                        return
                    }

                    self?.row.value = row.selectableValue
                    self?.row.updateCell()
                    self?.onDismissCallback?(w)
                })
            }
        }
    }

    @IBAction func handleBackItemOnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(SelectorBankVC.handleBackItemOnPressed(_:)))
        return item
    }()
}

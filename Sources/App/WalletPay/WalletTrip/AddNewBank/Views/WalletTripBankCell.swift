//
//  WalletTripBankCell.swift
//  FC
//
//  Created by MacbookPro on 5/22/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka
import FwiCoreRX
import SnapKit
import RxCocoa
import RxSwift

class WalletTripBankCell: Eureka.Cell<String>, CellType, UITextFieldDelegate, UpdateDisplayProtocol {
    
    var didSelectAdd: (() -> Void)?
    let lblTitle: UILabel
    let textField: UITextField
    var lblStar: UILabel?
    var bgRoundView: UIView?
    var imgDropdown: UIImageView = UIImageView(image: UIImage(named: "ic_form_droplist"))
    var btPress: UIButton = UIButton(type: .custom)
    var disposeBag = DisposeBag()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle = UILabel(frame: .zero)
        textField = UITextField(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        lblTitle >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
            })
        }
        

        let _lblStar = UILabel(frame: .zero)
        _lblStar >>> contentView >>> {
            $0.textColor = UIColor.red
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.text = "*"
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalTo(lblTitle.snp.centerY)
                make.left.equalTo(lblTitle.snp.right).offset(4)
            })
        }
        self.lblStar = _lblStar
        textField >>> contentView >>> {
            $0.borderStyle = .roundedRect
            $0.cornerRadius = 8
            $0.borderWidth = 1
            $0.borderColor = #colorLiteral(red: 0.8666666667, green: 0.9254901961, blue: 0.9098039216, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(36)
                make.bottom.equalTo(-4)
            })
        }
        
        self.imgDropdown = UIImageView(image: UIImage(named: "ic_form_droplist"))
        imgDropdown >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(self.textField.snp.centerY)
                make.right.equalTo(self.textField.snp.right).inset(8)
                make.width.height.equalTo(20)
            }
        }
        
        self.btPress >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(self.textField)
            }
        }
        
    }
    
    func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
    
    func setupRX() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .valueChanged)
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .editingDidEnd)
        
        self.btPress.rx.tap.bind { _ in
            self.didSelectAdd?()
        }.disposed(by: disposeBag)
    }
    
    @objc func textChanged(sender: UITextField?) {
        row.value = sender?.text
        row.validate()
    }
    
    func setupDisplay(item: String?) {
       textField.text = item
    }
    
    override func cellResignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange: range, replacementString: string, cell: self) ?? true
    }
    
    func setText(_ text: String?) {
        textField.text = text
        textField.sendActions(for: .valueChanged)
    }
    
    func allowInput(isAllowed: Bool) {
        self.textField.isEnabled = isAllowed
    }
}

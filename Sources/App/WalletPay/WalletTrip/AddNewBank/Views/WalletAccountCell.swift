//
//  WalletAccountCell.swift
//  FC
//
//  Created by Phan Hai on 27/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka
import FwiCoreRX
import SnapKit
import RxCocoa

class WalletAccountNameCell: Eureka.Cell<String>, CellType, UITextFieldDelegate, UpdateDisplayProtocol {
    
    let lblTitle: UILabel
    let textField: UITextField
    var lblStar: UILabel?
    var bgRoundView: UIView?
    var lbNote: UILabel?
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
            })
        }
        
        let _lbNote = UILabel(frame: .zero)
        _lbNote >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.9333333333, green: 0.5882352941, blue: 0.1568627451, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.numberOfLines = 0
            $0.text = "Tên chủ tài khoản phải trùng với tên VATO và chứng minh nhân dân"
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalTo(textField)
                make.top.equalTo(textField.snp.bottom).inset(-8)
                make.bottom.equalToSuperview().inset(4)
            })
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

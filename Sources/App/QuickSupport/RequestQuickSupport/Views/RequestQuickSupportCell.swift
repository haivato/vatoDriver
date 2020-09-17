//  File name   : FillInformationCell.swift
//
//  Author      : Dung Vu
//  Created date: 8/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCoreRX
import SnapKit
import RxCocoa



typealias SelectCallback = (Int) -> Void
protocol CallbackSelectProtocol {
    func set(callback: SelectCallback?)
}

class RequestQuickSupportInputCell: Eureka.Cell<String>, CellType, UITextFieldDelegate, UpdateDisplayProtocol {
    
    let lblTitle: UILabel
    let textField: UITextField
    var lblStar: UILabel?
    var bgRoundView: UIView?
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

class RequestQuickSupportTextViewCell: Eureka.Cell<String>, CellType, UITextViewDelegate, UpdateDisplayProtocol {
    
    let lblTitle: UILabel
    let lblPlaceHolder: UILabel
    let textView: UITextView
    var lblStar: UILabel?
    var bgRoundView: UIView?
    var defaultContent: String?

    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle = UILabel(frame: .zero)
        lblPlaceHolder = UILabel(frame: .zero)
        textView = UITextView(frame: .zero)
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
        textView >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.cornerRadius = 8
            $0.borderWidth = 1
            $0.borderColor = #colorLiteral(red: 0.8666666667, green: 0.9254901961, blue: 0.9098039216, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(160)
                make.bottom.equalTo(-4)
            })
        }
        
        lblPlaceHolder >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.isUserInteractionEnabled = false
            $0.textColor = .lightGray
            $0.numberOfLines = 0
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(textView).offset(8)
                make.left.equalTo(textView).offset(4)
                make.right.equalTo(textView)
            })
        }
    }
    
    func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        lblPlaceHolder.text = placeHolder
    }
    
    func setupRX() {
        textView.delegate = self
    }
    
    func textChanged(sender: UITextView?) {
        if let text = sender?.text,
            text.count > 0 {
            lblPlaceHolder.isHidden = true
        } else {
            lblPlaceHolder.isHidden = false
        }
        row.value = sender?.text
        row.validate()
    }
    
    override func cellResignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textChanged(sender: textView)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textChanged(sender: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanged(sender: textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let defaultContent = self.defaultContent, !defaultContent.isEmpty {
            let prefixText = NSString(string: textView.text).replacingCharacters(in: range, with: text).prefix(defaultContent.count)
            if prefixText != defaultContent {
                return false
            } else {
                return formViewController()?.textInput(textView, shouldChangeCharactersInRange: range, replacementString: text, cell: self) ?? true
            }
                        
        } else {
            return formViewController()?.textInput(textView, shouldChangeCharactersInRange: range, replacementString: text, cell: self) ?? true
        }
    }
    
    func setText(_ text: String?) {
        textView.text = text
        textChanged(sender: textView)
    }
    
    func allowInput(isAllowed: Bool) {
//        self.textField.isEnabled = isAllowed
    }
    
    func setupDisplay(item: String?) {
           textView.text = item
       }
}



// MARK: - Error
final class InputDeliveryErrorCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    let lblError: UILabel
    required init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblError = UILabel(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        textLabel?.isHidden = true
        selectionStyle = .none
        lblError >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.numberOfLines = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints { make in
                make.left.equalTo(18)
                make.top.equalTo(2)
                make.right.equalToSuperview()
                make.bottom.equalTo(-3).priority(.high)
            }
        }
    }
    
    func setupDisplay(item: String?) {
        lblError.text = item
    }
}

final class InputDeliveryErrorRow: Row<InputDeliveryErrorCell>, RowType {
    override var value: String? {
        didSet {
            cell.lblError.text = value
        }
    }
}

// MARK: - Generic detail
final class RowDetailGeneric<C>: Row<C>, RowType where C: BaseCell, C: CellType, C: UpdateDisplayProtocol {

    func set(callback: SelectCallback?) {
        guard let c = cell as? CallbackSelectProtocol else { return }
        c.set(callback: callback)
    }
    
    @discardableResult
    func onChange(_ callback: @escaping (RowDetailGeneric<C>) -> Void) -> RowDetailGeneric<C> {
        return self
    }
   
}
final class RowDetailGenericWallet<C>: Row<C>, RowType where C: BaseCell, C: CellType {

    func set(callback: SelectCallback?) {
        guard let c = cell as? CallbackSelectProtocol else { return }
        c.set(callback: callback)
    }
   
}

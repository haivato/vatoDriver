//  File name   : InputAutoresize.swift
//
//  Author      : Dung Vu
//  Created date: 1/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

@IBDesignable
final class InputAutoResizeView: UITextView {
    @IBInspectable var placeholderTextColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var fade: TimeInterval = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var maxH: CGFloat = 150
    @IBInspectable var minH: CGFloat = 36.5 {
        didSet {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(minH)
            }
        }
    }
    
    var attributedPlaceholder: NSAttributedString? {
        didSet {
            guard let att = self.attributedPlaceholder else {
                return
            }
            self._placeholderTextView.attributedText = att
        }
    }
    
    private (set) lazy var disposeBag: DisposeBag = DisposeBag()
    private lazy var _placeholderTextView: UILabel = {
        let t = UILabel(frame: .zero)
        return t
    }()
    
    override var intrinsicContentSize: CGSize {
        let width = super.intrinsicContentSize.width
        return CGSize(width: width, height: contentSize.height)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        prepare()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
        setupRX()
    }
    
    private func setupLayout() {
        self.snp.makeConstraints { (make) in
            make.height.equalTo(minH)
        }
    }
    
    private func prepare() {
        let inset = self.textContainerInset
        self.addSubview(_placeholderTextView)
        self.sendSubviewToBack(_placeholderTextView)
        _placeholderTextView.isUserInteractionEnabled = false
        _placeholderTextView.snp.makeConstraints { (make) in
            make.left.equalTo(inset.left + 6)
            make.top.equalTo(inset.top)
            make.right.equalTo(-inset.right)
        }
        setupLayout()
    }
    
    private func setupPlaceHolder() {
        _placeholderTextView.font = self.font
        _placeholderTextView.textColor = self.placeholderTextColor
        if let p = placeholder {
            self.attributedPlaceholder = NSAttributedString(string: p)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupPlaceHolder()
    }
    
    private func setupRX() {
        NotificationCenter.default.rx.notification(UITextView.textDidChangeNotification).bind { [weak self](_) in
            self?.updateHeightInput()
        }.disposed(by: disposeBag)
        self.rx.text.map{ !($0?.count == 0) }.bind(to: self._placeholderTextView.rx.isHidden).disposed(by: disposeBag)
    }
    
    private func updateHeightInput() {
        let w = self.frame.width
        let newSize = self.sizeThatFits(CGSize(width: w, height: CGFloat.greatestFiniteMagnitude))
        let padding = self.textContainer.lineFragmentPadding
        var newMax = min(maxH, newSize.height + padding)
        newMax = max(minH, newMax)
        
        self.snp.updateConstraints { (make) in
            make.height.equalTo(newMax)
        }
        UIView.animate(withDuration: 0.0) {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}

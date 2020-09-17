//  File name   : StoreEditMenuView.swift
//
//  Author      : Dung Vu
//  Created date: 11/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class StoreEditMenuView: UIView, Weakifiable {
    /// Class's public properties.
    var value: Observable<Int> {
        return mValue.distinctUntilChanged()
    }
    
    private lazy var mValue: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    private lazy var stackView: UIStackView = UIStackView(frame: .zero)
    private lazy var btnAdd: UIButton = {
       let button = UIButton(frame: .zero)
       return button
    }()
    
    private lazy var lblValue: UILabel = {
        let button = UILabel(frame: .zero)
        return button
    }()
    
    private lazy var btnMinus: UIButton = {
        let button = UIButton(frame: .zero)
        return button
    }()
    private lazy var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.2)
        stackView >>> self >>> {
            $0.distribution = .fillProportionally
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 11
            $0.snp.makeConstraints({ (make) in
                make.right.bottom.top.equalToSuperview()
                make.left.equalToSuperview().priority(.high)
            })
        }
        
        btnAdd >>> {
            $0.setImage(UIImage(named: "ic_add_menu"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.width.equalTo(30)
            })
        }
        
        lblValue >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .center
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        btnMinus >>> {
            $0.setImage(UIImage(named: "ic_minus_menu"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.width.equalTo(30)
            })
        }
        
        stackView.insertArrangedSubview(btnAdd, at: 0)
    }
    
    private func handerValue() {
        let value = mValue.value
        let childs = stackView.arrangedSubviews
        lblValue.text = "\(value)"
        let layoutIfNeeded = { [unowned self] in
            self.lblValue.alpha = 0
            self.btnMinus.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.lblValue.alpha = 1
                self.btnMinus.alpha = 1
                self.layoutIfNeeded()
            })
        }
        if value > 0 {
            guard childs.count == 1 else {
                return
            }
            stackView.insertArrangedSubview(lblValue, at: 0)
            stackView.insertArrangedSubview(btnMinus, at: 0)
            
            layoutIfNeeded()
        } else {
            guard childs.count > 1 else {
                return
            }
            stackView.removeArrangedSubview(lblValue)
            lblValue.removeFromSuperview()
            
            stackView.removeArrangedSubview(btnMinus)
            btnMinus.removeFromSuperview()
            
            layoutIfNeeded()
        }
        
    }
    
    private func setupRX() {
        mValue.distinctUntilChanged().bind(onNext: weakify({ (_, wSelf) in
            wSelf.handerValue()
        })).disposed(by: disposeBag)
        
        btnAdd.rx.tap.bind(onNext: weakify({ (wSelf) in
            let c = wSelf.mValue.value
            wSelf.mValue.accept(c + 1)
        })).disposed(by: disposeBag)
        
        btnMinus.rx.tap.bind(onNext: weakify({ (wSelf) in
            let c = wSelf.mValue.value
            wSelf.mValue.accept(max(0, c - 1))
        })).disposed(by: disposeBag)
    }
    
    /// Class's private properties.
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = self.bounds.height
        layer.cornerRadius = h / 2
        clipsToBounds = true
    }
    
    func updateValue(v: Int) {
        mValue.accept(v)
    }
}


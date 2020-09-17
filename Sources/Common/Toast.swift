//  File name   : Toast.swift
//
//  Author      : Dung Vu
//  Created date: 10/29/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import SnapKit

final class Toast: UIView {
    /// Class's public properties.
    convenience init(using message: String?, on view: UIView?, layout block: (Toast) -> ()) {
        self.init(frame: .zero)
        self.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8)
        self.cornerRadius = 4
        let lblMessage: UILabel = UILabel(frame: .zero)
        lblMessage.numberOfLines = 0
        lblMessage.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lblMessage.textColor = .white
        lblMessage >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(8)
                make.bottom.equalTo(-8).priority(.low)
                make.left.equalTo(5)
                make.right.equalTo(-5)
            })
        }
        lblMessage.text = message
        self >>> view >>> block
    }
    
    static func show(using message: String?, on view: UIView?,
                     duration: TimeInterval = 0.5,
                     layout block: (Toast) -> ()) -> Observable<Void>
    {
        let toastView = Toast(using: message, on: view, layout: block)
        return Observable.create({ (s) -> Disposable in
            UIView.animate(withDuration: duration, animations: {
                toastView.alpha = 0
            }, completion: { (_) in
                s.onNext(())
                s.onCompleted()
            })
            return Disposables.create {
                toastView.removeFromSuperview()
            }
        })
    }
}

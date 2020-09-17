//  File name   : NoItemView.swift
//
//  Author      : Dung Vu
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import SnapKit

final class NoItemView: UIView {
    /// Class's public properties.
    private(set) var lblMessage: UILabel?
    private(set) var iconView: UIImageView?
    private(set) var lblSub: UILabel?
    private weak var parentView: UIView?
    private var containerView: UIView?
    private var customLayout: ((NoItemView) -> ())?
    
    convenience init(imageName: String,
                     message: String?,
                     subMessage: String? = nil,
                     on view: UIView?,
                     customLayout: ((NoItemView) -> ())? = nil)
    {
        self.init(frame: .zero)
        common()
        let image = UIImage.init(named: imageName)
        self.iconView?.image = image
        self.lblMessage?.text = message
        self.lblSub?.text = subMessage
        self.parentView = view
        self.customLayout = customLayout
        
        self.iconView?.snp.updateConstraints({ (make) in
            make.size.equalTo(image?.size ?? .zero)
        })
    }
    
    private func common() {
        let container = UIView(frame: .zero) >>>
        {
            $0.backgroundColor = .clear
        } >>> self >>>
        {
            $0.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
        }
        
        self.containerView = container
        
        // Image View
        let imageView = UIImageView(frame: .zero) >>> {
            $0.contentMode = .center
        } >>> container >>>
        {
            $0.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.size.equalTo(CGSize.zero)
            })
        }
        
        self.iconView = imageView
        
        // Label
        let lblMessage = UILabel(frame: .zero) >>> {
            $0.numberOfLines = 0
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .center
        } >>> container >>>
        {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(8)
                make.width.greaterThanOrEqualTo(imageView.snp.width).priority(.high)
                make.width.lessThanOrEqualTo(imageView.snp.width).offset(40)
                make.left.equalToSuperview()
                make.right.equalToSuperview().priority(.high)
            })
        }
        self.lblMessage = lblMessage
        
        // sub message
        let lblSubMessage = UILabel(frame: .zero) >>> {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            } >>> container >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblMessage.snp.bottom).offset(3)
                    make.width.equalTo(lblMessage.snp.width).offset(40).priority(.high)
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview().priority(.low)
                })
        }
        
        self.lblSub = lblSubMessage
    }
    
    // MARK: Public function
    func detach() {
        guard !(self.parentView is UITableView) else {
            detachTableView()
            return
        }
        
        guard self.superview != nil else {
            return
        }
        
        self.snp.removeConstraints()
        self.removeFromSuperview()
    }
    
    func attach() {
        guard !(self.parentView is UITableView) else {
            attachTableView()
            return
        }
        
        guard self.superview == nil else {
            return
        }
        
        self >>> parentView >>> { [unowned self] in
            let block = self.customLayout ?? {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
            block($0)
        }
    }
    
    private func attachTableView() {
        guard let tableView = self.parentView as? UITableView else {
            return
        }
        tableView.backgroundView = nil
        // Full Frame
        let f = tableView.bounds
        self.frame = CGRect(origin: .zero, size: f.size)
        tableView.backgroundView = self
    }
    
    private func detachTableView() {
        let tableView = self.parentView as? UITableView
        tableView?.backgroundView = nil
    }
}



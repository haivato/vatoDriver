//  File name   : TopupByMoneyHeaderView.swift
//
//  Author      : Dung Vu
//  Created date: 12/11/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit

struct TopupByMoneyItem {
    let title: String?
    let iconName: String
    let description: String?
    let colorPrice: UIColor
    let price: String?
}

fileprivate final class TopupByMoneyTransferView: UIView {
    var lblTitle: UILabel?
    var iconView: UIImageView?
    var lblDescription: UILabel?
    var lblPrice: UILabel?
    let item: TopupByMoneyItem
    
    init(with item: TopupByMoneyItem) {
        self.item = item
        super.init(frame: .zero)
        setupDisplay()
    }
    
    func setupDisplay() {
        self.backgroundColor = .clear
        let lblTitle = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
            $0.textAlignment = .center
            $0.text = item.title
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(2)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.width.equalTo(136)
                })
        }
        self.lblTitle = lblTitle
        
        let iconView = UIImageView(image: UIImage(named: item.iconName)) >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 40, height: 40))
            })
        }
        
        self.iconView = iconView
        
        let lblDescription = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.text = item.description
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(iconView.snp.bottom).offset(12)
                    make.centerX.equalToSuperview()
                    make.width.equalTo(136)
                })
        }
        
        self.lblDescription = lblDescription
        
        let lblPrice = UILabel.create {
            $0.textColor = item.colorPrice
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.text = item.price ?? "\(0.currency)"
            $0.textAlignment = .center
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblDescription.snp.bottom).offset(6)
                    make.width.equalTo(136)
                    make.centerX.equalToSuperview()
                })
        }
        
        self.lblPrice = lblPrice
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTransfer(money: Int) {
        self.lblPrice?.text = money.currency
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

final class TopupByMoneyHeaderView: UIView {
    /// Class's public properties.
    private var sourceView: [UIView] = []
    convenience init(with items: [TopupByMoneyItem]) {
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 200)))
        visualize(by: items)
    }
    
    func updateTransfer(money: Int) {
        let v = self.sourceView.lazy.first(where: { $0 is TopupByMoneyTransferView})
        (v as? TopupByMoneyTransferView)?.updateTransfer(money: money)
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
}


// MARK: Class's private methods
private extension TopupByMoneyHeaderView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize(by items: [TopupByMoneyItem]) {
        // todo: Visualize view's here.
        self.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let last = items.count - 1
        items.enumerated().forEach { (item) in
            let v = TopupByMoneyTransferView(with: item.element)
            sourceView.append(v)
            guard item.offset != last else {
               return
            }
            
            let containerView = UIView() >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(38)
                })
            }
            
            UIImageView(image: UIImage(named: "ic_transfer")) >>> containerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.size.equalTo(CGSize(width: 28, height: 24))
                    make.centerX.equalToSuperview()
                    make.top.equalTo(52)
                })
            }
            sourceView.append(containerView)
        }
        
        UIStackView(arrangedSubviews: sourceView) >>> {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(32)
                    make.centerX.equalToSuperview()
                    make.bottom.equalTo(24)
                })
        }
        
        UIView(frame: .zero) >>> self >>> {
            $0.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.height.equalTo(0.5)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
        
    }
}

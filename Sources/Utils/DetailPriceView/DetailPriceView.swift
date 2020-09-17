//
//  DetailPriceView.swift
//  FC
//
//  Created by Phan Hai on 31/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import Eureka

// MARK: Price Info
struct PriceInfoDisplayStyle: Equatable {
    let attributeTitle: NSAttributedString
    let attributePrice: NSAttributedString
    let showLine: Bool
    let edge: UIEdgeInsets
    
    static func ==(lhs: PriceInfoDisplayStyle, rhs: PriceInfoDisplayStyle) -> Bool {
        return lhs.attributeTitle == rhs.attributeTitle
    }
}

final class DetailPriceView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    private lazy var containerView = UIView(frame: .zero)
    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        backgroundColor = .white
        containerView.backgroundColor = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 0.08)
        containerView >>> self >>> {
           $0.layer.cornerRadius = 8
           $0.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 0.15)
           $0.layer.borderWidth = 1
           $0.clipsToBounds = true
           $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
           $0.setContentHuggingPriority(.required, for: .vertical)
           $0.snp.makeConstraints { (make) in
               make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
           }
        }
        
        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func setupDisplay(item: [PriceInfoDisplayStyle]?) {
        if !self.containerView.subviews.isEmpty {
            let childs = containerView.subviews
            childs.forEach { $0.removeFromSuperview() }
        }
        
        let views = item?.map({ (destination) -> UIView in
            let view = UIView(frame: .zero)
            view.backgroundColor = .clear
            view >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
            }
            
            let lblTitle = UILabel(frame: .zero)
            lblTitle >>> {
                $0.attributedText = destination.attributeTitle
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.defaultLow, for: .vertical)
            }
            
            
            let lblPrice = UILabel(frame: .zero)
            lblPrice >>> {
                $0.attributedText = destination.attributePrice
                $0.setContentHuggingPriority(.required, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
            }
            
            let stackView = UIStackView(arrangedSubviews: [lblTitle, lblPrice])
            stackView >>> view >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
                $0.distribution = .fill
                $0.axis = .horizontal
                $0.spacing = 10
                $0.snp.makeConstraints { (make) in
                    make.edges.equalTo(destination.edge)
                }
            }
            
            if destination.showLine {
                view.addSeperator(with: .zero, position: .top)
            }
            return view
        })
        
        
        let stackView = UIStackView(arrangedSubviews: views ?? [])
        stackView >>> containerView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 8
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))//.priority(.high)
            }
        }
    }
    
    
}


//  File name   : AddDestinationCell.swift
//
//  Author      : Dung Vu
//  Created date: 3/23/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCore

final class AddDestinationCell: Eureka.Cell<DestinationPoint>, CellType, UpdateDisplayProtocol {
    private (set) lazy var view = DestinationInfoView.loadXib()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: DestinationPoint?) {
        view.setupDisplay(item: item)
    }
}

struct DestinationPriceInfo: Equatable {
    let attributeTitle: NSAttributedString
    let attributePrice: NSAttributedString
    let showLine: Bool
    let edge: UIEdgeInsets
    
    static func ==(lhs: DestinationPriceInfo, rhs: DestinationPriceInfo) -> Bool {
        return lhs.attributeTitle == rhs.attributeTitle
    }
}

final class AddDestinationPriceCell: Eureka.Cell<[DestinationPriceInfo]>, CellType, UpdateDisplayProtocol {
    private lazy var containerView = UIView(frame: .zero)
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        containerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.4)
        containerView >>> contentView >>> {
            $0.layer.cornerRadius = 8
            $0.layer.borderColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.clipsToBounds = true
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            }
        }
    }
    
    func setupDisplay(item: [DestinationPriceInfo]?) {
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
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)).priority(.high)
            }
        }
    }
}



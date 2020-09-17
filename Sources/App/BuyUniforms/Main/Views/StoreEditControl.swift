//  File name   : StoreEditControl.swift
//
//  Author      : Dung Vu
//  Created date: 12/9/19
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

struct StoreEditValue {
    let text: String?
    let image: UIImage?
}

typealias StoreEditType = [UIControl.State : StoreEditValue]
extension UIControl.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}

final class StoreEditControl: UIControl {
    struct Configs {
        struct Text {
            static let normal = "MUA"
            static let edit = "SỬA"
        }
        
        struct Image {
            static let normal = UIImage(named: "ic_buy_menu")
            static let edit = UIImage(named: "ic_edit_menu")
        }
    }
    /// Class's public properties.
    private (set) lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private (set) lazy var imageView: UIImageView = UIImageView(frame: .zero)
    private lazy var info: StoreEditType = StoreEditType()
    /// Class's private properties.
    override var isSelected: Bool {
        didSet {
            let s: UIControl.State = isSelected ? .selected : .normal
            let v = info[s]
            imageView.image = v?.image
            lblTitle.text = v?.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        let v1 = StoreEditValue(text: Configs.Text.normal, image: Configs.Image.normal)
        let v2 = StoreEditValue(text: Configs.Text.edit, image: Configs.Image.edit)
        set(value: v1, for: .normal)
        set(value: v2, for: .selected)
        
        imageView >>> self >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
                make.right.equalToSuperview()
            })
        }
        
        lblTitle >>> self >>> {
            $0.font = UIFont.systemFont(ofSize: 11, weight: .bold)
            $0.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.textAlignment = .right
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(imageView.snp.left).offset(-3)
                make.centerY.equalTo(imageView.snp.centerY).priority(.high)
                make.left.equalToSuperview()
            })
        }
    }
    
    func set(value: StoreEditValue, for state: UIControl.State) {
        info[state] = value
    }
}


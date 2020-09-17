//  File name   : TripMapSupplyInfoView.swift
//
//  Author      : Dung Vu
//  Created date: 4/7/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore

@objcMembers
final class TripMapSupplyInfoView: UIView {
    /// Class's public properties.
    @IBOutlet var lblPrice : UILabel?
    @IBOutlet var lblDescription : UILabel?
    @IBOutlet var btnReview : UIButton?
    /// Class's private properties.
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    private var mLayer: CAShapeLayer? {
        return self.layer as? CAShapeLayer
    }
    
    private func generateBenzierPath() -> UIBezierPath {
        let benzier = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        return benzier
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = generateBenzierPath()
        mLayer?.path = path.cgPath
        mLayer?.fillColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1).cgColor
    }
}

// MARK: Class's public methods
extension TripMapSupplyInfoView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    static func show(in container: UIView, after: UIView?, price: Double, description: String?) -> TripMapSupplyInfoView {
        let v = TripMapSupplyInfoView.loadXib()
        v.lblPrice?.text = "Giá ước tính: \(price.currency)"
        v.lblDescription?.text = description
        v >>> container >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                if let after = after {
                    make.top.equalTo(after.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
            }
        }
        return v
    }
}

// MARK: Class's private methods
private extension TripMapSupplyInfoView {
    private func initialize() {
        // todo: Initialize view's here.
    }

}

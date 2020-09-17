//
//  BottomCornerView.swift
//  FC
//
//  Created by MacbookPro on 5/8/20.
//  Copyright © 2020 Vato. All rights reserved.
import UIKit

final class BottomCornerView: UIView {
    /// Class's public properties.
    private let radius: CGFloat
    private let shapeLayer: CAShapeLayer = CAShapeLayer()
    @objc var containerColor: UIColor? = .clear {
        didSet {
            shapeLayer.fillColor = containerColor?.cgColor
        }
    }
    
    private var currentRect: CGRect = .zero {
        didSet {
            guard currentRect != oldValue else {
                return
            }
            setupView()
        }
    }
    
    override var frame: CGRect {
        get {
           return super.frame
        }
        
        set {
            super.frame = newValue
            setNeedsDisplay()
        }
    }
    
    
    @objc init(with cornerRadius: CGFloat) {
        radius = cornerRadius
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        shapeLayer.removeFromSuperlayer()
        shapeLayer.frame = currentRect
        let bezier = UIBezierPath(roundedRect: currentRect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius * 2, height: radius * 2))
        shapeLayer.path = bezier.cgPath
        shapeLayer.fillColor = containerColor?.cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.currentRect = rect
    }
    
    deinit {
        printDebug("\(#function)")
    }
}



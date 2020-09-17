//  File name   : HeaderCornerView.swift
//
//  Author      : Dung Vu
//  Created date: 1/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class HeaderCornerView: UIView {
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
        let bezier = UIBezierPath(roundedRect: currentRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius * 2, height: radius * 2))
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


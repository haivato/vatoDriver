//  File name   : ArrowView.swift
//
//  Author      : Dung Vu
//  Created date: 12/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class ArrowView: UIView {
    /// Class's public properties.
    private var color: UIColor?
    
    convenience init(by color: UIColor?) {
        self.init(frame: .zero)
        self.color = color
    }
    
    /// Class's private properties.
    override func layoutSubviews() {
        super.layoutSubviews()
        let subsLayer = self.layer.sublayers
        subsLayer?.forEach{ $0.removeFromSuperlayer() }
        // Add
        let f = self.bounds
        let p1 = CGPoint(x: f.width / 2, y: 0)
        let p2 = CGPoint(x: 0, y: f.height)
        let p3 = CGPoint(x: f.width, y: f.height)
        
        let bezier = UIBezierPath()
        bezier.move(to: p1)
        bezier.addLine(to: p2)
        bezier.addLine(to: p3)
        bezier.close()
        
        let arrow = CAShapeLayer()
        arrow.path = bezier.cgPath
        arrow.frame = CGRect(origin: .zero, size: f.size)
        arrow.fillColor = color?.cgColor
        self.layer.addSublayer(arrow)
    }
}

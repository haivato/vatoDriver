//
//  UIView+Extension.swift
//  FaceCar
//
//  Created by Dung Vu on 9/27/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
    @IBInspectable
    public var cornerRadius: CGFloat {
        set(radius) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        }

        get {
            return self.layer.cornerRadius
        }
    }

    @IBInspectable
    public var borderWidth: CGFloat {
        set(borderWidth) {
            self.layer.borderWidth = borderWidth
        }

        get {
            return self.layer.borderWidth
        }
    }

    @IBInspectable
    public var borderColor: UIColor? {
        set(color) {
            self.layer.borderColor = color?.cgColor
        }

        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    func dropShadow() {
        shadowColor = .black
        shadowOpacity = 0.1
        shadowRadius = 20.0
        shadowOffset = CGSize(width: 0.0, height: 4.0)
    }
}

protocol CreateViewCodeProtocol {}
extension CreateViewCodeProtocol where Self: UIView {
    static func create(_ transform: (Self) -> ()) -> Self {
        let v = self.init(frame: .zero)
        transform(v)
        return v
    }
}
extension UIView: CreateViewCodeProtocol {}

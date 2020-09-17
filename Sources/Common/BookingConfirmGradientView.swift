//  File name   : BookingConfirmGradientView.swift
//
//  Author      : Dung Vu
//  Created date: 9/27/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class BookingConfirmGradientView: UIView {
    /// Class's public properties.
    var colors: [CGColor]?
    /// Class's private properties.
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
}

// MARK: Class's public methods
extension BookingConfirmGradientView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension BookingConfirmGradientView {
    private func initialize() {
        // todo: Initialize view's here.
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.backgroundColor = .clear
        guard let layer = self.layer as? CAGradientLayer else {
            return
        }

        layer.colors = colors ?? [UIColor(white: 1, alpha: 0).cgColor, UIColor.white.cgColor]
    }
}

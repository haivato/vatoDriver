//  File name   : RoundGroupView.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import SnapKit

final class RoundGroupView: UIView {
    /// Class's public properties.
    private lazy var stackView: UIStackView = UIStackView()
    private let edges: UIEdgeInsets
    /// Class's private properties.
    init(frame: CGRect, edges: UIEdgeInsets) {
        self.edges = edges
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        layer.cornerRadius = 8
        
        stackView >>> self >>> {
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 10
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(edges)
            }
        }
    }
    
    func update(sources: [String]) {
        let views = stackView.arrangedSubviews
        if !views.isEmpty {
            views.forEach { (v) in
                stackView.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
        }
        
        guard !sources.isEmpty else {
            return
        }
        
        sources.enumerated().forEach { (s) in
            let label = UILabel(frame: .zero)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            let att = s.element.attribute >>> .color(c: #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 15, weight: .regular)) >>> .paragraph(p: style)
            label.attributedText = att
            label.numberOfLines = 0
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            stackView.addArrangedSubview(label)
            if s.offset > 0 {
                let sperator = self.addSeperator(with: .zero, position: .bottom)
                sperator.snp.remakeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(label.snp.top).offset(-4)
                    make.height.equalTo(0.5)
                }
            }
        }
    }
}

//  File name   : VatoShorcutView.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore

enum VatoGuideImageType: Int {
    case pdf
    case local
}

@objcMembers
final class VatoShorcutView: UIControl {
    /// Class's private properties.
    
    private let type: VatoGuideImageType
    private let fName: String
    private (set) var imageView: UIImageView?
    private let edges: UIEdgeInsets
    private static var imagesPDF: [String: [UIImage]] = [:]
    private let text: NSAttributedString?
    
    init(description: String?) {
        self.edges = UIEdgeInsets(top: 10, left: 17, bottom: 10, right: 17)
        self.type = .pdf
        self.fName = "ic_vato_list_animate"
        let text = FwiLocale.localized(description)
        let att = text.attributedString >>> .font(f: .systemFont(ofSize: 10, weight: .medium)) >>> .color(c: Color.orange)
        self.text = att
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else { return }
        visualize()
    }
    
    private func visualize() {
        backgroundColor = .white
        self.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.24)
        shadowOpacity = 1
        shadowRadius = 5
        shadowOffset = CGSize(width: -2, height: 2)
        
        let imageView = UIImageView(frame: .zero)
        self.imageView = imageView
        if let d = text {
            imageView >>> self >>> {
                $0.contentMode = .scaleAspectFill
                $0.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(3)
                    make.size.equalTo(CGSize(width: 35, height: 48))
                }
            }
            let lblDes = UILabel(frame: .zero)
            lblDes >>> self >>> {
                $0.attributedText = d
                $0.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(imageView.snp.bottom).offset(2)
                }
            }
        } else {
            imageView >>> self >>> {
                $0.contentMode = .scaleAspectFill
                $0.snp.makeConstraints { (make) in
                    make.edges.equalTo(edges)
                }
            }
        }
        
        switch type {
        case .local:
            imageView.image = UIImage(named: fName)
        case .pdf:
            let images: [UIImage]
            let cached = VatoShorcutView.imagesPDF[fName] ?? []
            if !cached.isEmpty {
                images = cached
            } else {
                let news = UIImage.loadListImage(from: fName)
                defer {
                    VatoShorcutView.imagesPDF[fName] = news
                }
                images = news
            }
            guard !images.isEmpty else { return }
            imageView >>>  {
                $0.animationImages = images
                $0.animationDuration = 1.5
                $0.startAnimating()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        layer.cornerRadius = h / 2
    }
}





//  File name   : TODetailLocationHeader.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import GSKStretchyHeaderView
import SnapKit
import FwiCore


final class TODetailLocationHeader: GSKStretchyHeaderView {
    /// Class's public properties.
    private let segment: VatoSegmentView
    private let containerView: UIView
    private let sizeContainer: CGSize
    private let hSegment: CGFloat
    
    /// Class's private properties.
    init(with containerView: UIView,
         size: CGSize,
         segment: VatoSegmentView,
         hSegment: CGFloat,
         frame: CGRect)
    {
        self.segment = segment
        self.containerView = containerView
        self.sizeContainer = size
        self.hSegment = hSegment
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        backgroundColor = .white
        minimumContentHeight = hSegment
        contentExpands = false
        
        segment >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(hSegment)
            }
        }
        
        containerView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(segment.snp.top).offset(-8)
            }
        }
        contentView.addSeperator()
    }
}




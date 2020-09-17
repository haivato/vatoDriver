//  File name   : DestinationInfoView.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

enum DestinationType {
    case original
    case destination
    case index(idx: Int)
    
    var title: String? {
        switch self {
        case .original:
            return "Điểm đến cũ"
        case .destination:
            return "Điểm đến mới"
        case .index:
            return nil
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .original:
            return UIImage(named: "ic_destination_o")
        case .destination:
            return UIImage(named: "ic_destination_d")
        case .index(let idx):
            if (idx == 1) {
                return UIImage(named: "ic_origin")
            } else {
               return UIImage(named: "ic_destination_edit")
            }
        }
    }
    
    var index: String? {
        switch self {
        case .index(let idx):
            return idx == 1 ? "" : "\(idx-1)"
        default:
            return nil
        }
    }
    
    func atrributeTitle(from text: String) -> NSAttributedString {
        switch self {
        case .original:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 13, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            return att
        case .destination:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 13, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
            return att
        case .index:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 16, weight: .medium)) >>> .color(c: Color.orange)
            return att
        }
    }
    
    func atrributeSubtitle(from text: String) -> NSAttributedString {
        switch self {
        case .original:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 16, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            return att
        case .destination:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 16, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
            return att
        case .index:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 16, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
            return att
        }
    }
}

final class DestinationInfoView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblAddress : UILabel?
    @IBOutlet var lblIndex: UILabel?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var imageDotView: UIImageView?
    /// Class's private properties.
    
    func setupDisplay(item: DestinationPoint?) {
        let title = item?.type.title ?? item?.address.name
        let att = item?.type.atrributeTitle(from: title ?? "")
        lblTitle?.attributedText = att
        let address = item?.address
        let sub = item?.type.atrributeSubtitle(from: address?.subLocality ?? address?.name ?? "")
        lblAddress?.attributedText = sub
        imageView?.image = item?.type.icon
        lblIndex?.text = item?.type.index
        imageDotView?.isHidden = item?.showDots == false
    }
}

// MARK: Class's public methods
extension DestinationInfoView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
    
    func update(hiddenLine: Bool) {
        imageView?.isHidden = hiddenLine
    }
}

// MARK: Class's private methods
private extension DestinationInfoView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}

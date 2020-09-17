//
//  ActionButtonView.swift
//  FC
//
//  Created by MacbookPro on 4/6/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PRActionButtonRequest: UIView {
    
    @IBOutlet weak var btAgree: UIButton?
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var hBtAgree: NSLayoutConstraint!
    @IBOutlet weak var hBtCancel: NSLayoutConstraint!
    //    @IBOutlet weak var hStackView: NSLayoutConstraint!
    private let tagBtAgree = 10
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btAgree?.tag = tagBtAgree

    }
    func updateUI(typeRequest: ProcessRequestType) {
        switch typeRequest {
        case .AGREE:
            self.btAgree?.isHidden = false
            changeColorBtCancel(text: "Huỷ yêu cầu")
        case .REGISTER_FOOD:
//            if let viewWithTag = self.stackView.viewWithTag(tagBtAgree) {
//                viewWithTag.removeFromSuperview()
//            }
            self.btAgree?.isHidden = true
            self.btCancel.setTitle("Gửi yêu cầu xử lý", for: .normal)
            self.btCancel.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            self.btCancel.setTitleColor(.white, for: .normal)
        case .INIT:
            if let viewWithTag = self.stackView.viewWithTag(tagBtAgree) {
                viewWithTag.removeFromSuperview()
            }
            changeColorBtCancel(text: "Huỷ yêu cầu")
        case .REJECT:
            if let viewWithTag = self.stackView.viewWithTag(tagBtAgree) {
                viewWithTag.removeFromSuperview()
            }
            changeColorBtCancel(text: "Đóng")
        case .AGREE_AND_ACCEPT_TERMS:
//            self.hStackView.constant = 0
            hBtAgree.constant = 0
            hBtCancel.constant = 0
            break
        case .CANCEL_BEFORE_FEEDBACK, .COMPLETED, .CANCEL_AFTER_FEEDBACK:
            if let viewWithTag = self.stackView.viewWithTag(tagBtAgree) {
                viewWithTag.removeFromSuperview()
            }
            changeColorBtCancel(text: "Đóng")

        default:
            break
        }
    }
    
    private func changeColorBtCancel(text: String) {
        self.btCancel.setTitle(text, for: .normal)
        self.btCancel.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
        self.btCancel.layer.borderWidth = 1
        self.btCancel.layer.borderColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        self.btCancel.backgroundColor = .white
    }
}


//
//  StatusRequestView.swift
//  FC
//
//  Created by MacbookPro on 4/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

enum ProcessRequestType: String, Codable {
    case INIT, CANCEL, CANCEL_BEFORE_FEEDBACK, AGREE_AND_ACCEPT_TERMS, CANCEL_AFTER_FEEDBACK, AGREE, REJECT, COMPLETED, PENDING, REGISTER_FOOD, CLOSE
    
//    var style: (textView: Bool, textView2: Bool) {
//        switch self {
//        case .AGREE:
//            return (true, true)
//        default:
//            return (true, true)
//        }
//    }
    
//    enum ActionButtonType {
//           case request
//           case leaveQueue
//           case cancelRequest
//           case pending
//
//           func buttonConfig() -> (title: String, titleColor: UIColor, bgColor: UIColor, borderColor: UIColor) {
//               switch self {
//               case .request:
//                   return ("Yêu cầu xếp tài", .white, #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), .clear)
//               case .leaveQueue:
//                   return ("Huỷ xếp tài", #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1), .white, #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1))
//               case .cancelRequest:
//                   return ("Huỷ yêu cầu xếp tài", #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1), .white, #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1))
//               case .pending:
//                   return ("Chờ phản hồi", #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1), .white, #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1))
//               }
//           }
//       }
}

class PRStatusRequestView: UIView {
    
    
    @IBOutlet weak var lbRequestDriver: UILabel!
    @IBOutlet weak var lbReponse: UILabel!
    @IBOutlet weak var lbVatoResponse: UILabel!
    @IBOutlet weak var tvNote: UITextView!
    var btnCall: UIButton?
    private let tagBtAgree = 10
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

        self.lbReponse.text = "Số tiền rút về tài khoản: 100.000đ Bạn cần xác nhận chắc chắn, hành động này không thể làm lại."
        self.lbRequestDriver.text = "Tôi muốn đóng tài khoản và tất toán toàn bộ số tiền trong tài khoản."
    }
    func updateUI(typeRequest: ProcessRequestType) {
        switch typeRequest {
        case .REGISTER_FOOD:
            self.lbRequestDriver.text = "Đăng ký dịch vụ Food."
            self.lbVatoResponse.text = ""
            self.lbReponse.text = ""
            self.tvNote.isEditable = true
            
        case .INIT:
            self.tvNote.isEditable = false
            self.tvNote.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            self.tvNote.text = "Tôi muốn đóng tài khoản và tất toán toàn bộ số tiền trong tài khoản."
            self.lbVatoResponse.text = "Vato đã tiếp nhận"
            self.lbVatoResponse.textColor = #colorLiteral(red: 0.9333333333, green: 0.5882352941, blue: 0.1568627451, alpha: 1)
            self.lbReponse.text = "Yêu cầu của bạn đã được tiếp nhận. Vui lòng chờ xử lý trong 24h"
            self.lbReponse.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        case .REJECT:
            self.tvNote.isEditable = false
            self.tvNote.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            self.tvNote.text = "Tôi muốn đóng tài khoản và tất toán toàn bộ số tiền trong tài khoản."
            
            self.lbVatoResponse.text = "VATO từ chối yêu cầu"
            self.lbVatoResponse.textColor = #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)

            self.lbReponse.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            var att = "Yêu cầu của bạn đã được bị từ chối. Vui lòng liên hệ tổng đài VATO ".attribute
                >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
                >>> .font(f: UIFont.systemFont(ofSize: 15.0, weight: .regular))

            let s1 = "19006667".attribute
                >>> .underline(u: NSUnderlineStyle.single.rawValue)
                >>> .color(c: #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1))
                >>> .font(f: UIFont.systemFont(ofSize: 15.0, weight: .regular))

            let s2 = " để biết thêm chi tiết!.".attribute
                >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
                >>> .font(f: UIFont.systemFont(ofSize: 15.0, weight: .regular))
            
            att = att >>> s1 >>> s2
            self.lbReponse.attributedText = att
            
            self.btnCall = UIButton.create{
                $0.backgroundColor = .clear
                } >>> self >>> {
                    $0.snp.makeConstraints { (make) in
                        make.edges.equalTo(self.lbReponse).priority(.medium)
                    }
            }

        case .AGREE:
            self.tvNote.isEditable = false
            self.tvNote.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            self.tvNote.text = "Tôi muốn đóng tài khoản và tất toán toàn bộ số tiền trong tài khoản."
            
            self.lbVatoResponse.text = "Vato đã chấp nhận"
            self.lbVatoResponse.textColor = #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 1)
            self.lbReponse.text = "Số tiền rút về tài khoản: 100.000đ Bạn cần xác nhận chắc chắn, hành động này không thể làm lại."
            self.lbReponse.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        default:
            break
        }
    }
}

//
//  StatusRequestCell.swift
//  FC
//
//  Created by MacbookPro on 4/7/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class StatusRequestCell: UITableViewCell {

    @IBOutlet weak var lbRequestDriver: UILabel!
    @IBOutlet weak var lbVatoResponse: UILabel!
    @IBOutlet weak var lbReponse: InputAutoResizeView!
    @IBOutlet weak var lbTitleNote: UILabel!
    @IBOutlet weak var tvNote: UITextView!
    @IBOutlet weak var lbNote: UILabel!
    @IBOutlet weak var hTvNote: NSLayoutConstraint!
    @IBOutlet weak var vNote: UIView!
    @IBOutlet weak var hViewNote: NSLayoutConstraint!
    private let disposeBag = DisposeBag()
    var btnCall: UIButton?
    var buttonActionCall : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tvNote.text = "Nhập nội dung lí do"
        self.tvNote.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5803921569, alpha: 1)
        hTvNote.constant = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI(type: ProcessRequestType, item: RequestResponseDetail?) {
        switch type {
        case .REGISTER_FOOD:
            self.lbRequestDriver.text = "Đăng ký dịch vụ Food."
            self.lbVatoResponse.text = ""
            updateTextResponse(nil)
            self.lbNote.text = ""
            self.tvNote.isEditable = true
            self.tvNote.isHidden = false
            self.hTvNote.constant = 80
            self.vNote.backgroundColor = .white
            
        case .INIT:
            self.lbRequestDriver.text = item?.requestTypeName
            self.vNote.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            self.tvNote.isEditable = false
            self.tvNote.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            self.lbNote.text = item?.content
            self.lbVatoResponse.text = "Vato đã tiếp nhận"
            self.lbVatoResponse.textColor = #colorLiteral(red: 0.9333333333, green: 0.5882352941, blue: 0.1568627451, alpha: 1)
            let att = "Yêu cầu của bạn đã được tiếp nhận. Vui lòng chờ xử lý. VATO sẽ phản hồi tới Đối tác trong thời gian sớm nhất.".attribute >>> .color(c: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
            updateTextResponse(att)
            
            self.tvNote.isHidden = true
            self.hTvNote.constant = 0
            
            if item?.content?.isEmpty ?? false {
                self.updateUIIfContentNil()
            }

        case .REJECT:
            self.vNote.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            self.tvNote.isHidden = true
            self.hTvNote.constant = 0
            self.tvNote.isEditable = false
            self.tvNote.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            self.lbNote.text = item?.content

            
            self.lbVatoResponse.text = "VATO từ chối yêu cầu"
            self.lbVatoResponse.textColor = #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
            self.lbRequestDriver.text = item?.requestTypeName

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
            updateTextResponse(att)
            self.btnCall = UIButton.create{
                $0.backgroundColor = .clear
                } >>> self >>> {
                    $0.snp.makeConstraints { (make) in
                        make.edges.equalTo(self.lbReponse).priority(.medium)
                    }
            }
            self.btnCall?.rx.tap.bind(onNext: { _ in
                self.buttonActionCall?()
            }).disposed(by: disposeBag)

            if item?.content?.isEmpty ?? false {
                self.updateUIIfContentNil()
            }
        case .AGREE, .COMPLETED:
            self.vNote.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            self.tvNote.isHidden = true
            self.hTvNote.constant = 0
            self.tvNote.isEditable = false
            self.tvNote.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            self.lbNote.text = item?.content
            self.lbRequestDriver.text = item?.requestTypeName
            
            if type == .AGREE {
                self.lbVatoResponse.textColor = #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 1)
                self.lbVatoResponse.text = "Vato đã chấp nhận"
            } else {
                self.lbVatoResponse.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.lbVatoResponse.text = "Yêu cầu đã hoàn thành"
            }
            
            updateTextResponse(item?.feedback?.content.htmlToAttributedString)
            self.lbReponse.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            
            if item?.content?.isEmpty ?? false {
                self.updateUIIfContentNil()
            }
        case .CANCEL_BEFORE_FEEDBACK, .AGREE_AND_ACCEPT_TERMS, .CANCEL_AFTER_FEEDBACK:
            self.vNote.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            self.tvNote.isHidden = true
            self.hTvNote.constant = 0
            self.tvNote.isEditable = false
            self.tvNote.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            self.lbNote.text = item?.content
            self.lbRequestDriver.text = item?.requestTypeName
            
            switch item?.status {
            case .AGREE_AND_ACCEPT_TERMS:
                self.lbVatoResponse.text = "Bạn đã đồng ý yêu cầu này, đang chờ VATO phản hồi"
                self.lbVatoResponse.textColor = #colorLiteral(red: 0.9333333333, green: 0.5882352941, blue: 0.1568627451, alpha: 1)
            default:
                self.lbVatoResponse.text = "Bạn đã huỷ yêu cầu này."
            }
            let att = item?.feedback?.content.htmlToAttributedString
            updateTextResponse(att)
            
            if item?.content?.isEmpty ?? false {
                self.updateUIIfContentNil()
            }
        default:
            break
        }
    }
    private func updateUIIfContentNil() {
        self.lbTitleNote.text = ""
        self.vNote.isHidden = true
        self.hViewNote.constant = 0
    }
    func updateUIFood(type: ProcessRequestType, item: UserRequestTypeFireStore?) {
        self.lbRequestDriver.text = item?.title
        self.lbVatoResponse.text = ""
        updateTextResponse(nil)
        self.lbNote.text = ""
        self.tvNote.isEditable = true
        self.tvNote.isHidden = false
        self.hTvNote.constant = 80
        self.vNote.backgroundColor = .white
    }
    
    func updateTextResponse(_ att: NSAttributedString?) {
        defer {
            NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: nil)
        }
        guard let att = att else {
            lbReponse?.attributedText = nil
            return
        }
        let count = att.string.count
        let att1 = NSMutableAttributedString(attributedString: att)
        att1.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], range: NSMakeRange(0, count))
        
        lbReponse?.attributedText = att1
    }
    
}

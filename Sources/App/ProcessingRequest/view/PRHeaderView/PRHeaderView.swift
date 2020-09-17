//
//  HeaderViewProcess.swift
//  FC
//
//  Created by MacbookPro on 4/3/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class PRHeaderView: UIView {

    
    @IBOutlet weak var lbHello: UILabel!
    @IBOutlet weak var lbContentHeader: UILabel!
    private let disposeBag = DisposeBag()
    var btLink: UIButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btLink = UIButton.create{
            $0.backgroundColor = .clear
            } >>> self >>> {
                $0.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.lbContentHeader).priority(.medium)
                }
        }
    }
    
    func updadteUI(item: RequestResponseDetail?, keyFood: String?) {
        guard  let item = item  else {
            updateUIRegisterFood()
            return
        }
        if item.requestTypeId == keyFood {
            updateUIRegisterFood()
        } else {
            self.btLink?.isEnabled = false
            self.lbContentHeader.text = "Đây là trung tâm hỗ trợ yêu cầu xử lý của bạn. Vui lòng chọn và nhập thông tin yêu cần xử lý bên dưới.\nXin cám ơn."
        }
    }
    private func updateUIRegisterFood() {
        var att = "Bạn cần đọc kỹ".attribute
            >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 15.0, weight: .regular))
        
        
        let s1 = " Chính sách và điều khoản Dịch vụ Food".attribute
            >>> .color(c: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1529411765, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 15.0, weight: .regular))
        
        let s2 = " đăng ký để bắt đầu dịch vụ giao Food của VATO nhé!".attribute
            >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 15.0, weight: .regular))
        
        att = att >>> s1 >>> s2
        self.lbContentHeader.attributedText = att
        
        self.btLink?.isEnabled = true
    }
    
}

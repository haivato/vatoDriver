//  File name   : LabelVersion.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore

final class LabelVersion: UIView {
    private (set) lazy var lblContent: UILabel = UILabel(frame: .zero)
    private (set) lazy var appVersion: String = {
        let app = Bundle.main.infoDictionary?.value("CFBundleShortVersionString", defaultValue: "")
        return app ?? ""
    }()
    
    private (set) lazy var userId: String = {
        guard let userId = UserManager.shared.getUserId() else { return "" }
        return "\(userId)"
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        common()
    }
    
    private func common() {
        backgroundColor = .clear
        lblContent >>> self >>> {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textAlignment = .center
            $0.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        lblContent.text = String(format: "%@ | %@", userId, appVersion)
    }
}

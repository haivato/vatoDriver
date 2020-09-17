//  File name   : VatoVerifyPasscodeObjC.swift
//
//  Author      : Dung Vu
//  Created date: 5/8/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import VatoPasswordIdentiy
import RxSwift
import FwiCore
@objc enum VatoObjCVerifyType: Int {
    case new
    case notVerify
    case changePin
    case forgot
}

public typealias HandlerPasscodeResult = (_ passcode: String?,_ verified:Bool) -> ()
public typealias HandlerForgotPhone = (_ phone: String) -> ()
@objcMembers
final class VatoVerifyPasscodeObjC: NSObject, Weakifiable {
    /// Class's public properties.
    struct ConfigUI: VatoPasswordUIProtocol {
        var title: VatoPasswordItem<VatoPasswordTitle?>
        var description: VatoPasswordItem<VatoPasswordTitle>?
        var iconClose: UIImage?
        var iconBack: UIImage?
        var useSupportPhone: Bool
        var passwordTitle: VatoPasswordItem<VatoPasswordTitle>?
        var roundRadius: CGFloat
        var phoneSupport: String
        var lengthPassword: VatoPasswordItem<Int>
        var size: CGSize
        var spacingPassword: CGFloat
        var colorPassword: VatoPasswordItem<UIColor>
        var colorPhoneCall: UIColor
    }
    
    private lazy var disposeBag = DisposeBag()
    func passcode(on controller: UIViewController?, type: VatoObjCVerifyType, forgot: HandlerForgotPhone?, handler: HandlerPasscodeResult?) {
        let config: ConfigUI
        let t: VatoVerifyType
        switch type {
        case .new:
            let colorTitle = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            let colorSub = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            let fTitle = FwiLocale.localized("Tạo mật khẩu thanh toán")
            let sTitle = FwiLocale.localized("Xác thực mật khẩu")
            
            let fSub = FwiLocale.localized("Tạo mật khẩu để thực hiện các giao dịch nạp, chuyển và rút tiền.")
            let sSub = FwiLocale.localized("Mật khẩu phải được giữ bí mật để thực hiện các giao dịch rút và chuyển tiền.")
            
            let fontTitle = UIFont.systemFont(ofSize: 18, weight: .medium)
            let fontSub = UIFont.systemFont(ofSize: 12, weight: .regular)
            let iconClose = UIImage(named: "ic_close")
            let iconBack = UIImage(named: "ic_back")
            let colorSelect = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            let colorUnSelect = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.4)
            
            let title = (VatoPasswordTitle(use: fTitle, font: fontTitle, color: colorTitle, numberOfLines: 2, alignment: .center), VatoPasswordTitle(use: sTitle, font: fontTitle, color: colorTitle, numberOfLines: 2, alignment: .center))
            let des = (VatoPasswordTitle(use: fSub, font: fontSub, color: colorSub, numberOfLines: 2, alignment: .center), VatoPasswordTitle(use: sSub, font: fontSub, color: colorTitle, numberOfLines: 2, alignment: .center))
            
            config = ConfigUI(title: title, description: des, iconClose: iconClose, iconBack: iconBack, useSupportPhone: false, passwordTitle: nil, roundRadius: 14, phoneSupport: "", lengthPassword: (6, 6), size: CGSize(width: 18, height: 18), spacingPassword: 8, colorPassword: (colorSelect, colorUnSelect), colorPhoneCall: .green)
            t = .createNew
        case .changePin:
            let colorTitle = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            let fTitle = FwiLocale.localized("Nhập mật khẩu hiện tại")
            let sTitle = FwiLocale.localized("Nhập mật khẩu mới")
            
            let fontTitle = UIFont.systemFont(ofSize: 18, weight: .medium)
            let iconClose = UIImage(named: "ic_close")
            let iconBack = UIImage(named: "ic_back")
            let colorSelect = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            let colorUnSelect = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.4)
            
            let fPassword = FwiLocale.localized("Quên mật khẩu?")
            let sPassword = FwiLocale.localized("Gọi 19006667")
            let colorPassword = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            
            let title = (VatoPasswordTitle(use: fTitle, font: fontTitle, color: colorTitle, numberOfLines: 2, alignment: .center), VatoPasswordTitle(use: sTitle, font: fontTitle, color: colorTitle, numberOfLines: 2, alignment: .center))
            let passwordTitle = (VatoPasswordTitle(use: fPassword, font: fontTitle, color: colorTitle, numberOfLines: 1, alignment: .center), VatoPasswordTitle(use: sPassword, font: fontTitle, color: colorPassword, numberOfLines: 1, alignment: .center))
            
            config = ConfigUI(title: title, description: nil, iconClose: iconClose, iconBack: iconBack, useSupportPhone: true, passwordTitle: passwordTitle, roundRadius: 14, phoneSupport: "19006667", lengthPassword: (6, 6), size: CGSize(width: 18, height: 18), spacingPassword: 8, colorPassword: (colorSelect, colorUnSelect), colorPhoneCall: .green)
            t = .changePin
        case .notVerify:
            let colorTitle = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            let fTitle = FwiLocale.localized("Nhập mật khẩu hiện tại")
            let sTitle = FwiLocale.localized("Nhập mật khẩu mới")
            
            let fontTitle = UIFont.systemFont(ofSize: 17, weight: .light)
            let iconClose = UIImage(named: "ic_close")
            let iconBack = UIImage(named: "ic_back")
            let colorSelect = #colorLiteral(red: 0, green: 0.4235294118, blue: 0.231372549, alpha: 1)
            let colorUnSelect = #colorLiteral(red: 0, green: 0.4235294118, blue: 0.231372549, alpha: 0.4)
            
            let fPassword = FwiLocale.localized("Quên mật khẩu?")
            let sPassword = FwiLocale.localized("Gọi 19006667")
            let fontPassword = UIFont.systemFont(ofSize: 15, weight: .light)
            let colorPassword = #colorLiteral(red: 0, green: 0.4235294118, blue: 0.231372549, alpha: 1)
            
            let title = (VatoPasswordTitle(use: fTitle, font: fontTitle, color: colorTitle, numberOfLines: 2, alignment: .center), VatoPasswordTitle(use: sTitle, font: fontTitle, color: colorTitle, numberOfLines: 2, alignment: .center))
            let passwordTitle = (VatoPasswordTitle(use: fPassword, font: fontPassword, color: colorTitle, numberOfLines: 1, alignment: .center), VatoPasswordTitle(use: sPassword, font: fontPassword, color: colorPassword, numberOfLines: 1, alignment: .center))
            
            config = ConfigUI(title: title, description: nil, iconClose: iconClose, iconBack: iconBack, useSupportPhone: true, passwordTitle: passwordTitle, roundRadius: 14, phoneSupport: "19006667", lengthPassword: (6, 6), size: CGSize(width: 18, height: 18), spacingPassword: 8, colorPassword: (colorSelect, colorUnSelect), colorPhoneCall: .green)
            t = .notVerify
        default:
            fatalError("Please Implement")
        }
        
        VatoVerifyPasswordVC.showVerify(on: controller, config: config, type: t, token: FirebaseTokenHelper.instance.eToken.filterNil(), loading: { (load) in
            load ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }, forgotBlock: forgot) { (e) -> String in
            switch e {
            case .notSameBeforePassword:
                return FwiLocale.localized("Mật khẩu thanh toán chưa trùng khớp!")
            case .server(let error):
                return error.localizedDescription
            }
        }.bind(onNext: weakify({ (result, wSelf) in
            handler?(result.password, result.valid)
        })).disposed(by: disposeBag)
        
        
    }

    /// Class's constructors.
    
    /// Class's private properties.
}

// MARK: Class's public methods
extension VatoVerifyPasscodeObjC {
}

// MARK: Class's private methods
private extension VatoVerifyPasscodeObjC {
}

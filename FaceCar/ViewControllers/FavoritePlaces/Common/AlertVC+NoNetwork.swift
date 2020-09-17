//  File name   : AlertVC+Extension.swift
//
//  Author      : Futa Corp
//  Created date: 1/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Foundation

extension AlertVC {
    static func presentNetworkDown(for viewController: UIViewController?) {
        /* Condition validation: do not present another AlertVC if there is one already */
        if let viewController = viewController?.presentedViewController,
            viewController is AlertVC {
            return
        }

        let okayAction = AlertAction(style: .default, title: Text.agree.localizedText, handler: {
            guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.openURL(url)
        })

        let dismissAction = AlertAction(style: .cancel, title: Text.later.localizedText, handler: {})

        AlertVC.show(on: viewController,
                     title: Text.networkDown.localizedText,
                     message: Text.networkDownDescription.localizedText,
                     from: [dismissAction, okayAction],
                     orderType: .horizontal)
    }
    
    static func showError(for viewController: UIViewController?, message: String) {
        var _message = message;
        if !self.isNetworkAvailable() {
            _message = "Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra để tiếp tục nhận chuyến."
        }
        /* Condition validation: do not present another AlertVC if there is one already */
        if let viewController = viewController?.presentedViewController,
            viewController is AlertVC { return }
        
        let dismissAction = AlertAction(style: .cancel, title: Text.cancel.localizedText, handler: {})
        
        AlertVC.show(on: viewController,
                     title: Text.error.localizedText,
                     message: _message,
                     from: [dismissAction],
                     orderType: .horizontal)
    }
    
    static func showError(for viewController: UIViewController?, error: NSError?) {
        var message: String = error?.localizedDescription ?? ""
        
        if !self.isNetworkAvailable() {
            message = "Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra lại."
        }
        
//        if error.code == NESerr
        /* Condition validation: do not present another AlertVC if there is one already */
        if let viewController = viewController?.presentedViewController,
            viewController is AlertVC { return }
        
        let dismissAction = AlertAction(style: .cancel, title: Text.cancel.localizedText, handler: {})
        
        AlertVC.show(on: viewController,
                     title: Text.error.localizedText,
                     message: message,
                     from: [dismissAction],
                     orderType: .horizontal)
    }
    
    static func showMessageAlert(for viewController: UIViewController?,
                                 title: String?,
                                 message: String?,
                                 actionButton1: String?,
                                 actionButton2: String?,
                                 handler1: (() -> Void)? = nil,
                                 handler2: (() -> Void)? = nil) {
        if let viewController = viewController?.presentedViewController,
            viewController is AlertVC {
            return
        }
        
        var arrButton = [AlertAction]()
        if let actionButton1 = actionButton1 {
            let action1 = AlertAction(style: .cancel, title: actionButton1, handler: {
                handler1?()
            })
            arrButton.append(action1)
        }
        
        if let actionButton2 = actionButton2 {
            let action2 = AlertAction(style: .default, title: actionButton2, handler: {
                handler2?()
            })
            arrButton.append(action2)
        }
        
        AlertVC.show(on: viewController,
                     title: title,
                     message: message,
                     from: arrButton,
                     orderType: .horizontal)
    }
    
}

#if canImport(RIBs)
import RIBs

extension AlertVC {
    static func presentNetworkDown(for viewControllable: ViewControllable?) {
        presentNetworkDown(for: viewControllable?.uiviewController)
    }
}
#endif

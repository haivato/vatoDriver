//  File name   : RSPolicyRouter.swift
//
//  Author      : MacbookPro
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol RSPolicyInteractable: Interactable {
    var router: RSPolicyRouting? { get set }
    var listener: RSPolicyListener? { get set }
}

protocol RSPolicyViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class RSPolicyRouter: ViewableRouter<RSPolicyInteractable, RSPolicyViewControllable> {
    /// Class's constructor.
    override init(interactor: RSPolicyInteractable, viewController: RSPolicyViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: RSPolicyRouting's members
extension RSPolicyRouter: RSPolicyRouting {
    func showAlerError(text: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: text, actionButton1: "Đóng", actionButton2: nil)
    }
    
    
}

// MARK: Class's private methods
private extension RSPolicyRouter {
}

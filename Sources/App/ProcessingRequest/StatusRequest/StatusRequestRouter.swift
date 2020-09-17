//  File name   : StatusRequestRouter.swift
//
//  Author      : MacbookPro
//  Created date: 4/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol StatusRequestInteractable: Interactable {
    var router: StatusRequestRouting? { get set }
    var listener: StatusRequestListener? { get set }
}

protocol StatusRequestViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class StatusRequestRouter: ViewableRouter<StatusRequestInteractable, StatusRequestViewControllable> {
    /// Class's constructor.
    override init(interactor: StatusRequestInteractable, viewController: StatusRequestViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: StatusRequestRouting's members
extension StatusRequestRouter: StatusRequestRouting {
    
    func showAlerError(message: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: message, actionButton1: "Đóng", actionButton2: nil)
    }
}

// MARK: Class's private methods
private extension StatusRequestRouter {
}

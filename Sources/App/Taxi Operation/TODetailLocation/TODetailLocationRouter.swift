//  File name   : TODetailLocationRouter.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TODetailLocationInteractable: Interactable {
    var router: TODetailLocationRouting? { get set }
    var listener: TODetailLocationListener? { get set }
}

protocol TODetailLocationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TODetailLocationRouter: ViewableRouter<TODetailLocationInteractable, TODetailLocationViewControllable> {
    /// Class's constructor.
    override init(interactor: TODetailLocationInteractable, viewController: TODetailLocationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: TODetailLocationRouting's members
extension TODetailLocationRouter: TODetailLocationRouting {
    func showAlertError(text: String) {
        AlertVC.showMessageAlert(for: self.viewController.uiviewController, title: "Thông báo ", message: text, actionButton1: "Đóng", actionButton2: nil)
    }
    
}

// MARK: Class's private methods
private extension TODetailLocationRouter {
}

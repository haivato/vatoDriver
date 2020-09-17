//  File name   : RegisterServiceRouter.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol RegisterServiceInteractable: Interactable {
    var router: RegisterServiceRouting? { get set }
    var listener: RegisterServiceListener? { get set }
}

protocol RegisterServiceViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class RegisterServiceRouter: ViewableRouter<RegisterServiceInteractable, RegisterServiceViewControllable> {
    /// Class's constructor.
    override init(interactor: RegisterServiceInteractable, viewController: RegisterServiceViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: RegisterServiceRouting's members
extension RegisterServiceRouter: RegisterServiceRouting {
    
}

// MARK: Class's private methods
private extension RegisterServiceRouter {
}

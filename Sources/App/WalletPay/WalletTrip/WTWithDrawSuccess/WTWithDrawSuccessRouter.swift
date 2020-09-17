//  File name   : WTWithDrawSuccessRouter.swift
//
//  Author      : admin
//  Created date: 5/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WTWithDrawSuccessInteractable: Interactable {
    var router: WTWithDrawSuccessRouting? { get set }
    var listener: WTWithDrawSuccessListener? { get set }
}

protocol WTWithDrawSuccessViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WTWithDrawSuccessRouter: ViewableRouter<WTWithDrawSuccessInteractable, WTWithDrawSuccessViewControllable> {
    /// Class's constructor.
    override init(interactor: WTWithDrawSuccessInteractable, viewController: WTWithDrawSuccessViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: WTWithDrawSuccessRouting's members
extension WTWithDrawSuccessRouter: WTWithDrawSuccessRouting {
    
}

// MARK: Class's private methods
private extension WTWithDrawSuccessRouter {
}

//  File name   : CCChatWithVatoRouter.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol CCChatWithVatoInteractable: Interactable {
    var router: CCChatWithVatoRouting? { get set }
    var listener: CCChatWithVatoListener? { get set }
}

protocol CCChatWithVatoViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CCChatWithVatoRouter: ViewableRouter<CCChatWithVatoInteractable, CCChatWithVatoViewControllable> {
    /// Class's constructor.
    override init(interactor: CCChatWithVatoInteractable, viewController: CCChatWithVatoViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: CCChatWithVatoRouting's members
extension CCChatWithVatoRouter: CCChatWithVatoRouting {
    
}

// MARK: Class's private methods
private extension CCChatWithVatoRouter {
}

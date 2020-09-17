//  File name   : WalletTripRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletTripInteractable: Interactable {
    var router: WalletTripRouting? { get set }
    var listener: WalletTripListener? { get set }
}

protocol WalletTripViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletTripRouter: ViewableRouter<WalletTripInteractable, WalletTripViewControllable> {
    /// Class's constructor.
    override init(interactor: WalletTripInteractable, viewController: WalletTripViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: WalletTripRouting's members
extension WalletTripRouter: WalletTripRouting {
    
}

// MARK: Class's private methods
private extension WalletTripRouter {
}

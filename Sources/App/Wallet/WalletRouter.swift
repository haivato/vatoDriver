//  File name   : WalletRouter.swift
//
//  Author      : Dung Vu
//  Created date: 5/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletInteractable: Interactable {
    var router: WalletRouting? { get set }
    var listener: WalletListener? { get set }
}

protocol WalletViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletRouter: ViewableRouter<WalletInteractable, WalletViewControllable> {
    /// Class's constructor.
    override init(interactor: WalletInteractable, viewController: WalletViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: WalletRouting's members
extension WalletRouter: WalletRouting {
    
}

// MARK: Class's private methods
private extension WalletRouter {
}

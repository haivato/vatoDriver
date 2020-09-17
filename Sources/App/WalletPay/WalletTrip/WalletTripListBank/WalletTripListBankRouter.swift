//  File name   : WalletTripListBankRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletTripListBankInteractable: Interactable {
    var router: WalletTripListBankRouting? { get set }
    var listener: WalletTripListBankListener? { get set }
}

protocol WalletTripListBankViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletTripListBankRouter: ViewableRouter<WalletTripListBankInteractable, WalletTripListBankViewControllable> {
    /// Class's constructor.
    override init(interactor: WalletTripListBankInteractable, viewController: WalletTripListBankViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: WalletTripListBankRouting's members
extension WalletTripListBankRouter: WalletTripListBankRouting {
    
}

// MARK: Class's private methods
private extension WalletTripListBankRouter {
}

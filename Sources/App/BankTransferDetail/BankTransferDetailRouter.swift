//  File name   : BankTransferDetailRouter.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BankTransferDetailInteractable: Interactable {
    var router: BankTransferDetailRouting? { get set }
    var listener: BankTransferDetailListener? { get set }
}

protocol BankTransferDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BankTransferDetailRouter: ViewableRouter<BankTransferDetailInteractable, BankTransferDetailViewControllable> {
    /// Class's constructor.
    override init(interactor: BankTransferDetailInteractable, viewController: BankTransferDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: BankTransferDetailRouting's members
extension BankTransferDetailRouter: BankTransferDetailRouting {
    
}

// MARK: Class's private methods
private extension BankTransferDetailRouter {
}

//  File name   : BankTransferRouter.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BankTransferInteractable: Interactable, BankTransferDetailListener {
    var router: BankTransferRouting? { get set }
    var listener: BankTransferListener? { get set }
}

protocol BankTransferViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BankTransferRouter: ViewableRouter<BankTransferInteractable, BankTransferViewControllable> {
    /// Class's constructor.
    init(interactor: BankTransferInteractable,
         viewController: BankTransferViewControllable,
         bankTransferDetailBuilder: BankTransferDetailBuildable)
    {
        self.bankTransferDetailBuilder = bankTransferDetailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let bankTransferDetailBuilder: BankTransferDetailBuildable
}

// MARK: BankTransferRouting's members
extension BankTransferRouter: BankTransferRouting {
    func routeToBankTransferDetail(bank: FirebaseModel.BankTransferConfig) {
        let router = bankTransferDetailBuilder.build(withListener: interactor, bank: bank)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension BankTransferRouter {
}

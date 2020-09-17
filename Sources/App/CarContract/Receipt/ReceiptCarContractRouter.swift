//  File name   : ReceiptCarContractRouter.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ReceiptCarContractInteractable: Interactable {
    var router: ReceiptCarContractRouting? { get set }
    var listener: ReceiptCarContractListener? { get set }
}

protocol ReceiptCarContractViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ReceiptCarContractRouter: ViewableRouter<ReceiptCarContractInteractable, ReceiptCarContractViewControllable> {
    /// Class's constructor.
    override init(interactor: ReceiptCarContractInteractable, viewController: ReceiptCarContractViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ReceiptCarContractRouting's members
extension ReceiptCarContractRouter: ReceiptCarContractRouting {
    
}

// MARK: Class's private methods
private extension ReceiptCarContractRouter {
}

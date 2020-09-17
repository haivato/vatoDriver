//  File name   : ListBankRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ListBankInteractable: Interactable {
    var router: ListBankRouting? { get set }
    var listener: ListBankListener? { get set }
}

protocol ListBankViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ListBankRouter: ViewableRouter<ListBankInteractable, ListBankViewControllable> {
    /// Class's constructor.
    override init(interactor: ListBankInteractable, viewController: ListBankViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ListBankRouting's members
extension ListBankRouter: ListBankRouting {
    
}

// MARK: Class's private methods
private extension ListBankRouter {
}

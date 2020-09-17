//  File name   : AddDestinationConfirmRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol AddDestinationConfirmInteractable: Interactable {
    var router: AddDestinationConfirmRouting? { get set }
    var listener: AddDestinationConfirmListener? { get set }
}

protocol AddDestinationConfirmViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class AddDestinationConfirmRouter: ViewableRouter<AddDestinationConfirmInteractable, AddDestinationConfirmViewControllable> {
    /// Class's constructor.
    override init(interactor: AddDestinationConfirmInteractable, viewController: AddDestinationConfirmViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: AddDestinationConfirmRouting's members
extension AddDestinationConfirmRouter: AddDestinationConfirmRouting {
    
}

// MARK: Class's private methods
private extension AddDestinationConfirmRouter {
}

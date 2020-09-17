//  File name   : BUSelectStationRouter.swift
//
//  Author      : vato.
//  Created date: 3/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BUSelectStationInteractable: Interactable {
    var router: BUSelectStationRouting? { get set }
    var listener: BUSelectStationListener? { get set }
}

protocol BUSelectStationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BUSelectStationRouter: ViewableRouter<BUSelectStationInteractable, BUSelectStationViewControllable> {
    /// Class's constructor.
    override init(interactor: BUSelectStationInteractable, viewController: BUSelectStationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: BUSelectStationRouting's members
extension BUSelectStationRouter: BUSelectStationRouting {
    
}

// MARK: Class's private methods
private extension BUSelectStationRouter {
}

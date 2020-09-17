//  File name   : PinAddressRouter.swift
//
//  Author      : vato.
//  Created date: 8/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol PinAddressInteractable: Interactable {
    var router: PinAddressRouting? { get set }
    var listener: PinAddressListener? { get set }
}

protocol PinAddressViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PinAddressRouter: ViewableRouter<PinAddressInteractable, PinAddressViewControllable> {
    /// Class's constructor.
    init(interactor: PinAddressInteractable,
                  viewController: PinAddressViewControllable,
                  defautPlace: AddressProtocol?) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: PinAddressRouting's members
extension PinAddressRouter: PinAddressRouting {
    
}

// MARK: Class's private methods
private extension PinAddressRouter {
}

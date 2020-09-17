//  File name   : SwitchPaymentRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol SwitchPaymentInteractable: Interactable {
    var router: SwitchPaymentRouting? { get set }
    var listener: SwitchPaymentListener? { get set }
}

protocol SwitchPaymentViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SwitchPaymentRouter: ViewableRouter<SwitchPaymentInteractable, SwitchPaymentViewControllable>, SwitchPaymentRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: SwitchPaymentInteractable,
         viewController: SwitchPaymentViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    
    
}

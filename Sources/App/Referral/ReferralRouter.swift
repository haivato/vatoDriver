//  File name   : ReferralRouter.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ReferralInteractable: Interactable {
    var router: ReferralRouting? { get set }
    var listener: ReferralListener? { get set }
}

protocol ReferralViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
    func showError(from error: Error)
}

final class ReferralRouter: ViewableRouter<ReferralInteractable, ReferralViewControllable>, ReferralRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: ReferralInteractable, viewController: ReferralViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func showError(from error: Error) {
        self.viewController.showError(from: error)
    }
}

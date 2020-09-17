//  File name   : WalletDetailHistoryRouter.swift
//
//  Author      : Dung Vu
//  Created date: 12/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletDetailHistoryInteractable: Interactable {
    var router: WalletDetailHistoryRouting? { get set }
    var listener: WalletDetailHistoryListener? { get set }
}

protocol WalletDetailHistoryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletDetailHistoryRouter: ViewableRouter<WalletDetailHistoryInteractable, WalletDetailHistoryViewControllable>, WalletDetailHistoryRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: WalletDetailHistoryInteractable, viewController: WalletDetailHistoryViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

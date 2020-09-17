//  File name   : WalletListHistoryRouter.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletListHistoryInteractable: Interactable, WalletDetailHistoryListener {
    var router: WalletListHistoryRouting? { get set }
    var listener: WalletListHistoryListener? { get set }
}

protocol WalletListHistoryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletListHistoryRouter: ViewableRouter<WalletListHistoryInteractable, WalletListHistoryViewControllable>, WalletListHistoryRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    init(interactor: WalletListHistoryInteractable, viewController: WalletListHistoryViewControllable, historyDetailBuilder: WalletDetailHistoryBuildable) {
        self.historyDetailBuilder = historyDetailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func showDetail(by item: WalletItemDisplayProtocol) {
//        let route = historyDetailBuilder.build(withListener: self.interactor, use: .detail(item: item))
//        let transition = RibsRouting(use: route, transitionType: .push, needRemoveCurrent: true)
//        self.perform(with: transition, completion: nil)
    }
    
    private let historyDetailBuilder: WalletDetailHistoryBuildable
}

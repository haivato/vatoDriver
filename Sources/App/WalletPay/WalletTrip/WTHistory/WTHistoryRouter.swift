//  File name   : WTHistoryRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WTHistoryInteractable: Interactable {
    var router: WTHistoryRouting? { get set }
    var listener: WTHistoryListener? { get set }
}

protocol WTHistoryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WTHistoryRouter: ViewableRouter<WTHistoryInteractable, WTHistoryViewControllable> {
    /// Class's constructor.
    override init(interactor: WTHistoryInteractable, viewController: WTHistoryViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: WTHistoryRouting's members
extension WTHistoryRouter: WTHistoryRouting {
    
}

// MARK: Class's private methods
private extension WTHistoryRouter {
}

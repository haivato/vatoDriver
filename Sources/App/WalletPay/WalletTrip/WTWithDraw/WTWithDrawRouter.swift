//  File name   : WTWithDrawRouter.swift
//
//  Author      : admin
//  Created date: 6/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WTWithDrawInteractable: Interactable, WTWithDrawConfirmListener {
    var router: WTWithDrawRouting? { get set }
    var listener: WTWithDrawListener? { get set }
}

protocol WTWithDrawViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WTWithDrawRouter: ViewableRouter<WTWithDrawInteractable, WTWithDrawViewControllable> {
    /// Class's constructor.
//    override init(interactor: WTWithDrawInteractable, viewController: WTWithDrawViewControllable) {
//        super.init(interactor: interactor, viewController: viewController)
//        interactor.router = self
//    }
    init(interactor: WTWithDrawInteractable, viewController: WTWithDrawViewControllable, wtWithDrawConfirm: WTWithDrawConfirmBuildable) {
        self.wtWithDrawConfirm = wtWithDrawConfirm
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let wtWithDrawConfirm: WTWithDrawConfirmBuildable
}

// MARK: WTWithDrawRouting's members
extension WTWithDrawRouter: WTWithDrawRouting {
    func moveToWithDrawCF(item: UserBankInfo, balance: DriverBalance) {
        let route = wtWithDrawConfirm.build(withListener: interactor, item: item, balance: balance)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension WTWithDrawRouter {
}

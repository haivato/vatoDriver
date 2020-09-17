//  File name   : BuyPointRouter.swift
//
//  Author      : admin
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BuyPointInteractable: Interactable, WTWithDrawConfirmListener {
    var router: BuyPointRouting? { get set }
    var listener: BuyPointListener? { get set }
}

protocol BuyPointViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BuyPointRouter: ViewableRouter<BuyPointInteractable, BuyPointViewControllable> {
    /// Class's constructor.
    init(interactor: BuyPointInteractable, viewController: BuyPointViewControllable, wtWithDrawConfirm: WTWithDrawConfirmBuildable) {
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

// MARK: BuyPointRouting's members
extension BuyPointRouter: BuyPointRouting {
    
    func moveToWithDrawCF(item: TopupCellModel, point: Int, balance: DriverBalance) {
        let route = wtWithDrawConfirm.build(withListener: interactor, item: item, point: point, balance: balance)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension BuyPointRouter {
}

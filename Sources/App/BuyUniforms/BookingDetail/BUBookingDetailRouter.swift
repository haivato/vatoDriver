//  File name   : BUBookingDetailRouter.swift
//
//  Author      : vato.
//  Created date: 3/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BUBookingDetailInteractable: Interactable, SwitchPaymentListener {
    var router: BUBookingDetailRouting? { get set }
    var listener: BUBookingDetailListener? { get set }
}

protocol BUBookingDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BUBookingDetailRouter: ViewableRouter<BUBookingDetailInteractable, BUBookingDetailViewControllable> {
    /// Class's constructor.
    init(interactor: BUBookingDetailInteractable,
         viewController: BUBookingDetailViewControllable,
         switchPaymentBuildable: SwitchPaymentBuildable)
    {
        self.switchPaymentBuildable = switchPaymentBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let switchPaymentBuildable: SwitchPaymentBuildable
}

// MARK: BUBookingDetailRouting's members
extension BUBookingDetailRouter: BUBookingDetailRouting {
    func routeToSwitchPayment(card: PaymentCardDetail) {
        let route = switchPaymentBuildable.build(withListener: interactor, currentSelect: card)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension BUBookingDetailRouter {
}

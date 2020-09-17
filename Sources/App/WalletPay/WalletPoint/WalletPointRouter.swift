//  File name   : WalletPointRouter.swift
//
//  Author      : admin
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletPointInteractable: Interactable, BuyPointListener, LinkingCardListener, WalletListHistoryListener {
    var router: WalletPointRouting? { get set }
    var listener: WalletPointListener? { get set }
}

protocol WalletPointViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletPointRouter: ViewableRouter<WalletPointInteractable, WalletPointViewControllable> {
    /// Class's constructor.
    init(interactor: WalletPointInteractable,
         viewController: WalletPointViewControllable,
         buyPointMainBuildable: BuyPointBuildable,
         linkCardMainBuildable: LinkingCardBuildable,
         walletListHistory: WalletListHistoryBuildable) {
        self.buyPointMainBuildable = buyPointMainBuildable
        self.linkCardMainBuildable = linkCardMainBuildable
        self.walletListHistory = walletListHistory
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let buyPointMainBuildable: BuyPointBuildable
    private let linkCardMainBuildable: LinkingCardBuildable
    private let walletListHistory: WalletListHistoryBuildable
    private var type: ListHistoryType = .credit
    
}

// MARK: WalletReceiveBookingRouting's members
extension WalletPointRouter: WalletPointRouting {
    
    func gotoBuyPoint(_ list: [Any], balance: DriverBalance?, index: IndexPath) {
        let route = buyPointMainBuildable.build(withListener: interactor, allList: list, balance: balance, indexSelect: index)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }

    func gotoLinkCard(listCardNapas: [PaymentCardType]) {
        let route =  linkCardMainBuildable.build(withListener: interactor, listCardNapas: listCardNapas)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    func moveToListHistoryCredit() {
        let route = walletListHistory.build(withListener: interactor, balanceType: type.rawValue)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension WalletPointRouter {
}

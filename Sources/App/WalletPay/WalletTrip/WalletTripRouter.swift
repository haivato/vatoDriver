//  File name   : WalletTripRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol WalletTripInteractable: Interactable, WalletAddNewBankListener, BuyPointListener, WalletListHistoryListener, WTWithDrawListener {
    var router: WalletTripRouting? { get set }
    var listener: WalletTripListener? { get set }
}

protocol WalletTripViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletTripRouter: ViewableRouter<WalletTripInteractable, WalletTripViewControllable> {
    /// Class's constructor.
    init(interactor: WalletTripInteractable,
         viewController: WalletTripViewControllable,
         addNewBankBuildable: WalletAddNewBankBuildable,
         withdrawConfirmBuildable: WTWithDrawConfirmBuildable,
         wtBuyPoint: BuyPointBuildable,
         walletListHistory: WalletListHistoryBuildable,
         wtWithDraw: WTWithDrawBuildable) {
        self.addNewBankBuildable = addNewBankBuildable
        self.withdrawConfirmBuildable = withdrawConfirmBuildable
        self.wtBuyPoint = wtBuyPoint
        self.walletListHistory = walletListHistory
        self.wtWithDraw = wtWithDraw
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    private let addNewBankBuildable: WalletAddNewBankBuildable
    private let withdrawConfirmBuildable: WTWithDrawConfirmBuildable
    private let wtBuyPoint: BuyPointBuildable
    private let wtWithDraw: WTWithDrawBuildable
    private let walletListHistory: WalletListHistoryBuildable
    private var type: ListHistoryType = .hardCash
    
    /// Class's private properties.
}

// MARK: WalletTripRouting's members
extension WalletTripRouter: WalletTripRouting {
    func moveToWithDraw(listUserBank: [UserBankInfo], balance: DriverBalance) {
        let route = wtWithDraw.build(withListener: interactor, listUserBank: listUserBank, balance: balance)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    func moveAddBank(user: UserBankInfo?) {
        let route = addNewBankBuildable.build(withListener: interactor, user: user)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
        
    func moveToHistoryWallet() {
        let route = walletListHistory.build(withListener: interactor, balanceType: type.rawValue)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension WalletTripRouter {
}

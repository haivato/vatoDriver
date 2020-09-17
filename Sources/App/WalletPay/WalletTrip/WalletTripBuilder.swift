//  File name   : WalletTripBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WalletTripDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
}

final class WalletTripComponent: Component<WalletTripDependency> {
    /// Class's public properties.
    let WalletTripVC: WalletTripVC
    
    /// Class's constructor.
    init(dependency: WalletTripDependency, WalletTripVC: WalletTripVC) {
        self.WalletTripVC = WalletTripVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WalletTripBuildable: Buildable {
    func build(withListener listener: WalletTripListener, balance: FCBalance) -> WalletTripRouting
}

final class WalletTripBuilder: Builder<WalletTripDependency>, WalletTripBuildable {
    /// Class's constructor.
    override init(dependency: WalletTripDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WalletTripBuildable's members
    func build(withListener listener: WalletTripListener, balance: FCBalance) -> WalletTripRouting {
        guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: WalletTripVC.identifier) as? WalletTripVC else { fatalError("Please Implement") }
        let component = WalletTripComponent(dependency: dependency, WalletTripVC: vc)

        let interactor = WalletTripInteractor(presenter: component.WalletTripVC, balance: balance)
        interactor.listener = listener
        
        let addNewBankBuilder = WalletAddNewBankBuilder(dependency: component)
        let withdrawConfirmBuilder = WTWithDrawConfirmBuilder(dependency: component)
        let wtBuyPoint = BuyPointBuilder(dependency: component)
        let walletListHistory = WalletListHistoryBuilder(dependency: component)
        let withdraw = WTWithDrawBuilder(dependency: component)

        // todo: Create builder modules builders and inject into router here.
        
        return WalletTripRouter(interactor: interactor,
                                viewController: component.WalletTripVC,
                                addNewBankBuildable: addNewBankBuilder,
                                withdrawConfirmBuildable: withdrawConfirmBuilder,
                                wtBuyPoint: wtBuyPoint,
                                walletListHistory: walletListHistory, wtWithDraw: withdraw)
    }
}

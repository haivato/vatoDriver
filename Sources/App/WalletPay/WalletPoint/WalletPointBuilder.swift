//  File name   : WalletPointBuilder.swift
//
//  Author      : admin
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WalletPointDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
}

final class WalletPointComponent: Component<WalletPointDependency> {
    /// Class's public properties.
    let WalletPointVC: WalletPointVC
    
    /// Class's constructor.
    init(dependency: WalletPointDependency, WalletPointVC: WalletPointVC) {
        self.WalletPointVC = WalletPointVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WalletPointBuildable: Buildable {
    func build(withListener listener: WalletPointListener) -> WalletPointRouting
}

final class WalletPointBuilder: Builder<WalletPointDependency>, WalletPointBuildable {
    /// Class's constructor.
    override init(dependency: WalletPointDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WalletPointBuildable's members
    func build(withListener listener: WalletPointListener) -> WalletPointRouting {
        guard let vc = UIStoryboard(name: "WalletPointVC", bundle: nil).instantiateViewController(withIdentifier: "walletdraft") as? WalletPointVC else { fatalError("Please Implement") }

        let component = WalletPointComponent(dependency: dependency, WalletPointVC: vc)

        let interactor = WalletPointInteractor(presenter: component.WalletPointVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let buyPointMainBuildable = BuyPointBuilder(dependency: component)
        let linkCardMainBuildable = LinkingCardBuilder(dependency: component)
        let walletListHistory = WalletListHistoryBuilder(dependency: component)

        return WalletPointRouter(interactor: interactor,
                                          viewController: component.WalletPointVC,
                                          buyPointMainBuildable: buyPointMainBuildable,
                                          linkCardMainBuildable: linkCardMainBuildable,
                                          walletListHistory: walletListHistory)
    }
}


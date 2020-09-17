//  File name   : WalletListHistoryBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol WalletListHistoryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
}

final class WalletListHistoryComponent: Component<WalletListHistoryDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WalletListHistoryBuildable: Buildable {
    func build(withListener listener: WalletListHistoryListener, balanceType: Int) -> WalletListHistoryRouting
}

final class WalletListHistoryBuilder: Builder<WalletListHistoryDependency>, WalletListHistoryBuildable {

    override init(dependency: WalletListHistoryDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: WalletListHistoryListener, balanceType: Int) -> WalletListHistoryRouting {
        let component = WalletListHistoryComponent(dependency: dependency)
        let viewController = WalletListHistoryVC()

        let interactor = WalletListHistoryInteractor(presenter: viewController,
                                                     authenticated: component.dependency.authenticated, balanceType: balanceType)
        interactor.listener = listener
        let historyDetailBuilder = WalletDetailHistoryBuilder(dependency: component)
        return WalletListHistoryRouter(interactor: interactor, viewController: viewController, historyDetailBuilder: historyDetailBuilder)
    }
}

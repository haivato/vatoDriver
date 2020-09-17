//  File name   : WalletDetailHistoryBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 12/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol WalletDetailHistoryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
}

final class WalletDetailHistoryComponent: Component<WalletDetailHistoryDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
enum WalletDetailHistoryType {
    case detail(item: WalletItemDisplayProtocol)
    case refer(id: String)
}

protocol WalletDetailHistoryBuildable: Buildable {
    func build(withListener listener: WalletDetailHistoryListener, use type: WalletDetailHistoryType) -> WalletDetailHistoryRouting
}

final class WalletDetailHistoryBuilder: Builder<WalletDetailHistoryDependency>, WalletDetailHistoryBuildable {

    override init(dependency: WalletDetailHistoryDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: WalletDetailHistoryListener, use type: WalletDetailHistoryType) -> WalletDetailHistoryRouting {
        let component = WalletDetailHistoryComponent(dependency: dependency)
        let viewController = WalletDetailHistoryVC()

        let interactor = WalletDetailHistoryInteractor(presenter: viewController,
                                                       authenticated: component.dependency.authenticated,
                                                       type: type)
        interactor.listener = listener

        return WalletDetailHistoryRouter(interactor: interactor, viewController: viewController)
    }
}

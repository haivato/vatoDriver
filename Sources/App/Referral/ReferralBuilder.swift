//  File name   : ReferralBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol ReferralDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
}

final class ReferralComponent: Component<ReferralDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ReferralBuildable: Buildable {
    func build(withListener listener: ReferralListener) -> ReferralRouting
}

final class ReferralBuilder: Builder<ReferralDependency>, ReferralBuildable {

    override init(dependency: ReferralDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ReferralListener) -> ReferralRouting {
        let component = ReferralComponent(dependency: dependency)
        let viewController = ReferralVC()

        let interactor = ReferralInteractor(presenter: viewController, authenticatedStream: component.dependency.authenticatedStream)
        interactor.listener = listener

        return ReferralRouter(interactor: interactor, viewController: viewController)
    }
}

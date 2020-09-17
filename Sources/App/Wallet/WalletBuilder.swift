//  File name   : WalletBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 5/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WalletDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class WalletComponent: Component<WalletDependency> {
    /// Class's public properties.
    let WalletVC: WalletVC
    
    /// Class's constructor.
    init(dependency: WalletDependency, WalletVC: WalletVC) {
        self.WalletVC = WalletVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WalletBuildable: Buildable {
    func build(withListener listener: WalletListener) -> WalletRouting
}

final class WalletBuilder: Builder<WalletDependency>, WalletBuildable {
    /// Class's constructor.
    override init(dependency: WalletDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WalletBuildable's members
    func build(withListener listener: WalletListener) -> WalletRouting {
        let vc = WalletVC()
        let component = WalletComponent(dependency: dependency, WalletVC: vc)

        let interactor = WalletInteractor(presenter: component.WalletVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return WalletRouter(interactor: interactor, viewController: component.WalletVC)
    }
}

//  File name   : WTHistoryBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 5/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol WTHistoryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class WTHistoryComponent: Component<WTHistoryDependency> {
    /// Class's public properties.
    let WTHistoryVC: WTHistoryVC
    
    /// Class's constructor.
    init(dependency: WTHistoryDependency, WTHistoryVC: WTHistoryVC) {
        self.WTHistoryVC = WTHistoryVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WTHistoryBuildable: Buildable {
    func build(withListener listener: WTHistoryListener) -> WTHistoryRouting
}

final class WTHistoryBuilder: Builder<WTHistoryDependency>, WTHistoryBuildable {
    /// Class's constructor.
    override init(dependency: WTHistoryDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: WTHistoryBuildable's members
    func build(withListener listener: WTHistoryListener) -> WTHistoryRouting {
        guard let vc = UIStoryboard(name: "WalletTripVC", bundle: nil).instantiateViewController(withIdentifier: WTHistoryVC.identifier) as? WTHistoryVC else { fatalError("Please Implement") }
        let component = WTHistoryComponent(dependency: dependency, WTHistoryVC: vc)

        let interactor = WTHistoryInteractor(presenter: component.WTHistoryVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return WTHistoryRouter(interactor: interactor, viewController: component.WTHistoryVC)
    }
}

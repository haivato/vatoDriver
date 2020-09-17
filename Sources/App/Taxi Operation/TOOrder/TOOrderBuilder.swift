//  File name   : TOOrderBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 2/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TOOrderDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class TOOrderComponent: Component<TOOrderDependency> {
    /// Class's public properties.
    let TOOrderVC: TOOrderVC
    
    /// Class's constructor.
    init(dependency: TOOrderDependency, TOOrderVC: TOOrderVC) {
        self.TOOrderVC = TOOrderVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TOOrderBuildable: Buildable {
    func build(withListener listener: TOOrderListener) -> TOOrderRouting
}

final class TOOrderBuilder: Builder<TOOrderDependency>, TOOrderBuildable {
    /// Class's constructor.
    override init(dependency: TOOrderDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TOOrderBuildable's members
    func build(withListener listener: TOOrderListener) -> TOOrderRouting {
        let vc = TOOrderVC()
        let component = TOOrderComponent(dependency: dependency, TOOrderVC: vc)

        let interactor = TOOrderInteractor(presenter: component.TOOrderVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let tODetailLocationBuilder = TODetailLocationBuilder(dependency: component)
        return TOOrderRouter(interactor: interactor, viewController: component.TOOrderVC, tODetailLocationBuildable: tODetailLocationBuilder)
    }
}

//  File name   : BUSelectStationBuilder.swift
//
//  Author      : vato.
//  Created date: 3/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BUSelectStationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutableStoreStream: MutableStoreStream { get }
}

final class BUSelectStationComponent: Component<BUSelectStationDependency> {
    /// Class's public properties.
    let selectStationVC: BUSelectStationVC
    
    /// Class's constructor.
    init(dependency: BUSelectStationDependency, selectStationVC: BUSelectStationVC) {
        self.selectStationVC = selectStationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BUSelectStationBuildable: Buildable {
    func build(withListener listener: BUSelectStationListener, categoryId: Int, coordinate: CLLocationCoordinate2D) -> BUSelectStationRouting
}

final class BUSelectStationBuilder: Builder<BUSelectStationDependency>, BUSelectStationBuildable {
    /// Class's constructor.
    override init(dependency: BUSelectStationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BUSelectStationBuildable's members
    func build(withListener listener: BUSelectStationListener, categoryId: Int, coordinate: CLLocationCoordinate2D) -> BUSelectStationRouting {
        let vc = BUSelectStationVC()
        let component = BUSelectStationComponent(dependency: dependency, selectStationVC: vc)

        let interactor = BUSelectStationInteractor(presenter: component.selectStationVC,
                                                   mutableStoreStream: dependency.mutableStoreStream,
                                                   categoryId: categoryId,
                                                   coordinate: coordinate)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return BUSelectStationRouter(interactor: interactor, viewController: component.selectStationVC)
    }
}

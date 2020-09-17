//  File name   : TODetailLocationBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TODetailLocationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class TODetailLocationComponent: Component<TODetailLocationDependency> {
    /// Class's public properties.
    let TODetailLocationVC: TODetailLocationVC
    
    /// Class's constructor.
    init(dependency: TODetailLocationDependency, TODetailLocationVC: TODetailLocationVC) {
        self.TODetailLocationVC = TODetailLocationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TODetailLocationBuildable: Buildable {
    func build(withListener listener: TODetailLocationListener,
               pickUpStationId: Int?,
               firestore_listener_path: String?) -> TODetailLocationRouting
}

final class TODetailLocationBuilder: Builder<TODetailLocationDependency>, TODetailLocationBuildable {
    /// Class's constructor.
    override init(dependency: TODetailLocationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TODetailLocationBuildable's members
    func build(withListener listener: TODetailLocationListener,
               pickUpStationId: Int?,
               firestore_listener_path: String?) -> TODetailLocationRouting {
        let vc = TODetailLocationVC()
        let component = TODetailLocationComponent(dependency: dependency, TODetailLocationVC: vc)

        let interactor = TODetailLocationInteractor(presenter: component.TODetailLocationVC,
                                                    pickUpStationId: pickUpStationId,
                                                    firestore_listener_path: firestore_listener_path)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return TODetailLocationRouter(interactor: interactor, viewController: component.TODetailLocationVC)
    }
}

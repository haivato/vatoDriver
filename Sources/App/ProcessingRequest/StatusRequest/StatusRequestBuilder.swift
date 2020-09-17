//  File name   : StatusRequestBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 4/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol StatusRequestDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class StatusRequestComponent: Component<StatusRequestDependency> {
    /// Class's public properties.
    let StatusRequestVC: StatusRequestVC
    
    /// Class's constructor.
    init(dependency: StatusRequestDependency, StatusRequestVC: StatusRequestVC) {
        self.StatusRequestVC = StatusRequestVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol StatusRequestBuildable: Buildable {
    func build(withListener listener: StatusRequestListener, item: RequestResponseDetail?, itemFood: UserRequestTypeFireStore?, keyFood: String?) -> StatusRequestRouting
}

final class StatusRequestBuilder: Builder<StatusRequestDependency>, StatusRequestBuildable {
    /// Class's constructor.
    override init(dependency: StatusRequestDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: StatusRequestBuildable's members
    func build(withListener listener: StatusRequestListener, item: RequestResponseDetail?, itemFood: UserRequestTypeFireStore?, keyFood: String?) -> StatusRequestRouting {
        let vc = StatusRequestVC(nibName: StatusRequestVC.identifier, bundle: nil)
        let component = StatusRequestComponent(dependency: dependency, StatusRequestVC: vc)

        let interactor = StatusRequestInteractor(presenter: component.StatusRequestVC, item: item, itemFood: itemFood, keyFood: keyFood)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return StatusRequestRouter(interactor: interactor, viewController: component.StatusRequestVC)
    }
}

//  File name   : RegisterServiceBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol RegisterServiceDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class RegisterServiceComponent: Component<RegisterServiceDependency> {
    /// Class's public properties.
    let RegisterServiceVC: RegisterServiceVC
    
    /// Class's constructor.
    init(dependency: RegisterServiceDependency, RegisterServiceVC: RegisterServiceVC) {
        self.RegisterServiceVC = RegisterServiceVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol RegisterServiceBuildable: Buildable {
    func build(withListener listener: RegisterServiceListener, type: RegisterServiceType, listCar: [CarInfo]) -> RegisterServiceRouting
}

final class RegisterServiceBuilder: Builder<RegisterServiceDependency>, RegisterServiceBuildable {
    /// Class's constructor.
    override init(dependency: RegisterServiceDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: RegisterServiceBuildable's members
    func build(withListener listener: RegisterServiceListener, type: RegisterServiceType, listCar: [CarInfo]) -> RegisterServiceRouting {
        let vc = RegisterServiceVC(nibName: RegisterServiceVC.identifier, bundle: nil)
        let component = RegisterServiceComponent(dependency: dependency, RegisterServiceVC: vc)

        let interactor = RegisterServiceInteractor(presenter: component.RegisterServiceVC, listCar: listCar)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return RegisterServiceRouter(interactor: interactor, viewController: component.RegisterServiceVC)
    }
}

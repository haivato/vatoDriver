//  File name   : RSListServiceBuilder.swift
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
protocol RSListServiceDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class RSListServiceComponent: Component<RSListServiceDependency> {
    /// Class's public properties.
    let RSListServiceVC: RSListServiceVC
    
    /// Class's constructor.
    init(dependency: RSListServiceDependency, RSListServiceVC: RSListServiceVC) {
        self.RSListServiceVC = RSListServiceVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol RSListServiceBuildable: Buildable {
    func build(withListener listener: RSListServiceListener, listCar: [CarInfo]?, listService: [CarInfo]?, isFromManageCar: Bool, carManage: FCUCar?) -> RSListServiceRouting
}

final class RSListServiceBuilder: Builder<RSListServiceDependency>, RSListServiceBuildable {
    /// Class's constructor.
    override init(dependency: RSListServiceDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: RSListServiceBuildable's members
    func build(withListener listener: RSListServiceListener, listCar: [CarInfo]?, listService: [CarInfo]?, isFromManageCar: Bool, carManage: FCUCar?) -> RSListServiceRouting {
        let vc = RSListServiceVC(nibName: RSListServiceVC.identifier, bundle: nil)
        let component = RSListServiceComponent(dependency: dependency, RSListServiceVC: vc)

        let interactor = RSListServiceInteractor(presenter: component.RSListServiceVC, listCar: listCar, listService: listService, isFromManageCar: isFromManageCar, carManage: carManage)
        interactor.listener = listener
        
        let registerServiceBuilder = RegisterServiceBuilder(dependency: component)
        let rsPolicyBuildable = RSPolicyBuilder(dependency: component)

        // todo: Create builder modules builders and inject into router here.
        
        return RSListServiceRouter(interactor: interactor,
                                   viewController: component.RSListServiceVC,
                                   registerServiceBuildable: registerServiceBuilder, rsPolicyBuildable: rsPolicyBuildable)
    }
}

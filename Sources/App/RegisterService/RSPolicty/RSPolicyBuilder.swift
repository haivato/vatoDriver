//  File name   : RSPolicyBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol RSPolicyDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class RSPolicyComponent: Component<RSPolicyDependency> {
    /// Class's public properties.
    let RSPolicyVC: RSPolicyVC
    
    /// Class's constructor.
    init(dependency: RSPolicyDependency, RSPolicyVC: RSPolicyVC) {
        self.RSPolicyVC = RSPolicyVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol RSPolicyBuildable: Buildable {
    func build(withListener listener: RSPolicyListener, array: [ListServiceVehicel], strHtml: String, itemCarId: Int64, isFromManage: Bool) -> RSPolicyRouting
}

final class RSPolicyBuilder: Builder<RSPolicyDependency>, RSPolicyBuildable {
    /// Class's constructor.
    override init(dependency: RSPolicyDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: RSPolicyBuildable's members
    func build(withListener listener: RSPolicyListener, array: [ListServiceVehicel], strHtml: String, itemCarId: Int64, isFromManage: Bool) -> RSPolicyRouting {
        let vc = RSPolicyVC(nibName: RSPolicyVC.identifier, bundle: nil)
        let component = RSPolicyComponent(dependency: dependency, RSPolicyVC: vc)

        let interactor = RSPolicyInteractor(presenter: component.RSPolicyVC, array: array, strHtml: strHtml, itemCar: itemCarId, isFromManage: isFromManage)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return RSPolicyRouter(interactor: interactor, viewController: component.RSPolicyVC)
    }
}

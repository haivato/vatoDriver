//  File name   : FoodReceivePackageBuilder.swift
//
//  Author      : vato.
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FoodReceivePackageDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class FoodReceivePackageComponent: Component<FoodReceivePackageDependency> {
    /// Class's public properties.
    let FoodReceivePackageVC: FoodReceivePackageVC
    
    /// Class's constructor.
    init(dependency: FoodReceivePackageDependency, FoodReceivePackageVC: FoodReceivePackageVC) {
        self.FoodReceivePackageVC = FoodReceivePackageVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FoodReceivePackageBuildable: Buildable {
    func build(withListener listener: FoodReceivePackageListener,
               bookInfo: FCBookInfo,
               bookingService: FCBookingService,
               type: FoodReceivePackageType) -> FoodReceivePackageRouting
}

final class FoodReceivePackageBuilder: Builder<FoodReceivePackageDependency>, FoodReceivePackageBuildable {
    /// Class's constructor.
    override init(dependency: FoodReceivePackageDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FoodReceivePackageBuildable's members
    func build(withListener listener: FoodReceivePackageListener,
               bookInfo: FCBookInfo,
               bookingService: FCBookingService,
               type: FoodReceivePackageType) -> FoodReceivePackageRouting {
        guard let vc = UIStoryboard(name: "FoodReceivePackage", bundle: nil).instantiateViewController(withIdentifier: FoodReceivePackageVC.identifier) as? FoodReceivePackageVC else { fatalError("Please Implement") }
        
        let component = FoodReceivePackageComponent(dependency: dependency, FoodReceivePackageVC: vc)

        let interactor = FoodReceivePackageInteractor(presenter: component.FoodReceivePackageVC,
                                                      bookInfo: bookInfo,
                                                      bookingService: bookingService,
                                                      type: type)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return FoodReceivePackageRouter(interactor: interactor, viewController: component.FoodReceivePackageVC)
    }
}

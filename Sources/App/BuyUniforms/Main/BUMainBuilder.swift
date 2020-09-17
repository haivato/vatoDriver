//  File name   : BUMainBuilder.swift
//
//  Author      : vato.
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BUMainDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutableBookingStream: MutableBookingStream { get }
}

final class BUMainComponent: Component<BUMainDependency> {
    /// Class's public properties.
    let BUMainVC: BUMainVC
    
    /// Class's constructor.
    init(dependency: BUMainDependency, BUMainVC: BUMainVC) {
        self.BUMainVC = BUMainVC
        super.init(dependency: dependency)
    }
    
    var mutableStoreStream: MutableStoreStream {
        return shared { StoreStreamImpl() }
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BUMainBuildable: Buildable {
    func build(withListener listener: BUMainListener) -> BUMainRouting
}

final class BUMainBuilder: Builder<BUMainDependency>, BUMainBuildable {
    /// Class's constructor.
    override init(dependency: BUMainDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BUMainBuildable's members
    func build(withListener listener: BUMainListener) -> BUMainRouting {
        guard let vc = UIStoryboard(name: "BuyUniform", bundle: nil).instantiateViewController(withIdentifier: BUMainVC.identifier) as? BUMainVC else { fatalError("Please Implement") }
        
        let component = BUMainComponent(dependency: dependency, BUMainVC: vc)

        let interactor = BUMainInteractor(presenter: component.BUMainVC,
                                          mutableStoreStream: component.mutableStoreStream,
                                          mutableBookingStream: component.dependency.mutableBookingStream)
        interactor.listener = listener

        let bookingDetailBuilder = BUBookingDetailBuilder(dependency: component)
        let selectStationBuilder = BUSelectStationBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return BUMainRouter(interactor: interactor,
                            viewController: component.BUMainVC,
                            bookingDetailBuildable: bookingDetailBuilder, selectStationBuildable: selectStationBuilder)
    }
}

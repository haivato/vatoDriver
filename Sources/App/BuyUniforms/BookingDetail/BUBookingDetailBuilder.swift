//  File name   : BUBookingDetailBuilder.swift
//
//  Author      : vato.
//  Created date: 3/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BUBookingDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutableStoreStream: MutableStoreStream { get }
}

final class BUBookingDetailComponent: Component<BUBookingDetailDependency> {
    /// Class's public properties.
    let BUBookingDetailVC: BUBookingDetailVC
    
    /// Class's constructor.
    init(dependency: BUBookingDetailDependency, BUBookingDetailVC: BUBookingDetailVC) {
        self.BUBookingDetailVC = BUBookingDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BUBookingDetailBuildable: Buildable {
    func build(withListener listener: BUBookingDetailListener) -> BUBookingDetailRouting
}

final class BUBookingDetailBuilder: Builder<BUBookingDetailDependency>, BUBookingDetailBuildable {
    /// Class's constructor.
    override init(dependency: BUBookingDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BUBookingDetailBuildable's members
    func build(withListener listener: BUBookingDetailListener) -> BUBookingDetailRouting {
        let vc = BUBookingDetailVC()
        let component = BUBookingDetailComponent(dependency: dependency, BUBookingDetailVC: vc)

        let interactor = BUBookingDetailInteractor(presenter: component.BUBookingDetailVC,
                                                   mutableStoreStream: dependency.mutableStoreStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let switchPaymentBuilder = SwitchPaymentBuilder(dependency: component)
        return BUBookingDetailRouter(interactor: interactor, viewController: component.BUBookingDetailVC, switchPaymentBuildable: switchPaymentBuilder)
    }
}

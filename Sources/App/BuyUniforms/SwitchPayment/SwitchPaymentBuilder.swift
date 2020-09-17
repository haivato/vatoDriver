//  File name   : SwitchPaymentBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase

// MARK: Dependency
protocol SwitchPaymentDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class SwitchPaymentComponent: Component<SwitchPaymentDependency> {
    
    
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol SwitchPaymentBuildable: Buildable {
    func build(withListener listener: SwitchPaymentListener, currentSelect: PaymentCardDetail) -> SwitchPaymentRouting
}

final class SwitchPaymentBuilder: Builder<SwitchPaymentDependency>, SwitchPaymentBuildable {

    override init(dependency: SwitchPaymentDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SwitchPaymentListener, currentSelect: PaymentCardDetail) -> SwitchPaymentRouting {
        let component = SwitchPaymentComponent(dependency: dependency)
        let viewController = SwitchPaymentVC()

        let interactor = SwitchPaymentInteractor(presenter: viewController, currentSelect: currentSelect)
        interactor.listener = listener
        
        return SwitchPaymentRouter(interactor: interactor, viewController: viewController)
    }
}


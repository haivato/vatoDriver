//  File name   : TOShortcutBuilder.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol TOShortcutDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }

}

final class TOShortcutComponent: Component<TOShortcutDependency> {
    /// Class's public properties.
    let TOShortcutVC: TOShortcutVC
    
    /// Class's constructor.
    init(dependency: TOShortcutDependency, TOShortcutVC: TOShortcutVC) {
        self.TOShortcutVC = TOShortcutVC
        super.init(dependency: dependency)
    }
    
    var mutableBookingStream: MutableBookingStream {
        return shared { BookingStreamImpl() }
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TOShortcutBuildable: Buildable {
    func build(withListener listener: TOShortcutListener) -> TOShortcutRouting
}

final class TOShortcutBuilder: Builder<TOShortcutDependency>, TOShortcutBuildable {
    /// Class's constructor.
    override init(dependency: TOShortcutDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TOShortcutBuildable's members
    func build(withListener listener: TOShortcutListener) -> TOShortcutRouting {
        let vc = TOShortcutVC(nibName: TOShortcutVC.identifier, bundle: nil)
        let component = TOShortcutComponent(dependency: dependency, TOShortcutVC: vc)

        let interactor = TOShortcutInteractor(presenter: component.TOShortcutVC, authenticated: self.dependency.authenticated, mutableBookingStream: component.mutableBookingStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let quickSupportMainBuilder = QuickSupportMainBuilder(dependency: component)
        let buyUniformsMainBuilder = BUMainBuilder(dependency: component)
        let tOOrderBuilder = TOOrderBuilder(dependency: component)
        let setLocationBuilder = SetLocationBuilder(dependency: component)
        let processingBuilder = ProcessingRequestBuilder(dependency: component)
        let statusRequestBuilder = StatusRequestBuilder(dependency: component)
        let registerServiceBuilder = RegisterServiceBuilder(dependency: component)
        let rsListService = RSListServiceBuilder(dependency: component)
        return TOShortcutRouter(interactor: interactor,
                                viewController: component.TOShortcutVC,
                                quickSupportMainBuildable: quickSupportMainBuilder,
                                tOOrderBuildable: tOOrderBuilder,
                                buyUniformsMainBuildable: buyUniformsMainBuilder,
                                setLocationBuildable: setLocationBuilder,
                                processingRequestBuildable: processingBuilder,
                                statusRequestBuildable: statusRequestBuilder,
                                registerServiceBuildable: registerServiceBuilder,
                                rsListService: rsListService)
    }
}

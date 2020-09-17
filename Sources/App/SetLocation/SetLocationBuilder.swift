//  File name   : SetLocationBuilder.swift
//
//  Author      : khoi tran
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol SetLocationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var mutableBookingStream: MutableBookingStream { get }

}

final class SetLocationComponent: Component<SetLocationDependency> {
    /// Class's public properties.
    let SetLocationVC: SetLocationVC
    
    /// Class's constructor.
    init(dependency: SetLocationDependency, SetLocationVC: SetLocationVC) {
        self.SetLocationVC = SetLocationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol SetLocationBuildable: Buildable {
    func build(withListener listener: SetLocationListener) -> SetLocationRouting
}

final class SetLocationBuilder: Builder<SetLocationDependency>, SetLocationBuildable {
    /// Class's constructor.
    override init(dependency: SetLocationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: SetLocationBuildable's members
    func build(withListener listener: SetLocationListener) -> SetLocationRouting {
        let vc = SetLocationVC(nibName: SetLocationVC.identifier, bundle: nil)
        let component = SetLocationComponent(dependency: dependency, SetLocationVC: vc)

        let interactor = SetLocationInteractor(presenter: component.SetLocationVC, mutableBookingStream: component.dependency.mutableBookingStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return SetLocationRouter(interactor: interactor, viewController: component.SetLocationVC, locationPickerBuilable: LocationPickerBuilder(dependency: component))
    }
}

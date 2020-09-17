//  File name   : PinAddressBuilder.swift
//
//  Author      : vato.
//  Created date: 8/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol PinAddressDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
}

final class PinAddressComponent: Component<PinAddressDependency> {
    /// Class's public properties.
    let PinAddressVC: PinAddressVC
    
    /// Class's constructor.
    init(dependency: PinAddressDependency, PinAddressVC: PinAddressVC) {
        self.PinAddressVC = PinAddressVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol PinAddressBuildable: Buildable {
    func build(withListener listener: PinAddressListener,
               defautPlace: AddressProtocol?, isOrigin: Bool) -> PinAddressRouting
}

final class PinAddressBuilder: Builder<PinAddressDependency>, PinAddressBuildable {
    /// Class's constructor.
    override init(dependency: PinAddressDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: PinAddressBuildable's members
    func build(withListener listener: PinAddressListener,
               defautPlace: AddressProtocol?, isOrigin: Bool) -> PinAddressRouting {
        let vc = PinAddressVC()
        let component = PinAddressComponent(dependency: dependency, PinAddressVC: vc)

        let interactor = PinAddressInteractor(presenter: component.PinAddressVC,
                                              authStream: dependency.authenticatedStream,
                                              defaultPlace: defautPlace,
                                              isOrigin: isOrigin)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return PinAddressRouter(interactor: interactor,
                                viewController: component.PinAddressVC,
                                defautPlace: defautPlace)
    }
}

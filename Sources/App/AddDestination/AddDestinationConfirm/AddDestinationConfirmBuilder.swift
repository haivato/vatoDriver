//  File name   : AddDestinationConfirmBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

enum AddDestinationType {
    case new(destination: AddressProtocol)
    case edit(destination: AddressProtocol)
    
    var address: AddressProtocol {
        switch self {
        case .new(let destination):
            return destination
        case .edit(let destination):
            return destination
        }
    }
}

// MARK: Dependency tree
protocol AddDestinationConfirmDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class AddDestinationConfirmComponent: Component<AddDestinationConfirmDependency> {
    /// Class's public properties.
    let AddDestinationConfirmVC: AddDestinationConfirmVC
    
    /// Class's constructor.
    init(dependency: AddDestinationConfirmDependency, AddDestinationConfirmVC: AddDestinationConfirmVC) {
        self.AddDestinationConfirmVC = AddDestinationConfirmVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol AddDestinationConfirmBuildable: Buildable {
    func build(withListener listener: AddDestinationConfirmListener, type: AddDestinationType, tripId: String) -> AddDestinationConfirmRouting
}

final class AddDestinationConfirmBuilder: Builder<AddDestinationConfirmDependency>, AddDestinationConfirmBuildable {
    /// Class's constructor.
    override init(dependency: AddDestinationConfirmDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: AddDestinationConfirmBuildable's members
    func build(withListener listener: AddDestinationConfirmListener,
               type: AddDestinationType,
               tripId: String) -> AddDestinationConfirmRouting
    {
        let vc = AddDestinationConfirmVC()
        let component = AddDestinationConfirmComponent(dependency: dependency, AddDestinationConfirmVC: vc)

        let interactor = AddDestinationConfirmInteractor(presenter: component.AddDestinationConfirmVC, type: type , tripId: tripId)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return AddDestinationConfirmRouter(interactor: interactor, viewController: component.AddDestinationConfirmVC)
    }
}

//  File name   : LocationPickerBuilder.swift
//
//  Author      : khoi tran
//  Created date: 11/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

enum LocationPickerDisplayType {
    case updatePlaceMode
    case full
}

enum SearchType {
    case express(origin: Bool)
    case booking(origin: Bool, placeHolder: String?, icon:UIImage?)
    case none
    
    func string() -> String {
        return "Thêm điểm đến"
    }
    
    func isOrigin() -> Bool {
        switch self {
        case .express(let origin):
            return origin
        case .booking(let origin, _, _):
            return origin
        default:
            return true
        }
    }
}

// MARK: Dependency tree
protocol LocationPickerDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }

}

final class LocationPickerComponent: Component<LocationPickerDependency> {
    /// Class's public properties.
    let LocationPickerVC: LocationPickerVC
    
    /// Class's constructor.
    init(dependency: LocationPickerDependency, LocationPickerVC: LocationPickerVC) {
        self.LocationPickerVC = LocationPickerVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol LocationPickerBuildable: Buildable {
    func build(withListener listener: LocationPickerListener,
               placeModel: AddressProtocol?,
               searchType: SearchType,
               typeLocationPicker: LocationPickerDisplayType) -> LocationPickerRouting
}

final class LocationPickerBuilder: Builder<LocationPickerDependency>, LocationPickerBuildable {
    /// Class's constructor.
    override init(dependency: LocationPickerDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: LocationPickerBuildable's members
    func build(withListener listener: LocationPickerListener,
               placeModel: AddressProtocol?,
               searchType: SearchType,
               typeLocationPicker: LocationPickerDisplayType) -> LocationPickerRouting {
        let vc = LocationPickerVC(nibName: LocationPickerVC.identifier, bundle: nil)
        let component = LocationPickerComponent(dependency: dependency, LocationPickerVC: vc)
        let interactor = LocationPickerInteractor(presenter: component.LocationPickerVC,
                                                     authStream: component.dependency.authenticatedStream,
                                                     placeModel: placeModel,
                                                     searchType: searchType,
                                                     typeLocationPicker: typeLocationPicker)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let pinAddressBuilder = PinAddressBuilder(dependency: component)

        return LocationPickerRouter(interactor: interactor, viewController: component.LocationPickerVC, pinAddressBuildable: pinAddressBuilder)
    }
}

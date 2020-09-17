//  File name   : SetLocationComponent+LocationPicker.swift
//
//  Author      : khoi tran
//  Created date: 3/6/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of SetLocation to provide for the LocationPicker scope.
// todo: Update SetLocationDependency protocol to inherit this protocol.
protocol SetLocationDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of SetLocation to provide dependencies
    // for the LocationPicker scope.
}

extension SetLocationComponent: LocationPickerDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    

    // todo: Implement properties to provide for LocationPicker scope.
}

//
//  LocationPicker+PinAddress.swift
//  Vato
//
//  Created by khoi tran on 11/13/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
extension LocationPickerComponent: PinAddressDependency {
    // todo: Implement properties to provide for SearchDelivery scope.
    
    var authenticatedStream: AuthenticatedStream {
        return self.dependency.authenticatedStream
    }
}

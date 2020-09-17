
//  File name   : ProcessingRequestComponent+StatusRequest.swift
//
//  Author      : MacbookPro
//  Created date: 4/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ProcessingRequest to provide for the StatusRequest scope.
// todo: Update ProcessingRequestDependency protocol to inherit this protocol.
protocol ProcessingRequestDependencyStatusRequest: Dependency {
    // todo: Declare dependencies needed from the parent scope of ProcessingRequest to provide dependencies
    // for the StatusRequest scope.
}

extension ProcessingRequestComponent: StatusRequestDependency {

    // todo: Implement properties to provide for StatusRequest scope.
}

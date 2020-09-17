//  File name   : ProcessingRequestComponent+ProcessingRequest.swift
//
//  Author      : MacbookPro
//  Created date: 4/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ProcessingRequest to provide for the ProcessingRequest scope.
// todo: Update ProcessingRequestDependency protocol to inherit this protocol.
protocol ProcessingRequestDependencyProcessingRequest: Dependency {
    // todo: Declare dependencies needed from the parent scope of ProcessingRequest to provide dependencies
    // for the ProcessingRequest scope.
}

extension ProcessingRequestComponent: ProcessingRequestDependency {

    // todo: Implement properties to provide for ProcessingRequest scope.
}

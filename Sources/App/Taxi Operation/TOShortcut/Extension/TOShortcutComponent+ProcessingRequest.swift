//  File name   : TOShortcutComponent+ProcessingRequest.swift
//
//  Author      : MacbookPro
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the ProcessingRequest scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyProcessingRequest: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the ProcessingRequest scope.
}

extension TOShortcutComponent: ProcessingRequestDependency {

    // todo: Implement properties to provide for ProcessingRequest scope.
}

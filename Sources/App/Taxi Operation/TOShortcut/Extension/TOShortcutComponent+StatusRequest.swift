//  File name   : TOShortcutComponent+StatusRequest.swift
//
//  Author      : MacbookPro
//  Created date: 4/6/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the StatusRequest scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyStatusRequest: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the StatusRequest scope.
}

extension TOShortcutComponent: StatusRequestDependency {

    // todo: Implement properties to provide for StatusRequest scope.
}

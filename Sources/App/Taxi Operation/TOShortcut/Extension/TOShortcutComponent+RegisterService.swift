//  File name   : TOShortcutComponent+RegisterService.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the RegisterService scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyRegisterService: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the RegisterService scope.
}

extension TOShortcutComponent: RegisterServiceDependency {

    // todo: Implement properties to provide for RegisterService scope.
}

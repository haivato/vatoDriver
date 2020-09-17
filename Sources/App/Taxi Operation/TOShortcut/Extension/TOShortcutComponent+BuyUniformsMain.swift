//  File name   : TOShortcutComponent+BUMain.swift
//
//  Author      : vato.
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the BUMain scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyBUMain: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the BUMain scope.
}

extension TOShortcutComponent: BUMainDependency {

    // todo: Implement properties to provide for BUMain scope.
}

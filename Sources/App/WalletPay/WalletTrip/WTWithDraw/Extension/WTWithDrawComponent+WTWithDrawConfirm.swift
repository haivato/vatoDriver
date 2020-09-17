//  File name   : WTWithDrawComponent+WTWithDrawConfirm.swift
//
//  Author      : admin
//  Created date: 6/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WTWithDraw to provide for the WTWithDrawConfirm scope.
// todo: Update WTWithDrawDependency protocol to inherit this protocol.
protocol WTWithDrawDependencyWTWithDrawConfirm: Dependency {
    // todo: Declare dependencies needed from the parent scope of WTWithDraw to provide dependencies
    // for the WTWithDrawConfirm scope.
}

extension WTWithDrawComponent: WTWithDrawConfirmDependency {

    // todo: Implement properties to provide for WTWithDrawConfirm scope.
}

//  File name   : WTWithDrawConfirmComponent+WTWithDrawSuccess.swift
//
//  Author      : admin
//  Created date: 5/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WTWithDrawConfirm to provide for the WTWithDrawSuccess scope.
// todo: Update WTWithDrawConfirmDependency protocol to inherit this protocol.
protocol WTWithDrawConfirmDependencyWTWithDrawSuccess: Dependency {
    // todo: Declare dependencies needed from the parent scope of WTWithDrawConfirm to provide dependencies
    // for the WTWithDrawSuccess scope.
}

extension WTWithDrawConfirmComponent: WTWithDrawSuccessDependency {

    // todo: Implement properties to provide for WTWithDrawSuccess scope.
}

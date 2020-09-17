//  File name   : WalletTripComponent+WTWithDraw.swift
//
//  Author      : admin
//  Created date: 6/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletTrip to provide for the WTWithDraw scope.
// todo: Update WalletTripDependency protocol to inherit this protocol.
protocol WalletTripDependencyWTWithDraw: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletTrip to provide dependencies
    // for the WTWithDraw scope.
}

extension WalletTripComponent: WTWithDrawDependency {

    // todo: Implement properties to provide for WTWithDraw scope.
}

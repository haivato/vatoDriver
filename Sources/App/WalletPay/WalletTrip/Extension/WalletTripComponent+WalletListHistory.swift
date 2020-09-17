//  File name   : WalletTripComponent+WalletListHistory.swift
//
//  Author      : MacbookPro
//  Created date: 5/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletTrip to provide for the WalletListHistory scope.
// todo: Update WalletTripDependency protocol to inherit this protocol.
protocol WalletTripDependencyWalletListHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletTrip to provide dependencies
    // for the WalletListHistory scope.
}

extension WalletTripComponent: WalletListHistoryDependency {
    var authenticated: AuthenticatedStream {
        return self.dependency.authenticated
    }
    

    // todo: Implement properties to provide for WalletListHistory scope.
}

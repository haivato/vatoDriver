//  File name   : TOShortcutComponent+WalletReceiveBooking.swift
//
//  Author      : admin
//  Created date: 5/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the WalletReceiveBooking scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyWalletReceiveBooking: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the WalletReceiveBooking scope.
}

extension TOShortcutComponent: WalletPointDependency {
    var authenticated: AuthenticatedStream {
        return self.dependency.authenticated
    }
    

    // todo: Implement properties to provide for WalletReceiveBooking scope.
//    var authenticated: AuthenticatedStream? {
//        return self.dependency.authenticated
//    }
}

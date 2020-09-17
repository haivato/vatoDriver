//  File name   : WalletListHistoryComponent+WalletDetailHistory.swift
//
//  Author      : Dung Vu
//  Created date: 12/7/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletListHistory to provide for the WalletDetailHistory scope.
// todo: Update WalletListHistoryDependency protocol to inherit this protocol.
protocol WalletListHistoryDependencyWalletDetailHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletListHistory to provide dependencies
    // for the WalletDetailHistory scope.
}

extension WalletListHistoryComponent: WalletDetailHistoryDependency {
    var authenticated: AuthenticatedStream {
        return self.dependency.authenticated
    }
    // todo: Implement properties to provide for WalletDetailHistory scope.
}

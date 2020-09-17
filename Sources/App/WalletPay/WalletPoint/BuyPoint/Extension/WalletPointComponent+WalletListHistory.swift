//  File name   : WalletPointComponent+WalletListHistory.swift
//
//  Author      : MacbookPro
//  Created date: 5/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletReceiveBooking to provide for the WalletListHistory scope.
// todo: Update WalletPointDependency protocol to inherit this protocol.
protocol WalletPointDependencyWalletListHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletReceiveBooking to provide dependencies
    // for the WalletListHistory scope.
}

extension WalletPointComponent: WalletListHistoryDependency {

    // todo: Implement properties to provide for WalletListHistory scope.
}

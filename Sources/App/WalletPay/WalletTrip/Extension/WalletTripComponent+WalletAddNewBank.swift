//  File name   : WalletTripComponent+WalletAddNewBank.swift
//
//  Author      : MacbookPro
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletTrip to provide for the WalletAddNewBank scope.
// todo: Update WalletTripDependency protocol to inherit this protocol.
protocol WalletTripDependencyWalletAddNewBank: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletTrip to provide dependencies
    // for the WalletAddNewBank scope.
}

extension WalletTripComponent: WalletAddNewBankDependency {

    // todo: Implement properties to provide for WalletAddNewBank scope.
}

//  File name   : WalletAddNewBankComponent+ListBank.swift
//
//  Author      : MacbookPro
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletAddNewBank to provide for the ListBank scope.
// todo: Update WalletAddNewBankDependency protocol to inherit this protocol.
protocol WalletAddNewBankDependencyListBank: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletAddNewBank to provide dependencies
    // for the ListBank scope.
}

extension WalletAddNewBankComponent: ListBankDependency {

    // todo: Implement properties to provide for ListBank scope.
}

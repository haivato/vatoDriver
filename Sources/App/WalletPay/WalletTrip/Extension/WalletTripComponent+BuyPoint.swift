//  File name   : WalletTripComponent+BuyPoint.swift
//
//  Author      : MacbookPro
//  Created date: 5/25/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletTrip to provide for the BuyPoint scope.
// todo: Update WalletTripDependency protocol to inherit this protocol.
protocol WalletTripDependencyBuyPoint: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletTrip to provide dependencies
    // for the BuyPoint scope.
}

extension WalletTripComponent: BuyPointDependency {

    // todo: Implement properties to provide for BuyPoint scope.
}

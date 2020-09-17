//  File name   : BuyPointComponent+WTWithDrawConfirm.swift
//
//  Author      : MacbookPro
//  Created date: 5/25/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BuyPoint to provide for the WTWithDrawConfirm scope.
// todo: Update BuyPointDependency protocol to inherit this protocol.
protocol BuyPointDependencyWTWithDrawConfirm: Dependency {
    // todo: Declare dependencies needed from the parent scope of BuyPoint to provide dependencies
    // for the WTWithDrawConfirm scope.
}

extension BuyPointComponent: WTWithDrawConfirmDependency {

    // todo: Implement properties to provide for WTWithDrawConfirm scope.
}

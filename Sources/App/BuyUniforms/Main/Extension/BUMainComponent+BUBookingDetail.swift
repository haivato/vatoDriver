//  File name   : BUMainComponent+BUBookingDetail.swift
//
//  Author      : vato.
//  Created date: 3/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BUMain to provide for the BUBookingDetail scope.
// todo: Update BUMainDependency protocol to inherit this protocol.
protocol BUMainDependencyBUBookingDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of BUMain to provide dependencies
    // for the BUBookingDetail scope.
}

extension BUMainComponent: BUBookingDetailDependency {

    // todo: Implement properties to provide for BUBookingDetail scope.
}

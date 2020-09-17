//  File name   : BUBookingDetailComponent+SwitchPayment.swift
//
//  Author      : Dung Vu
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BUBookingDetail to provide for the SwitchPayment scope.
// todo: Update BUBookingDetailDependency protocol to inherit this protocol.
protocol BUBookingDetailDependencySwitchPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of BUBookingDetail to provide dependencies
    // for the SwitchPayment scope.
}

extension BUBookingDetailComponent: SwitchPaymentDependency {

    // todo: Implement properties to provide for SwitchPayment scope.
}

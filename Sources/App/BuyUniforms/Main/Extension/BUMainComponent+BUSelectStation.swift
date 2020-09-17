//  File name   : BUMainComponent+BUSelectStation.swift
//
//  Author      : vato.
//  Created date: 3/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BUMain to provide for the BUSelectStation scope.
// todo: Update BUMainDependency protocol to inherit this protocol.
protocol BUMainDependencyBUSelectStation: Dependency {
    // todo: Declare dependencies needed from the parent scope of BUMain to provide dependencies
    // for the BUSelectStation scope.
}

extension BUMainComponent: BUSelectStationDependency {

    // todo: Implement properties to provide for BUSelectStation scope.
}

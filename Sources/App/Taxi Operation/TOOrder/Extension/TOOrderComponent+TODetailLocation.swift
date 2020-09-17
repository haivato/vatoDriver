//  File name   : TOOrderComponent+TODetailLocation.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOOrder to provide for the TODetailLocation scope.
// todo: Update TOOrderDependency protocol to inherit this protocol.
protocol TOOrderDependencyTODetailLocation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOOrder to provide dependencies
    // for the TODetailLocation scope.
}

extension TOOrderComponent: TODetailLocationDependency {

    // todo: Implement properties to provide for TODetailLocation scope.
}

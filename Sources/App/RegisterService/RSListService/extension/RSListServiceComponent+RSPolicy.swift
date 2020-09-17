//  File name   : RSListServiceComponent+RSPolicy.swift
//
//  Author      : MacbookPro
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of RSListService to provide for the RSPolicy scope.
// todo: Update RSListServiceDependency protocol to inherit this protocol.
protocol RSListServiceDependencyRSPolicy: Dependency {
    // todo: Declare dependencies needed from the parent scope of RSListService to provide dependencies
    // for the RSPolicy scope.
}

extension RSListServiceComponent: RSPolicyDependency {

    // todo: Implement properties to provide for RSPolicy scope.
}

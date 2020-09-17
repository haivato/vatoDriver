//  File name   : RSListServiceComponent+RegisterService.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of RSListService to provide for the RegisterService scope.
// todo: Update RSListServiceDependency protocol to inherit this protocol.
protocol RSListServiceDependencyRegisterService: Dependency {
    // todo: Declare dependencies needed from the parent scope of RSListService to provide dependencies
    // for the RegisterService scope.
}

extension RSListServiceComponent: RegisterServiceDependency {

    // todo: Implement properties to provide for RegisterService scope.
}

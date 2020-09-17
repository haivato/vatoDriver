//  File name   : RequestQuickSupportComponent+QuickSupportList.swift
//
//  Author      : vato.
//  Created date: 2/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of RequestQuickSupport to provide for the QuickSupportList scope.
// todo: Update RequestQuickSupportDependency protocol to inherit this protocol.
protocol RequestQuickSupportDependencyQuickSupportList: Dependency {
    // todo: Declare dependencies needed from the parent scope of RequestQuickSupport to provide dependencies
    // for the QuickSupportList scope.
}

extension RequestQuickSupportComponent: QuickSupportListDependency {

    // todo: Implement properties to provide for QuickSupportList scope.
}

//  File name   : QuickSupportMainComponent+QuickSupportList.swift
//
//  Author      : khoi tran
//  Created date: 1/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of QuickSupportMain to provide for the QuickSupportList scope.
// todo: Update QuickSupportMainDependency protocol to inherit this protocol.
protocol QuickSupportMainDependencyQuickSupportList: Dependency {
    // todo: Declare dependencies needed from the parent scope of QuickSupportMain to provide dependencies
    // for the QuickSupportList scope.
}

extension QuickSupportMainComponent: QuickSupportListDependency {

    // todo: Implement properties to provide for QuickSupportList scope.
}

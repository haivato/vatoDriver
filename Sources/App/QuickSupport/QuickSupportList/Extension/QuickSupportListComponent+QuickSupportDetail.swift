//  File name   : QuickSupportListComponent+QuickSupportDetail.swift
//
//  Author      : khoi tran
//  Created date: 1/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of QuickSupportList to provide for the QuickSupportDetail scope.
// todo: Update QuickSupportListDependency protocol to inherit this protocol.
protocol QuickSupportListDependencyQuickSupportDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of QuickSupportList to provide dependencies
    // for the QuickSupportDetail scope.
}

extension QuickSupportListComponent: QuickSupportDetailDependency {

    // todo: Implement properties to provide for QuickSupportDetail scope.
}

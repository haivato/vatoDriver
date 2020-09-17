//  File name   : QuickSupportMainComponent+RequestQuickSupport.swift
//
//  Author      : vato.
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of QuickSupportMain to provide for the RequestQuickSupport scope.
// todo: Update QuickSupportMainDependency protocol to inherit this protocol.
protocol QuickSupportMainDependencyRequestQuickSupport: Dependency {
    // todo: Declare dependencies needed from the parent scope of QuickSupportMain to provide dependencies
    // for the RequestQuickSupport scope.
}

extension QuickSupportMainComponent: RequestQuickSupportDependency {

    // todo: Implement properties to provide for RequestQuickSupport scope.
}

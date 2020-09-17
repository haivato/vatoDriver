//  File name   : ContractDetailComponent+ReceiptCarContract.swift
//
//  Author      : Phan Hai
//  Created date: 31/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ContractDetail to provide for the ReceiptCarContract scope.
// todo: Update ContractDetailDependency protocol to inherit this protocol.
protocol ContractDetailDependencyReceiptCarContract: Dependency {
    // todo: Declare dependencies needed from the parent scope of ContractDetail to provide dependencies
    // for the ReceiptCarContract scope.
}

extension ContractDetailComponent: ReceiptCarContractDependency {

    // todo: Implement properties to provide for ReceiptCarContract scope.
}

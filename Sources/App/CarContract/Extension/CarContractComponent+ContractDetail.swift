//  File name   : CarContractComponent+ContractDetail.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CarContract to provide for the ContractDetail scope.
// todo: Update CarContractDependency protocol to inherit this protocol.
protocol CarContractDependencyContractDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of CarContract to provide dependencies
    // for the ContractDetail scope.
}

extension CarContractComponent: ContractDetailDependency {

    // todo: Implement properties to provide for ContractDetail scope.
}

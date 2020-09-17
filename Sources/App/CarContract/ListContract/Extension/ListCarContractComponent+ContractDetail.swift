//  File name   : ListCarContractComponent+ContractDetail.swift
//
//  Author      : Phan Hai
//  Created date: 10/09/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ListCarContract to provide for the ContractDetail scope.
// todo: Update ListCarContractDependency protocol to inherit this protocol.
protocol ListCarContractDependencyContractDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of ListCarContract to provide dependencies
    // for the ContractDetail scope.
}

extension ListCarContractComponent: ContractDetailDependency {

    // todo: Implement properties to provide for ContractDetail scope.
}

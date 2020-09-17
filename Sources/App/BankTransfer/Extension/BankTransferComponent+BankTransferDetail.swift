//  File name   : BankTransferComponent+BankTransferDetail.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BankTransfer to provide for the BankTransferDetail scope.
// todo: Update BankTransferDependency protocol to inherit this protocol.
protocol BankTransferDependencyBankTransferDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of BankTransfer to provide dependencies
    // for the BankTransferDetail scope.
}

extension BankTransferComponent: BankTransferDetailDependency {

    // todo: Implement properties to provide for BankTransferDetail scope.
}

//  File name   : ContractDetailComponent+Chat.swift
//
//  Author      : Phan Hai
//  Created date: 30/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ContractDetail to provide for the Chat scope.
// todo: Update ContractDetailDependency protocol to inherit this protocol.
protocol ContractDetailDependencyChat: Dependency {
    // todo: Declare dependencies needed from the parent scope of ContractDetail to provide dependencies
    // for the Chat scope.
}

extension ContractDetailComponent: ChatDependency {
    var chatStream: ChatStreamImpl {
        return mutableChatStream
    }
    

    // todo: Implement properties to provide for Chat scope.
}

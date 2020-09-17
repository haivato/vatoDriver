//  File name   : WalletPointComponent+LinkingCard.swift
//
//  Author      : admin
//  Created date: 5/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletReceiveBooking to provide for the LinkingCard scope.
// todo: Update WalletPointDependency protocol to inherit this protocol.
protocol WalletPointDependencyLinkingCard: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletReceiveBooking to provide dependencies
    // for the LinkingCard scope.
}

extension WalletPointComponent: LinkingCardDependency {
    // todo: Implement properties to provide for LinkingCard scope.
    var authenticated: AuthenticatedStream {
        return self.dependency.authenticated
    }
}

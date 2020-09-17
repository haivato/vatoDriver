//  File name   : WalletPointComponent+BuyPoint.swift
//
//  Author      : admin
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of WalletReceiveBooking to provide for the BuyPoint scope.
// todo: Update WalletPointDependency protocol to inherit this protocol.
protocol WalletPointDependencyBuyPoint: Dependency {
    // todo: Declare dependencies needed from the parent scope of WalletReceiveBooking to provide dependencies
    // for the BuyPoint scope.
}

extension WalletPointComponent: BuyPointDependency {

    // todo: Implement properties to provide for BuyPoint scope.    
//    var mutablePaymentStream: MutablePaymentStream {
//        return self.mutablePaymentStream
//    }
}



//extension WalletPointComponent: LinkingCardDependency {
//    // todo: Implement properties to provide for LinkingCard scope.
//    var authenticated: AuthenticatedStream {
//        return self.dependency.authenticated
//    }
//}

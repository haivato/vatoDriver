//  File name   : Protocol.swift
//
//  Author      : Dung Vu
//  Created date: 12/13/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

// MARK: Immutable stream
protocol AuthenticatedStream: class {
    var googleAPI: Observable<String> { get }
    var firebaseAuthToken: Observable<String> { get }
}

protocol WalletItemDisplayProtocol {
    var increase: Bool { get }
    var title: String? { get }
    var description: String? { get }
    var amount: Double { get }
    var id: Int { get }
    var transactionDate: Double { get }
}

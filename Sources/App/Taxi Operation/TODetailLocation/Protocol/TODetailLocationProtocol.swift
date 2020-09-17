//  File name   : TODetailLocationProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

protocol TODetailLocationProtocol: PickupLocationProtocol {
    var name: String? { get }
    var info: [String]? { get }
    var approveModel: TaxiOperationDisplay? { get set }
    var canRequestTaxiQueue: Bool { get }
}

extension TODetailLocationProtocol {}



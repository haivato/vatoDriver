//  File name   : RequireProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 9/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
typealias BlockModifyByValue<Value, T> = (Value) -> T

// MARK: -- Network
protocol ModifyHostProtocol {
    static var host: String { get }
    static var path: BlockModifyByValue<String, String> { get }
}

extension ModifyHostProtocol {
    static var path: BlockModifyByValue<String, String> {
        return { host + $0 }
    }
}

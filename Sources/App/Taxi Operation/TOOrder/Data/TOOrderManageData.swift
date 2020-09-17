//  File name   : TOOrderManageData.swift
//
//  Author      : Dung Vu
//  Created date: 2/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

typealias TOOrderData = [TOOrderSectionType: [TOOrderProtocol]]
final class TOOrderManageData {
    /// Class's public properties.
    /// Class's constructors.
    /// Class's private properties.
    @VariableReplay(wrappedValue: [:]) var mSource : TOOrderData
}

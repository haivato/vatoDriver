//  File name   : BankRow.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

final class BankRow: Row<BankCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
    }
}

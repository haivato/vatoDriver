//  File name   : WithdrawRow.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

final class WithdrawRow: MasterFieldRow<WithdrawCell>, RowType {

    var cash: Int64 = 0
        
    required init(tag: String?) {
        super.init(tag: tag)
        
        let locale = Locale(identifier: "en_US")
        let currencyFormat = NumberFormatter()
        
        //             Layout currency
        currencyFormat.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        currencyFormat.roundingMode = NumberFormatter.RoundingMode.halfUp
        currencyFormat.numberStyle = NumberFormatter.Style.currency
        currencyFormat.generatesDecimalNumbers = true
        currencyFormat.locale = locale
        
        currencyFormat.positiveFormat = "#,##0.00\u{00a4}"
        currencyFormat.negativeFormat = "- #,##0.00\u{00a4}"
        currencyFormat.currencyCode = "VND"
        formatter = currencyFormat
        useFormatterDuringInput = false
        onRowValidationChanged(validationChangedClosure)
    }
    
    func formatPointCell() {
        let currencyFormat = NumberFormatter()
        currencyFormat.groupingSeparator = ","
        currencyFormat.numberStyle = .decimal
        currencyFormat.allowsFloats = false
        formatter = currencyFormat
    }
        
    func update(by items: [Double]?, isPrice: Bool = true) {
        cell.update(by: items, isPrice: isPrice)
    }
}


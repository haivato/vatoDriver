//  File name   : MasterFieldRow.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 9/14/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

public protocol MasterFieldRowProtocol {
    var textFont: UIFont { get }
    var textColor: UIColor { get }
    var placeholderFont: UIFont { get }
}

open class MasterFieldRow<Cell>: FieldRow<Cell>, MasterFieldRowProtocol where Cell : BaseCell, Cell: CellType, Cell: TextFieldCell {
    /// Class's public properties.
    open var textFont: UIFont
    open var textColor: UIColor
    open var placeholderFont: UIFont
    
    /// Class's constructors
    public required init(tag: String?) {
        textColor = EurekaConfig.detailColor
        textFont = EurekaConfig.detailFont
        placeholderFont = EurekaConfig.detailFont
        
        super.init(tag: tag)
        placeholderColor = EurekaConfig.placeholderColor
        validationOptions = .validatesOnBlur
    }
    
    /// Class's private properties
    internal let validationChangedClosure: (Cell, BaseRow) -> Void = { (cell, row) -> Void in
        // Display error message if row is invalid, only display the first one
        if let masterCell = cell as? MasterFieldCellProtocol {
            if !row.isValid, let validationMessage = row.validationErrors.first?.msg {
                masterCell.titleLabel.textColor = .red
                masterCell.titleLabel.text = validationMessage
            }
        }
    }
}

public final class MasterAccountFieldRow: MasterFieldRow<MasterAccountFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterEmailFieldRow: MasterFieldRow<MasterEmailFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterNameFieldRow: MasterFieldRow<MasterNameFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterPasswordFieldRow: MasterFieldRow<MasterPasswordFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterPhoneFieldRow: MasterFieldRow<MasterPhoneFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterTextFieldRow: MasterFieldRow<MasterTextFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterURLFieldRow: MasterFieldRow<MasterURLFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterZipCodeFieldRow: MasterFieldRow<MasterZipCodeFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        onRowValidationChanged(validationChangedClosure)
    }
}

public final class MasterIntFieldRow: MasterFieldRow<MasterIntFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        
        formatter = numberFormatter
        useFormatterDuringInput = true
        onRowValidationChanged(validationChangedClosure)
    }
}
public final class MasterDecimalFieldRow: MasterFieldRow<MasterDecimalFieldCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        
        formatter = numberFormatter
        useFormatterDuringInput = true
        onRowValidationChanged(validationChangedClosure)
    }
}

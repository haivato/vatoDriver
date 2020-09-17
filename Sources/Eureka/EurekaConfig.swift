//  File name   : EurekaConfig.swift
//
//  Author      : Vato
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCore

struct EurekaConfig {
    static let defaultHeight = { return CGFloat(70.0) }
    static let paddingLeft: CGFloat = 15.0
    
    static let primaryColor = #colorLiteral(red: 0, green: 0.4235294118, blue: 0.231372549, alpha: 1)
    static let originNewColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
    
    static let detailColor = #colorLiteral(red: 0.0431372549, green: 0.0431372549, blue: 0.0431372549, alpha: 1)
    static let placeholderColor = #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7843137255, alpha: 1)
    static let separatorColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
    static let titleColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
    
    static let disabledTitleColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
    static let disabledDetailColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
    
    static let detailFont = UIFont.systemFont(ofSize: 17.0)
    static let titleFont = UIFont.systemFont(ofSize: 14.0)
}

extension ValidationError {
    static let empty = ValidationError(msg: "")
}

struct RulesWidthdraw {
    typealias Value = Int
    
    
    /// Rules
    ///
    /// - Parameters:
    ///   - minValue: min can check
    ///   - maxValue: max (cash can check)
    ///   - maxOption: max from server
    /// - Returns: Error
    static func rules(minValue: Value, maxValue: Value, maxOption: Value) -> RuleSet<Value> {
        /*
         1. Tài khoản "Số dư khả dụng" - Số tiền có thể rút: Sẽ bao gồm 50,000đ phong toả. Ví dụ: Số dư có thể rút là 2,000,000đ thì chỉ có thể rút 1,950,000đđ.
         
         - Nếu Driver yêu cầu rủt 2,000,000đ thì sẽ thông báo text như sau:
         "Số dư tối thiểu cần giữ lại trong tài khoản là 50,000đ"
         
         2. Thêm text lưu ý trong form Add tài khoản:
         "Lưu ý:
         - Tài khoản ngân hàng chỉ được thêm một lần duy nhất.
         - Nếu có thay đổi thông tin, vui lòng gọi tổng đài 1900 6667 để được hướng dẫn."
         */
        
        var newRules = RuleSet<Value>()
        let required = RuleRequired<Value>(msg: "Số tiền cần rút không được để trống.", id: "Required")
        
//        var finalMax = maxValue - 50000
//        finalMax = max(finalMax, 0)
        let ruleAmount = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let v = v else {
                return nil
            }
            
//            if v > finalMax {
//                return ValidationError(msg: "Số dư tối thiểu trong tài khoản là \(50000.currency).")
//            }
            
            if v < minValue {
                return ValidationError(msg: "Số tiền rút tối thiểu là \(minValue.currency).")
            }
            
            if v > maxOption {
                return ValidationError(msg: "Số tiền tối đa có thể rút là \(maxOption.currency).")
            }
            
            if v > maxValue {
                return ValidationError(msg: "Số tiền tối đa có thể rút là \(maxValue.currency).")
            }

            
            let div: UInt64 = 10000
            guard (UInt64(v) % div) != 0 else {
                return nil
            }
            
            return ValidationError(msg: "Số tiền rút phải là bội số của \(div.currency)")
        }
        
        newRules.add(rule: required)
        newRules.add(rule: ruleAmount)
        
        return newRules
    }
}

struct RulesTopUp {
    typealias Value = Int
    
    static func rules(minValue: Value, maxValue: Value) -> RuleSet<Value> {
        var newRules = RuleSet<Value>()
        let required = RuleRequired<Value>(msg: "Số tiền cần nạp không được để trống.", id: "Required")
        let smallerThan = RuleSmallerOrEqualThan<Value>(max: maxValue, msg: "Số tiền nạp phải nhỏ hơn \(maxValue.currency)", id: "check_max")
        let greaterThan = RuleGreaterOrEqualThan<Value>(min: minValue, msg: "Giới hạn số tiền tối thiểu là \(minValue.currency).", id: "check_min")
        let ruleDiv = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let v = v, v > 0 else {
                return nil
            }
            
            let div: UInt64 = 10000
            guard (UInt64(v) % div) != 0 else {
                return nil
            }
            
            return ValidationError(msg: "Số tiền nạp phải là bội số của \(div.currency)")
        }
        newRules.add(rule: required)
        newRules.add(rule: greaterThan)
        newRules.add(rule: smallerThan)
        newRules.add(rule: ruleDiv)
        return newRules
    }
    
    static func checkMaxRule(maxValue: Value) -> RuleSmallerOrEqualThan<Value> {
        return RuleSmallerOrEqualThan<Value>(max: maxValue, msg: "\(FwiLocale.localized("Số tiền nạp phải nhỏ hơn")) \(maxValue.currency).", id: "check_max")
    }
     
    static func checkMinRule(minValue: Value) -> RuleGreaterOrEqualThan<Value> {
        return RuleGreaterOrEqualThan<Value>(min: minValue, msg: "\(FwiLocale.localized("Giới hạn số tiền tối thiểu là")) \(minValue.currency).", id: "check_min")
    }
    
    static func rulesOfPoint(minValue: Value, maxValue: Value) -> RuleSet<Value> {
        var newRules = RuleSet<Value>()
        let required = RuleRequired<Value>(msg: "Số điểm cần nạp không được để trống.", id: "Required")
        let smallerThan = RuleSmallerOrEqualThan<Value>(max: maxValue, msg: "Số điểm nạp phải nhỏ hơn \(maxValue.point)", id: "check_max")
        let greaterThan = RuleGreaterOrEqualThan<Value>(min: minValue, msg: "Giới hạn số điểm tối thiểu là \(minValue.point).", id: "check_min")
        let ruleDiv = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let v = v, v > 0 else {
                return nil
            }
            
            let div: UInt64 = 10000
            guard (UInt64(v) % div) != 0 else {
                return nil
            }
            
            return ValidationError(msg: "Số điểm nạp phải là bội số của \(div)")
        }
        newRules.add(rule: required)
        newRules.add(rule: greaterThan)
        newRules.add(rule: smallerThan)
        newRules.add(rule: ruleDiv)
        return newRules
    }
    
    static func checkMaxRulePoint(maxValue: Value) -> RuleSmallerOrEqualThan<Value> {
        return RuleSmallerOrEqualThan<Value>(max: maxValue, msg: "\(FwiLocale.localized("Số điểm nạp phải nhỏ hơn")) \(maxValue.point).", id: "check_max")
    }
     
    static func checkMinRulePoint(minValue: Value) -> RuleGreaterOrEqualThan<Value> {
        return RuleGreaterOrEqualThan<Value>(min: minValue, msg: "\(FwiLocale.localized("Giới hạn số điểm tối thiểu là")) \(minValue.point).", id: "check_min")
    }
}

struct RulesTopUpMoney {
    typealias Value = Int
    
    static func rules(minValue: Value, maxValue: Value) -> RuleSet<Value> {
        var newRules = RuleSet<Value>()
        let required = RuleRequired<Value>(msg: "Số tiền cần nạp không được để trống.", id: "Required")
        let greaterThan = RuleGreaterOrEqualThan<Value>(min: minValue, msg: "Giới hạn số tiền tối thiểu là \(minValue.currency).", id: "check_min")
        var finalMax = maxValue - 50000
        finalMax = max(finalMax, 0)
        let ruleAmount = RuleClosure<Value>.init { (v) -> ValidationError? in
            guard let v = v, v >= 0 else {
                return nil
            }
            
            if v > finalMax {
                return ValidationError(msg: "Số dư tối thiểu trong tài khoản là \(50000.currency).")
            }
            
            if v < minValue {
                return ValidationError(msg: "Giới hạn số tiền tối thiểu là \(minValue.currency).")
            }
            
//            if v > maxOption {
//                return ValidationError(msg: "Số tiền tối đa có thể rút là \(maxOption.currency).")
//            }
            
            let div: UInt64 = 10000
            guard (UInt64(v) % div) != 0 else {
                return nil
            }
            
            return ValidationError(msg: "Số tiền nạp phải là bội số của \(div.currency)")
        }
        
        newRules.add(rule: required)
        newRules.add(rule: greaterThan)
        newRules.add(rule: ruleAmount)
        return newRules
    }
}

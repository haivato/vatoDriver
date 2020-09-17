//  File name   : NewBankAccountRules.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Eureka

struct NewBankAccountRules {
    typealias Value = String
    static func rules() -> RuleSet<Value> {
        var newRules = RuleSet<Value>()
        let required = RuleRequired<Value>(msg: "Số chứng minh thư không được bỏ trống.", id: "Required")
        let check = RuleClosure<Value>.init { (s) -> ValidationError? in
            guard case let .some(v) = s, !v.isEmpty else {
                return nil
            }
            
            let lenght = v.count
            if lenght < 4 {
                return ValidationError(msg: "Thông tin nhập tối thiểu 4 ký tự")
            }
            
            if lenght > 20 {
                return ValidationError(msg: "Thông tin nhập tối đa 20 ký tự")
            }
            
            return nil
        }
        
        newRules.add(rule: required)
        newRules.add(rule: check)
        
        return newRules
    }
}

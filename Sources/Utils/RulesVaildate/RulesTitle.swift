//
//  RulesTitle.swift
//  FC
//
//  Created by vato. on 1/16/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka

struct RulesTitle {
    typealias Value = String
    
    static func rules(minimumCharacter: UInt) -> RuleSet<Value> {
        let ruleTitle = RuleClosure<Value>.init { (v) -> ValidationError? in
            
            let trimVal = v?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimVal.count < minimumCharacter {
                return ValidationError(msg: "Nhập title")
            }
            
            return nil
        }
        var newRules = RuleSet<Value>()
        newRules.add(rule: ruleTitle)
        
        return newRules
    }
}

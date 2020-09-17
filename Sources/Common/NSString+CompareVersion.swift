//  File name   : NSString+CompareVersion.swift
//
//  Author      : Dung Vu
//  Created date: 10/2/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

extension NSString {
    @objc static func different(currentVersion: String?, compareVersion: String?) -> Bool {
        guard let current = currentVersion, let compare = compareVersion, !current.isEmpty, !compare.isEmpty else {
            return true
        }
        
        let component1 = current.components(separatedBy: ".")
        let component2 = compare.components(separatedBy: ".")
        let lenght = min(component1.count, component2.count)
        for idx in (0..<lenght) {
            let v1 = component1[idx]
            let v2 = component2[idx]
            
            let n = abs(v1.count - v2.count)
            let value1 = Int(v1) ?? 0
            let value2 = Int(v2) ?? 0
            
            let condition = (n == 0, idx == 0)
            
            switch condition {
            case (_, true), (true, _):
                guard value1 != value2 else {
                    continue
                }
                return value1 < value2
            default:
                let mutiply = pow(10.0, Double(n))
                if value1 < value2 {
                    let next = value1 * Int(mutiply)
                    return next < value2
                } else {
                    let next = value2 * Int(mutiply)
                    return value1 < next
                }
                
            }
        }
        return false
    }
}

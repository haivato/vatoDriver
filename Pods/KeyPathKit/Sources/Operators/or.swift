//
//  or.swift
//  KeyPathKit
//
//  Created by Vincent on 07/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation

extension Sequence {
    public func or(_ attribute: KeyPath<Element, Bool>) -> Bool {
        for element in self{
            if element[keyPath: attribute] == true {
                return true
            }
        }
        return false
    }
}

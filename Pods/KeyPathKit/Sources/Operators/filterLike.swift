//
//  filterLike.swift
//  KeyPathKit
//
//  Created by Vincent on 11/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation

extension Sequence {
    public func filter(where attribute: KeyPath<Element, String>, like regex: String) -> [Element] {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return filter { predicate.evaluate(with: $0[keyPath: attribute]) }
    }
}

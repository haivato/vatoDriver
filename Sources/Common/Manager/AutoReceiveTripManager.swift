//
//  AutoReceiveTripManager.swift
//  FC
//
//  Created by vato. on 7/24/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import VatoNetwork

class AutoReceiveTripManager: NSObject {
    let keyStoreUserDefaults = "keyStoreUserDefaults"
    @objc static fileprivate(set) var shared = AutoReceiveTripManager()
    
    @objc var flagAutoReceiveTripManager: Bool {
        set { UserDefaults.standard.set(newValue, forKey: keyStoreUserDefaults) }
        get { return  UserDefaults.standard.bool(forKey: keyStoreUserDefaults) }
    }
}

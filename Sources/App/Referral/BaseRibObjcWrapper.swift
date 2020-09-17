//  File name   : BaseRibObjcWrapper.swift
//
//  Author      : Dung Vu
//  Created date: 1/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RIBs

class BaseRibObjcWrapper: NSObject {
    /// Class's constructors.
    private var currrentRoute: Routing?
    /// Class's private properties.
    
    func active(by route: Routing) {
        self.currrentRoute = route
        currrentRoute?.interactable.activate()
    }
    
    func deactive() {
        currrentRoute?.interactable.deactivate()
        currrentRoute = nil
    }
    
    func present() {}
    
    deinit {
        printDebug("\(#function)")
    }
}

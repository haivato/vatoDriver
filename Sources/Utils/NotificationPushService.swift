//  File name   : NotificationPushService.swift
//
//  Author      : Dung Vu
//  Created date: 2/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

@objc protocol HandlerPushProtocol: NSObjectProtocol {
    func updatePush(info: [String: Any]?)
}

@objcMembers
final class NotificationPushService: NSObject {
    static let instance = NotificationPushService()
    private weak var currentHandler: HandlerPushProtocol?
    private var dispose: Disposable?
    /// Class's constructors.
    @VariableReplay(wrappedValue: nil) private var infor: [String: Any]?
    var new: Observable<[String: Any]> {
        return $infor.filterNil()
    }
    
    private func setupRX() {
        dispose = new.bind { [weak self](new) in
            self?.currentHandler?.updatePush(info: new)
        }
    }
    
    /// Class's private properties...
    func update(push: [String: Any]?) {
        infor = push
    }
    
    func register(handler: HandlerPushProtocol) {
        dispose?.dispose()
        self.currentHandler = handler
        setupRX()
    }
}


//  File name   : BankTransferWrapper.swift
//
//  Author      : Futa Corp
//  Created date: 2/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RIBs
import FirebaseDatabase

@objcMembers
final class BankTransferWrapper: BaseRibObjcWrapper {
    /// Class's public properties.
    weak var controller: UIViewController?

    var firebaseDatabase: DatabaseReference {
        return Database.database().reference()
    }

    /// Class's constructors
    init(with controller: UIViewController?) {
        super.init()
        self.controller = controller
    }

    deinit {
        printDebug("\(#function)")
    }

    override func present() {
        guard let navigationVC = controller?.navigationController else {
            fatalError("\(BankTransferVC.self) must be presented within navigation controller.")
        }

        let builder = BankTransferBuilder(dependency: self)
        let route = builder.build(withListener: self)
        active(by: route)

        let bankTransferVC = route.viewControllable.uiviewController
        navigationVC.pushViewController(bankTransferVC, animated: true)
    }

    /// Class's private properties.
}

// MARK: BankTransferDependency's members
extension BankTransferWrapper: BankTransferDependency {
}

// MARK: BankTransferListener's members
extension BankTransferWrapper: BankTransferListener {
    func requestToDismissBankTransferModule() {
        controller?.navigationController?.popViewController(animated: true)
    }
}

//  File name   : FormHandlerProtocol.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

#if canImport(Eureka)
    import Eureka
    import UIKit
    import FwiCoreRX

    protocol FormHandlerProtocol: class {
        /// Cancel form.
        func cancelForm()

        /// Execute user's input.
        ///
        /// - Parameter input: form's input
        func execute(input: [String: Any?], completion: (() -> Void)?)
    }

    extension FormHandlerProtocol where Self: UIViewController {
        func execute(form: Form, prefixAction: (() -> Void)?, suffixAction: (() -> Void)?) {
            view.findAndResignFirstResponder()

            /* Condition validation: if user's input is valid or not */
            let info = form.values()
            guard form.validate().count <= 0 else {
                return
            }
            prefixAction?()
            execute(input: info, completion: suffixAction)
        }
    }
#endif

#if canImport(RIBs)
    import RIBs

    extension FormHandlerProtocol where Self: ViewControllable {
        func execute(form: Form, viewController: ViewControllable, prefixAction: (() -> Void)?, suffixAction: (() -> Void)?) {
            guard let view = viewController.uiviewController.view else {
                return
            }
            view.findAndResignFirstResponder()

            /* Condition validation: if user's input is valid or not */
            let info = form.values()
            guard form.validate().count <= 0 else {
                return
            }
            prefixAction?()
            execute(input: info, completion: suffixAction)
        }
    }
#endif

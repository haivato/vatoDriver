//  File name   : ControllableProtocol.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 10/1/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Aversafe. All rights reserved.
//  --------------------------------------------------------------

#if canImport(RIBs)
    import RIBs
    import UIKit

    // MARK: ControllableProtocol
    protocol ControllableProtocol: class {
        /// Dismiss a view controller.
        ///
        /// - Parameter viewController: a view controller
        func dismiss(viewController vc: ViewControllable, completion block: (() -> Void)?)

        /// Present a view controller.
        ///
        /// - Parameter viewController: a view controller
        func present(viewController vc: ViewControllable, transitionType transition: TransitonType, completion block: (() -> Void)?)

        /// Present a view controller within a navigation view controller hierarchy.
        ///
        /// - Parameter viewController: a view controller
        @discardableResult
        func presentNavigationController(for vc: ViewControllable, transitionType transition: TransitonType, completion block: (() -> Void)?) -> UINavigationController
    }

    extension ControllableProtocol where Self: ViewControllable, Self: UIViewController {
        func dismiss(viewController vc: ViewControllable, completion block: (() -> Void)? = nil) {
//            if presentedViewController === vc.uiviewController {
//                vc.uiviewController.dismiss(animated: true, completion: block)
//                return
//            }
            
            let currentVC = vc.uiviewController
            guard currentVC.parent != nil , currentVC.navigationController == nil else {
                currentVC.dismiss(animated: true, completion: block)
                return
            }
            
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
            block?()
        }

//    func pop() {
//        self.navigationController?.popViewController(animated: true)
//    }

        func present(viewController vc: ViewControllable, transitionType transition: TransitonType, completion block: (() -> Void)? = nil) {
            let currentVC = self
            let nextVC = vc.uiviewController

            switch transition {
            case .push:
                currentVC.navigationController?.pushViewController(nextVC, animated: true)

            case .modal(let type, let style):
                nextVC.modalTransitionStyle = type
                nextVC.modalPresentationStyle = style
                currentVC.present(nextVC, animated: true, completion: block)

            case .segue(let factory):
                let segue = factory(currentVC, nextVC)
                segue.perform()
            
            case .addChild(let custom):
                custom(nextVC.view, currentVC)
                currentVC.addChild(nextVC)
                nextVC.didMove(toParent: currentVC)
                block?()
                
            default:
                break
            }
        }

        func presentNavigationController(for vc: ViewControllable, transitionType transition: TransitonType, completion block: (() -> Void)?) -> UINavigationController {
            let currentVC = self
            let nextVC = vc.uiviewController
            let navigationVC = UINavigationController(rootViewController: nextVC)

            switch transition {
            case .modal(let type, let style):
                navigationVC.modalTransitionStyle = type
                navigationVC.modalPresentationStyle = style
                currentVC.present(navigationVC, animated: true, completion: block)

            default:
                break
            }

            return navigationVC
        }
    }
#endif

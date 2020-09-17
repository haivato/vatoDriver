//
//  RibTransition.swift
//  FaceCar
//
//  Created by Dung Vu on 12/4/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import FwiCore
import RIBs
import RxSwift
import UIKit

enum TransitonType {
    // Only View
    case childView
    case addChild(custom: (_ childView: UIView?, _ vc: UIViewController?) -> Void)
    
    // Only Controller
    case presentNavigation
    case push
    case popRoot
    case modal(type: UIModalTransitionStyle, presentStyle: UIModalPresentationStyle)
    case segue(segueFactory: (UIViewController, UIViewController) -> UIStoryboardSegue)
    case tabbar(customVC: (UIViewController) -> UIViewController)
    case custom(customVC: (UIViewController) -> (), remove: (UIViewController?) -> ())
}

// MARK: Protocol access controllable

protocol RibsAccessControllableProtocol {
    var viewControllable: ViewControllable { get }
}

protocol RibsTransitionInformationProtocol: AnyObject {
    var transitionType: TransitonType { get }
    var needRemoveCurrent: Bool { get }
    var isController: Bool { get set }
    
    // Function
    func perform(with root: Routing, completion block: RibsTransitionComplete?)
    func dismiss(from root: Routing, force: Bool, completion block: RibsTransitionComplete?)
}

typealias RibsTransitionComplete = () -> Void
protocol RibsInformationRouteProtocol: AnyObject {
    associatedtype R
    var nextRoute: R? { get set }
    var autoRemove: Bool { get set }
    var completeTransition: RibsTransitionComplete? { get set }
}

extension Interactor {
    var identifier: String {
        let interactorName = "\(type(of: self))"
        return interactorName
    }
}

extension RibsInformationRouteProtocol where Self: RibsTransitionInformationProtocol, R == Routing {
    private func attachChild(from root: Routing, next: Routing) {
        root.attachChild(next)
    }
    
    private func removeCurrentChild(from root: Routing, completion block: RibsTransitionComplete?) {
        guard needRemoveCurrent else {
            block?()
            return
        }
        let f = root.children.count
        root.dismissCurrentRoute(true, completion: {
            if f > 0 {
                let after = root.children.count
                assert(after < f, " Can't Remove")
            }
            block?()
        })
    }
    
    private func excute(from root: Routing, for nextRoute: Routing) -> Observable<Void> {
        // attach route
        let empty = root.children.isEmpty
        return Observable.create { (s) -> Disposable in
            let run = {
                self.attachChild(from: root, next: nextRoute)
                s.onCompleted()
            }
            guard !empty else {
                run()
                return Disposables.create()
            }
            self.removeCurrentChild(from: root, completion: run)
            return Disposables.create {}
        }
    }
    
    private func autoRelease() {
        guard let interactor = nextRoute?.interactable as? Interactor else {
            fatalError("Must be interactor avoid leak")
        }
        
        let tag = String(format: "%@ lifecycle!!!", interactor.identifier)
        nextRoute?.lifecycle.debug(tag).subscribe(onDisposed: { [weak self] in
            guard let wSelf = self else {
                return
            }
            let force = wSelf.autoRemove
            wSelf.cleanUp(with: !force, completion: wSelf.destroy)
        })
            .disposeOnDeactivate(interactor: interactor)
    }
    
    private func destroy() {
        completeTransition?()
        completeTransition = nil
        nextRoute?.transitionInformation = nil
        nextRoute = nil
    }
    
    func perform(with root: Routing, completion block: RibsTransitionComplete?) {
        guard let nextRoute = self.nextRoute else {
            return
        }
        
        // try copy
        completeTransition = block
        var check = block != nil
        func runComplete() {
            if check {
                assert(completeTransition != nil, "Check")
            }
            
            completeTransition?()
            completeTransition = nil
        }
        _ = excute(from: root, for: nextRoute).debug("Excute Perform!!!!").timeout(2, scheduler: MainScheduler.asyncInstance).do(onError: { _ in
            assert(false, "So long to get response")
        }).subscribe(onCompleted: { [unowned self] in
            guard let vRouting = nextRoute as? ViewableRouting else {
                self.isController = false
                runComplete()
                return
            }
            self.isController = true
            guard let rControllable = ((root as? ViewableRouting)?.viewControllable) ?? (root as? RibsAccessControllableProtocol)?.viewControllable else {
                fatalError(" Root must be ViewableRouting or conform RibsAccessControllableProtocol")
            }
            
            let currentVC = rControllable.uiviewController
            let nextVC = vRouting.viewControllable.uiviewController
            
            switch self.transitionType {
            case .custom(let customVC, _):
                customVC(nextVC)
                runComplete()
            case let .addChild(custom):
                custom(nextVC.view, currentVC)
                currentVC.addChild(nextVC)
                nextVC.didMove(toParent: currentVC)
                runComplete()
            case .push, .popRoot:
                currentVC.navigationController?.pushViewController(nextVC, animated: true)
                runComplete()
            case let .modal(type, style):
                nextVC.modalTransitionStyle = type
                switch style {
                case .currentContext, .custom, .overCurrentContext, .fullScreen:
                    nextVC.modalPresentationStyle = style
                default:
                    nextVC.modalPresentationStyle = .fullScreen
                }
                currentVC.present(nextVC, animated: true, completion: runComplete)
            case let .segue(factory):
                let segue = factory(currentVC, nextVC)
                segue.perform()
                runComplete()
            case .presentNavigation:
                let navigationVC = UINavigationController(rootViewController: nextVC)
                navigationVC.modalTransitionStyle = .coverVertical
                navigationVC.modalPresentationStyle = .fullScreen
                currentVC.present(navigationVC, animated: true, completion: runComplete)
            case let .tabbar(custom):
                guard let tabbarVC = currentVC as? UITabBarController else {
                    fatalError(" Implement")
                }
                
                let customVC = custom(nextVC)
                var current = tabbarVC.viewControllers ?? []
                current.append(customVC)
                tabbarVC.setViewControllers(current, animated: false)
                runComplete()
                
            default:
                fatalError(" Implement")
            }
            }, onDisposed: {
                self.autoRelease()
        })
    }
    
    private func cleanUp(with animated: Bool = true, completion block: RibsTransitionComplete? = nil) {
        guard let nextRoute = self.nextRoute else {
            return
        }
        let temp = ((nextRoute as? ViewableRouting)?.viewControllable) ?? (nextRoute as? RibsAccessControllableProtocol)?.viewControllable
        let currentVC = temp?.uiviewController
        switch transitionType {
        case .custom(_, let remove):
            remove(currentVC)
            DispatchQueue.main.async {
                block?()
            }
        case .addChild:
            currentVC?.willMove(toParent: nil)
            currentVC?.view.removeFromSuperview()
            currentVC?.removeFromParent()
            DispatchQueue.main.async {
                block?()
            }
        case .push:
            currentVC?.navigationController?.popViewController(animated: animated)
            DispatchQueue.main.async {
                block?()
            }
        case .childView:
            DispatchQueue.main.async {
                block?()
            }
        case .popRoot:
            currentVC?.navigationController?.popToRootViewController(animated: animated)
            DispatchQueue.main.async {
                block?()
            }
        case .modal, .presentNavigation, .segue:
            guard let vc = currentVC else {
                block?()
                return
            }
            if vc.presentingViewController != nil || vc.navigationController?.presentingViewController != nil {
                vc.dismiss(animated: animated, completion: block)
            } else {
                block?()
            }
        case .tabbar:
            guard let vc = (currentVC?.navigationController ?? currentVC) else {
                block?()
                return
            }
            guard let tabbarVC = vc.tabBarController else {

                fatalError("")
            }
            var listVC = tabbarVC.viewControllers
            guard let idx = listVC?.firstIndex(of: vc) else {
                block?()
                return
            }
            listVC?.remove(at: idx)
            tabbarVC.setViewControllers(listVC, animated: false)
            block?()
        }
    }
    
    func dismiss(from root: Routing, force: Bool, completion block: RibsTransitionComplete?) {
        guard let nextRoute = self.nextRoute else {
            block?()
            return
        }
        autoRemove = force
        assert(completeTransition == nil, "Duplicate  ")
        completeTransition = block
        root.detachChild(nextRoute)
        LeakDetector.instance.expectDeallocate(object: nextRoute)
    }
}

final class RibsRouting: RibsTransitionInformationProtocol, RibsInformationRouteProtocol, CustomStringConvertible {
    var autoRemove: Bool = true
    var description: String = ""
    var transitionType: TransitonType
    var needRemoveCurrent: Bool
    var nextRoute: Routing?
    var isController: Bool = false
    var completeTransition: RibsTransitionComplete? {
        didSet {
            assert(oldValue == nil || completeTransition == nil, "Check !!!!!!!!!!!")
        }
    }
    
    init(use route: Routing, transitionType: TransitonType, needRemoveCurrent: Bool) {
        nextRoute = route
        self.transitionType = transitionType
        self.needRemoveCurrent = needRemoveCurrent
        description = "\(type(of: route))"
        nextRoute?.transitionInformation = self
    }
    
    deinit {
        print("\(#function) name: \(description)")
    }
}

private struct RoutingInformation {
    static var name = "RoutingInformation"
}

// MARK:

extension Routing {
    fileprivate var transitionInformation: RibsTransitionInformationProtocol? {
        get {
            let r = objc_getAssociatedObject(self, &RoutingInformation.name)
            return r as? RibsTransitionInformationProtocol
        }
        
        set {
            objc_setAssociatedObject(self, &RoutingInformation.name, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // attach
    func perform(with transition: RibsTransitionInformationProtocol, completion block: RibsTransitionComplete?) {
        transition.perform(with: self, completion: block)
    }
    
    private func observer(from t: RibsTransitionInformationProtocol) -> Observable<Void> {
        return Observable.create { (s) -> Disposable in
            t.perform(with: self, completion: {
                s.onNext(())
                s.onCompleted()
            })
            return Disposables.create()
            }.observeOn(MainScheduler.asyncInstance)
    }
    
    func perform(with moreTransitions: [RibsTransitionInformationProtocol], completion block: RibsTransitionComplete?) {
        let operations = moreTransitions.map(observer)
        _ = Observable.zip(operations).subscribe(onCompleted: block)
    }
    
    func dismissRoute(_ force: Bool = false, by condition: (Routing) -> Bool, completion block: RibsTransitionComplete?) {
        let f = children.first(where: condition)
        guard let t = f?.transitionInformation else {
            block?()
            return
        }
        t.dismiss(from: self, force: force, completion: block)
    }
    
    func detachAllChild() -> Observable<Void> {
        let childrens = children
        guard childrens.count > 0 else {
            return Observable.just(())
        }
        var count = childrens.count
        return Observable.create { (s) -> Disposable in
            func remove() {
                guard count > 0 else {
                    let name = self.children.map { "\(type(of: $0))" }.joined(separator: " ")
                    assert(self.children.isEmpty, "Track \(name)")
                    s.onNext(())
                    s.onCompleted()
                    return
                }
                count -= 1
                let child = childrens[count]
                guard let t = child.transitionInformation else {
                    remove()
                    return
                }
                t.dismiss(from: self, force: true, completion: remove)
            }
            remove()
            return Disposables.create()
        }
    }
    
    func dismissCurrentRoute(_ force: Bool = false, completion block: RibsTransitionComplete?) {
        let m = children.last
        guard let last = m,
            let t = last.transitionInformation else {
                assert(m == nil, "Check")
                block?()
                return
        }
        
        // remove all children
        if last.children.count > 0 {
            let mChildren = last.children
            var childrens = sequence(first: mChildren, next: {
                let n = $0.flatMap { $0.children }
                return !n.isEmpty ? n : nil
            }).flatMap { $0 }.filter { $0.children.count > 0 }
            childrens.insert(last, at: 0)
            let action = childrens.count > 0 ? {
                childrens.insert(last, at: 0)
                childrens = childrens.reversed()
                let count = childrens.count
                let value = Variable<Int>(0)
                
                _ = value.asObservable().observeOn(MainScheduler.asyncInstance).filter { $0 == count }.take(1).subscribe(onNext: { _ in
                    t.dismiss(from: self, force: force, completion: block)
                })
                
                _ = value.asObservable().filter { $0 < count }.flatMap { (idx) -> Observable<Void> in
                    let child = childrens[idx]
                    return child.detachAllChild()
                    }.subscribe(onNext: {
                        value.value += 1
                    })
                } : {
                    t.dismiss(from: self, force: force, completion: block)
            }
            action()
        } else {
            t.dismiss(from: self, force: force, completion: block)
        }
    }
}
 

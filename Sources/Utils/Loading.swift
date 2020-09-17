//  File name   : Loading.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import FwiCore
import FwiCoreRX
import RIBs

protocol LoadingViewProtocol {
    static func showProgress(_ progress: Float, status: String?)
    static func dismiss()
}

// MARK: - Loading for can't check progress
@objcMembers
final class LoadingManager: NSObject, ManageListenerProtocol {
    internal var listenerManager: [Disposable] = []
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    typealias Element = ActivityProgressIndicator.Element
    typealias EventLoad = Observable<Element>
    static let instance = LoadingManager()
    private var loadingType: LoadingViewProtocol.Type?
    #if DEBUG
    fileprivate var log: [String] = []
    #endif
    
    private func register(type: LoadingViewProtocol.Type) {
        loadingType = type
    }
    
    private func show(duration: TimeInterval = 30) {
        assert(duration > 0, "Check condition !!!")
        var current: Double = 0
        let ratio =  30 / duration
        let listener = Observable<Int>.interval(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance).map { _  -> Element in
            current += (1 * ratio)
            let p = min(current / 100, 1)
            return Element(true, p)
        }
        add(add(listener: listener, key: "Manual show"))
    }
    
    private func add(listener: EventLoad, key: String) -> Disposable {
        let dispose = listener.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self](loading, percent) in
            #if DEBUG
                print("!!! Loading : \(key)")
            #endif
            if loading {
                self?.loadingType?.showProgress(Float(percent), status: "\(Int(percent * 100))%")
            } else {
                self?.loadingType?.dismiss()
            }
        }, onDisposed: loadingType?.dismiss)
        return dispose
    }
    
    private func dismiss() {
        cleanUpListener()
    }
}

extension LoadingManager {
    static func register(type: LoadingViewProtocol.Type) {
        LoadingManager.instance.register(type: type)
    }
    
    static func showProgress(duration: TimeInterval = 30) {
        LoadingManager.instance.show(duration: duration)
    }
    
    static func dismissProgress() {
        LoadingManager.instance.dismiss()
    }
    
    fileprivate static func show(use listener: EventLoad?, key: String) -> Disposable {
        guard let listener = listener else {
            return Disposables.create()
        }
        return LoadingManager.instance.add(listener: listener, key: key)
    }
    
    fileprivate static func log(key: String) {
        #if DEBUG
            LoadingManager.instance.log.append(key)
        #endif
    }
}

// MARK: - Loading Protocol Dependency
protocol LoadingAnimateProtocol {}
extension LoadingAnimateProtocol where Self: DisposableProtocol {
    func showLoading(use listener:LoadingManager.EventLoad?) {
        let key = "\(type(of: self))"
        LoadingManager.log(key: key)
        LoadingManager.show(use: listener, key: key).disposed(by: disposeBag)
    }
}

extension LoadingAnimateProtocol where Self: Interactor {
    func showLoading(use listener:LoadingManager.EventLoad?) {
        let key = "\(type(of: self))"
        LoadingManager.log(key: key)
        LoadingManager.show(use: listener, key: key).disposeOnDeactivate(interactor: self)
    }
}

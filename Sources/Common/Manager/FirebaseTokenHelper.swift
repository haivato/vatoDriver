//  File name   : FirebaseTokenHelper.swift
//
//  Author      : Dung Vu
//  Created date: 12/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FirebaseAuth
import Firebase
import RxSwift
import FwiCoreRX

@objcMembers
final class FirebaseTokenHelper: NSObject, ManageListenerProtocol {
    static let instance = FirebaseTokenHelper()
    internal var listenerManager: [Disposable] = []
    internal lazy var lock: NSRecursiveLock = NSRecursiveLock()
    struct Configs {
        static let timeRefreshToken: TimeInterval = 720
    }
    private lazy var mToken = ReplaySubject<String?>.create(bufferSize: 1)
    var eToken: Observable<String?> {
        return mToken
    }
    private var _token: String? {
        didSet {
            mToken.onNext(_token)
        }
    }
    
    private (set) var token: String? {
        get {
            return excute { _token }
        }
        
        set {
            excute { _token = newValue }
        }
    }
    
    private func getUser() -> Observable<User?> {
        return Observable.create({ (s) -> Disposable in
            let handle = Auth.auth().addIDTokenDidChangeListener { (_, user) in
                s.onNext(user)
                if user != nil {
                    s.onCompleted()
                }
            }
            
            return Disposables.create {
                Auth.auth().removeIDTokenDidChangeListener(handle)
            }
        })
    }
    
    private func getToken(user: User) -> Observable<String?> {
        return Observable.create({ (s) -> Disposable in
            user.getIDTokenForcingRefresh(true) { (token, err) in
                if let err = err {
                    return s.onError(err)
                }
                s.onNext(token)
                s.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    private func requestToken() {
        let dispose = getUser().filterNil().take(1).flatMap(getToken).subscribe(onNext: { [unowned self](token) in
            self.token = token
        }, onError: { (e) in
//            assert(false, e.localizedDescription)
        })
        add(dispose)
    }
    
    private func autoRefresh() {
        let e1 = Observable<Int>
            .interval(Configs.timeRefreshToken, scheduler: MainScheduler.asyncInstance).map { _ in }
        let e2 = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification).map { _ in }
        let dispose = Observable.merge([e1, e2])
            .bind { [unowned self](_) in
                self.requestToken()
        }
        add(dispose)
    }
    
    private func getCurrentToken() {
        Auth.auth().currentUser?.getIDTokenResult(completion: { (result, e) in
            if let e = e {
                assert(false, e.localizedDescription)
            }
            
            let token = result?.token
            assert(token != nil, "Check logic")
            self.token = token
        })
    }
    
    func startUpdate() {
        // get current first
        getCurrentToken()
        autoRefresh()
    }
    
    func stopUpdate() {
        cleanUpListener()
        token = nil
    }

}

// MARK: Class's public methods
extension FirebaseTokenHelper {
}

// MARK: Class's private methods
private extension FirebaseTokenHelper {
}

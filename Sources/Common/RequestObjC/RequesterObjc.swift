//  File name   : RequesterObjc.swift
//
//  Author      : Dung Vu
//  Created date: 11/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import VatoNetwork
import RxSwift
import RxCocoa
import Alamofire
import SVProgressHUD

protocol ManageListenerProtocol: AnyObject, SafeAccessProtocol {
    var listenerManager: [Disposable] { get set }
}

extension ManageListenerProtocol {
    func cleanUpListener() {
        excute(block: { [unowned self] in
            self.listenerManager.forEach({ $0.dispose() })
            self.listenerManager.removeAll()
        })
    }
    
    func add(_ disposable: Disposable) {
        excute(block: { [unowned self] in
            self.listenerManager.append(disposable)
        })
    }
}

@objcMembers
final class RequesterObjc: NSObject, ActivityTrackingProgressProtocol {
    static let instance = RequesterObjc()
    private lazy var disposeBag = DisposeBag()
    override init() {
        super.init()
        setupRX()
    }
    
    private func setupRX() {
        indicator.asObservable().observeOn(MainScheduler.asyncInstance).bind { (loading, percent) in
            if loading {
                SVProgressHUD.showProgress(Float(percent), status: "\(Int(percent * 100))%")
            } else {
                SVProgressHUD.dismiss()
            }
        }.disposed(by: disposeBag)
    }
    
    func request(token: String?, path: String, method: String, header: [String: String]?,  params: [String: Any]?, trackProgress: Bool = true, handler: (([String: Any]?, Error?) -> ())?) {
        guard let token = token else { return }
        let m = HTTPMethod(rawValue: method)
        let encoding: ParameterEncoding
        if m == .get {
            encoding = URLEncoding.default
        } else {
            encoding = JSONEncoding.default
        }
        var request: Observable<(HTTPURLResponse, Data)> = Requester
            .request(using: VatoAPIRouter.customPath(authToken: token, path: path, header: header, params: params, useFullPath: false), method: m, encoding: encoding)
        if trackProgress {
            request = request.trackProgressActivity(indicator)
        }
        
        request
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (res) in
                do {
                    let json = try JSONSerialization.jsonObject(with: res.1, options: [])
                    handler?(json as? [String: Any], nil)
                } catch {
                    handler?(nil, error)
                }
        }, onError: { (e) in
            handler?(nil, e)
        }).disposed(by: disposeBag)
    }
}

@objcMembers
final class LoadingManager: NSObject, ManageListenerProtocol {
    internal var listenerManager: [Disposable] = []
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()

    static let instance = LoadingManager()

    private var loadingType: LoadingViewProtocol.Type?
    typealias Element = ActivityProgressIndicator.Element
    typealias EventLoad = Observable<Element>
    
    #if DEBUG
    fileprivate var log: [String] = []
    #endif

    func show() {
        var current: Float = 0
        let disposeProgress = Observable<Int>.interval(.milliseconds(300), scheduler: MainScheduler.instance).subscribe(onNext: { (_) in
            current += 1
            let p = min(current / 100, 1)
            SVProgressHUD.showProgress(current / 100, status: "\(Int(p * 100))%")
        }, onDisposed: {
           SVProgressHUD.dismiss()
        })
        add(disposeProgress)
    }

    func dismiss() {
        cleanUpListener()
    }
    
    private func register(type: LoadingViewProtocol.Type) {
        loadingType = type
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
}

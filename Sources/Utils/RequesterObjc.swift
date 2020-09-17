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

import FwiCore
import FwiCoreRX
import RIBs

@objcMembers
final class RequesterObjc: NSObject, ActivityTrackingProgressProtocol, DisposableProtocol, LoadingAnimateProtocol {
    static let instance = RequesterObjc()
    lazy var disposeBag = DisposeBag()
    override init() {
        super.init()
        setupRX()
    }
    
    private func setupRX() {
        showLoading(use: indicator.asObservable())
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
        let request: Observable<(HTTPURLResponse, Data)> = Requester
            .request(using: VatoAPIRouter.customPath(authToken: token, path: path, header: header, params: params, useFullPath: false), method: m, encoding: encoding)
        if trackProgress {
            LoadingManager.showProgress()
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
                LoadingManager.dismissProgress()
        }, onError: { (e) in
            LoadingManager.dismissProgress()
            handler?(nil, e)
        }, onDisposed: {
            LoadingManager.dismissProgress()
        }).disposed(by: disposeBag)
    }
}



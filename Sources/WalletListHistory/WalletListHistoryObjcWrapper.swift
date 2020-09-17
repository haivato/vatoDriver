//  File name   : WalletListHistoryObjcWrapper.swift
//
//  Author      : Dung Vu
//  Created date: 12/13/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import UIKit
import RxSwift
import RIBs

@objc protocol WalletListHistoryDetailProtocol: NSObjectProtocol {
    func showDetail(from json: [String: Any]?)
}

@objc enum ListHistoryType: Int {
    case credit = 3
    case hardCash = 12
    case all = 15
}

@objcMembers
final class WalletListHistoryObjcWrapper: NSObject, WalletListHistoryDependency, AuthenticatedStream, WalletListHistoryListener {
    var googleAPI: Observable<String> {
        return Observable.empty()
    }
    
    var firebaseAuthToken: Observable<String> {
        return self._firebaseAuthToken.filterNil()
    }
    
    var authenticated: AuthenticatedStream {
        return self
    }
    
    /// Class's private properties.
    typealias Object = UIViewController & WalletListHistoryDetailProtocol
    private weak var controller: Object?
    private lazy var _firebaseAuthToken = ReplaySubject<String?>.create(bufferSize: 1)
    private var currentRoute: WalletListHistoryRouting?
    private var type: ListHistoryType = .all
    convenience init(withVC controller: Object?, firebaseAuthen: String?, type: ListHistoryType){
        self.init()
        self.type = type
        self._firebaseAuthToken.onNext(firebaseAuthen)
        self.controller = controller
    }
    
    func showList() {
        let builder = WalletListHistoryBuilder(dependency: self)
        let route = builder.build(withListener: self, balanceType: type.rawValue)
        let listVC = route.viewControllable.uiviewController
        self.currentRoute = route
        self.controller?.navigationController?.pushViewController(listVC, animated: true)
    }
    
    func listDetailMoveBack() {
        controller?.navigationController?.popViewController(animated: true)
        self.currentRoute = nil
    }
    
    func showDetail(by item: WalletItemDisplayProtocol) {
        guard let item = item as? WalletTransactionItem else {
            return
        }
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(item) else {
            return
        }
        
        let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
        self.controller?.showDetail(from: json)
    }
    
    deinit {
        printDebug("\(#function)")
    }
}



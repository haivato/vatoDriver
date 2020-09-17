//
//  AddDestinationCommunication.swift
//  FC
//
//  Created by khoi tran on 3/27/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import VatoNetwork
import RxSwift
import FirebaseFirestore

protocol AddDestinationProtocol: class {
    func showConfirmView(detail: AddDestinationRequestDetail)
    func showErrorView(message: String)
}

@objcMembers
final class AddDestinationCommunication: NSObject, SafeAccessProtocol, ManageListenerProtocol {
    var lock: NSRecursiveLock = NSRecursiveLock()
    
    var listenerManager: [Disposable] = []
    
    static let shared = AddDestinationCommunication()
    
    weak var delegate: AddDestinationProtocol?

    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    
    struct Configs {
        static let url: (String) -> String = { p in
            #if DEBUG
            return "https://api-dev.vato.vn\(p)"
            #else
            return "https://api.vato.vn\(p)"
            #endif
        }
        
        static let genError: (String?) -> NSError = { messge in
            return NSError(domain: NSURLErrorDomain,
                           code: NSURLErrorUnknown,
                           userInfo: [NSLocalizedDescriptionKey: messge ?? "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."])
        }
    }
     func listenChangeDestination() {
        guard let userId = UserManager.shared.getUserId() else { return }
        let collectionRef = Firestore.firestore().collection(collection: .notifications, .custom(id: "\(userId)"), .custom(id: "driver"))
        let dispose = collectionRef.listenNotificationTaxi().subscribe(onNext: { [weak self] (l) in
            
            let add = (l.documentsAdd?.compactMap { try? $0.decode(to: AddDestinationNotification.self) } ?? []).sorted { (a1, a2) -> Bool in
                return a1.created_at ?? 0 > a2.created_at ?? 0
            }
            
            if !add.isEmpty, let first = add.first, first.isValid() {
                self?.showConfirmView(notification: first)
            }
            
            
            
        })
        add(dispose)
    }
    
    func stopListenNotification() {
        self.cleanUpListener()
    }
    
    func showConfirmView(notification: AddDestinationNotification) {
        if let orderId = notification.payload?.orderId {
            if let status = notification.payload?.status, status == .reject {
                NotificationCenter.default.post(name: .addDestinationTripCancel, object: notification)
            } else {
                self.requestDestinationOrder(orderId: orderId)
            }
        }
    }
    
    func requestDestinationOrder(orderId: Int) {
        let url = Configs.url("/api/destination-order/\(orderId)")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let dispose = network.request(using: router, decodeTo: OptionalMessageDTO<AddDestinationRequestDetail>.self).bind {[weak self] (result) in
                   guard let wSelf = self else { return }
                   switch result {
                   case .success(let s):
                        if let data = s.data, let delegate = wSelf.delegate {
                            delegate.showConfirmView(detail: data)
                        }
                   case .failure(let e):
                    if let delegate = wSelf.delegate {
                        delegate.showErrorView(message: e.localizedDescription)
                    }
                   }
               }
        add(dispose)

    }
}


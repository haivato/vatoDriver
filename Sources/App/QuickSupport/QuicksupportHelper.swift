//
//  QuicksupportHeper.swift
//  FC
//
//  Created by vato. on 2/11/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore
@objcMembers
class QuicksupportHelper: NSObject {
    @VariableReplay(wrappedValue: 0) private (set) var mUnreadNumber: Int
    
    static let shared = QuicksupportHelper()
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
    var unreadNumber: Observable<Int> {
        return $mUnreadNumber.asObservable()
    }
    
    func requestUnread() -> Observable<Int>{
        guard let userId = UserManager.shared.getUserId() else {
            return Observable.empty()
        }
        
        let collectionRef = Firestore.firestore().collection(collection: .quickSupport)
        let query = collectionRef
            .whereField("createdBy", isEqualTo: userId)
            .whereField("userType", isEqualTo: UserType.driver.rawValue)
            .whereField("numberOfUnread", isGreaterThan: 0)
        return query
            .getDocuments()
            .take(1)
            .map { [weak self] snapshots -> Int in
                let items = snapshots?.compactMap { try? $0.decode(to: QuickSupportModel.self) }
                let result = (items ?? []).reduce(0, { $0 + ($1.numberOfUnread ?? 0)})
                self?.mUnreadNumber = result
                return result
        }
    }
    
    func getUnreadMessage(completion: ((Int, Error?) -> ())?) {
        requestUnread().subscribe(onNext: { (m) in
            completion?(m, nil)
        }, onError: { (e) in
            completion?(0, e)
        }).disposed(by: disposeBag)
    }
}

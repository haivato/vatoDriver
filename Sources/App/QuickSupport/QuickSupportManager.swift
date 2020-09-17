//
//  QuickSupportManager.swift
//  Vato
//
//  Created by khoi tran on 3/5/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore

@objcMembers
final class QuickSupportManager: NSObject {
    
    public static let shared = QuickSupportManager()
    internal lazy var disposeBag = DisposeBag()
    
    @VariableReplay(wrappedValue: []) private var mListQuickSupport: [QuickSupportRequest]
    
    func getListRequest() {
        let collectionRef = Firestore.firestore().collection(collection: .quickSupportCategory)
        let query = collectionRef.whereField("active", isEqualTo: 1).whereField("appType", isEqualTo: UserType.client.rawValue).order(by: "position", descending: false)
        
        query
            .getDocuments()
            .map { $0?.compactMap { try? $0.decode(to: QuickSupportRequest.self) } }
            .bind { (d) in
                self.mListQuickSupport = d ?? []
        }.disposed(by: disposeBag)
    }
    
    
    var listQuickSupport: Observable<[QuickSupportRequest]> {
        return $mListQuickSupport.asObservable()
    }
}

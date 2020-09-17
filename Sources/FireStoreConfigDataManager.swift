//
//  FireBase+ConfigData.swift
//  Vato
//
//  Created by vato. on 11/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxCocoa

@objcMembers class FireStoreConfigDataManager: NSObject {
    struct Configs {
        static let rootCategoryIdBuyUniform = 315
    }
    static let shared = FireStoreConfigDataManager()
    func getConfigBuyUniform() -> Observable<Int> {
        let documentRef = Firestore.firestore().documentRef(collection: .configData, storePath: .custom(path: "Driver") , action: .read)
        
        return documentRef.find(action: .get, json: nil, source: .server).map { snapshot -> Int in
            let d = snapshot?.data()
            let json: JSON? = d?.value("VatoShop", defaultValue: nil)
            let id: Int? = json?.value("rootCategoryId", defaultValue: nil)
            return id ?? Configs.rootCategoryIdBuyUniform
        }
    }
}

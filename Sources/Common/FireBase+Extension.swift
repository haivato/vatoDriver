//  File name   : FireBase.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Firebase
import RxSwift


struct AppConfigure: Codable, ModelFromFireBaseProtocol {
    var theme_storage_path_ios_client: String?
    
}


extension DatabaseReference {
    
    func findAppConfigure() -> Observable<AppConfigure> {
        //FarePredicate
        let node = FireBaseTable.master >>> .appConfigure
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<AppConfigure> in
                let config = try AppConfigure.create(from: snapshot)
                return Observable.just(config)
        }
    }
}

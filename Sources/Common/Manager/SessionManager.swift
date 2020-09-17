//
//  MetaDataManager.swift
//  Vato
//
//  Created by vato. on 7/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import RIBs
import Foundation
import RxSwift
import Firebase
import VatoNetwork

class SessionManager {
    static fileprivate(set) var shared = SessionManager()
    
    var authStream: AuthenticatedStream? = nil
    
    func firebaseToken() -> Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil().take(1)
    
    }
}



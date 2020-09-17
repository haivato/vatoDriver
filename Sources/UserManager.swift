//
//  UserManager.swift
//  FC
//
//  Created by vato. on 1/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift


struct UserManager {
    static let shared = UserManager()
    func getAvatarUrl() -> URL? {
        guard let user = UserDataHelper.shareInstance().getCurrentUser(),
            let avatar = user.user.avatarUrl else {
                return nil
        }
        return URL(string: avatar)
    }
    
    func getCurrentUser() -> FCDriver? {
        return UserDataHelper.shareInstance().getCurrentUser()
    }
    
    func getUserId() -> Int? {
          return UserDataHelper.shareInstance().getCurrentUser()?.user.id
      }
    
    func getCurrentLocation() -> CLLocationCoordinate2D {
        let currentLoc = GoogleMapsHelper.shareInstance().currentLocation?.coordinate
        return currentLoc ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    var autoAccept: Bool? {
        return UserDataHelper.shareInstance().autoAccept?.boolValue
    }
}


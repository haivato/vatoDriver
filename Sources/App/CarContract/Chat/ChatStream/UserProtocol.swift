//
//  UserProtocol.swift
//  FC
//
//  Created by Phan Hai on 29/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

protocol UserProtocol {
    var firebaseID: String { get }
    var userID: Int64 { get }
    var fullname: String? { get }
    var nicknamee: String? { get }
    var phoneDriver: String { get }
    var cashDriver: Double { get }
    var coinDriver: Double { get }

    var emailAddress: String { get }
    var photoURL: URL? { get }
}

extension UserProtocol {
    var displayName: String {
        guard let nickname = nicknamee, nickname.count > 0 else {
            return fullname ?? ""
        }
        return nickname
    }

    var updateFirebaseUser: [String:Any] {
        let info: [String:Any] = [
            "firebaseId":firebaseID,
            "id":NSNumber(value: userID),
            "fullName":fullname ?? "",
            "nickname":nicknamee ?? "",
            "phone":phoneDriver,
            "cash":NSNumber(value: cashDriver),
            "coin":NSNumber(value: coinDriver),

            "email":emailAddress
        ]
        return info
    }
}
extension FCUser: UserProtocol {
    var phoneDriver: String {
        return phone
    }
    
    var cashDriver: Double {
        return Double(cash)
    }
    
    var coinDriver: Double {
        return Double(coin)
    }
    
    var firebaseID: String {
        return firebaseId
    }
    
    var userID: Int64 {
        return Int64(self.id)
    }
    
    var fullname: String? {
        return fullName
    }
    
    var nicknamee: String? {
        return nickname
    }
    
    var emailAddress: String {
        return email ?? ""
    }
    
    var photoURL: URL? {
        guard let url = URL(string: avatarUrl ?? "") else { return nil }
        return url
    }
    
}

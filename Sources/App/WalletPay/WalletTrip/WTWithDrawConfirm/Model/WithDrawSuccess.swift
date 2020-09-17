//
//  WithDrawSuccess.swift
//  FC
//
//  Created by MacbookPro on 5/26/20.
//  Copyright © 2020 Vato. All rights reserved.
//

struct WithDrawSuccess: Codable {
    let createdBy, updatedBy, createdAt, updatedAt: Int
    let id, userID: Int
    let code: String
    let amount: Int
    let transactionID: Int
    let bankAccount, bankName, accountName: String
    let status: Int
    let done, dataInit, processing: Bool

    enum CodingKeys: String, CodingKey {
        case createdBy, updatedBy, createdAt, updatedAt, id
        case userID = "userId"
        case code, amount
        case transactionID = "transactionId"
        case bankAccount, bankName, accountName
        case status, done
        case dataInit = "init"
        case processing
    }
}

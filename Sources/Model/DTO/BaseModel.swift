//  File name   : BaseModel.swift
//
//  Author      : Dung Vu
//  Created date: 11/8/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct MessageDTO<T: Decodable>: Decodable {
    let message: String?
    let errorCode: String?
    let status: Int
    let data: T?
    
    var fail: Bool {
        return status != 200
    }
    
    var error: Error? {
        guard fail else {
            return nil
        }
        
        return NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey : errorCode ?? ""])
    }
}

struct UserBankInfo: Codable, Comparable, Equatable {
    let createdBy: Int
    let updatedBy: Int
    let createdAt: Date
    let updatedAt: Date
    let id: Int
    let userId: Int
    let bankCode: Int
    let bankAccount: String
    let accountName: String
    var idCard: String?
    var verified: Bool?
    var bankInfo: BankInfoServer?
    var amountNeedWithDraw: Int?

    static func < (lhs: UserBankInfo, rhs: UserBankInfo) -> Bool {
        return lhs.bankCode < rhs.bankCode
    }

    static func == (lhs: UserBankInfo, rhs: UserBankInfo) -> Bool {
        return lhs.bankCode == rhs.bankCode
    }
}

struct WithdrawOrder: Codable {
    let createdBy: Int
    let updatedBy: Int
    let createdAt: Date
    let updatedAt: Date
    let id: Int
    let userId: Int
    let code: String
    let amount: Int
//    let approvedBy: Any? //TODO: Specify the type to conforms Codable protocol
//    let approvedAt: Any? //TODO: Specify the type to conforms Codable protocol
//    let detail: Any? //TODO: Specify the type to conforms Codable protocol
    let transactionId: Int
    let bankAccount: String
    let bankName: String
    let accountName: String
//    let status: Int
//    let processed: Bool
//    let transferred: Bool
//    let rejected: Bool
    let done: Bool
}

struct BankInfo: Codable, Comparable, Equatable {
    let bankId: Int
    let bankName: String
    let bankShortName: String
    let icon: URL
    let min: Double
    let max: Double
    let options: [Double]

    static func < (lhs: BankInfo, rhs: BankInfo) -> Bool {
        return lhs.bankId < rhs.bankId
    }

    static func == (lhs: BankInfo, rhs: BankInfo) -> Bool {
        return lhs.bankId == rhs.bankId
    }
}

enum TypeBankName: Int {
    case Agribank = 1
    case VietinBank = 2
    case Techcombank = 4
    case Vietcombank = 8
}
struct BankInfoServer: Codable {
    let bankID: Int
    let bankName, bankShortName: String
    let icon: URL
    let min: Double
    var options: [Double]
    let max: Double

    enum CodingKeys: String, CodingKey {
        case bankID = "bankId"
        case bankName, bankShortName, icon, min, options, max
    }

}


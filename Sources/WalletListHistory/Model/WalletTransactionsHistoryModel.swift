//  File name   : WalletTransactionsHistoryModel.swift
//
//  Author      : Dung Vu
//  Created date: 12/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct WalletTransactionItem: Codable, WalletItemDisplayProtocol, Comparable {
    var increase: Bool {
            let userId = UserDataHelper.shareInstance().userId()
            return userId == accountTo
    }
    
    var title: String? {
        switch type {
        case 100:
            return "Chuyến đi"
        case 40001:
            return "Nạp tiền"
        case 50001:
            return "Rút tiền"
        case 60001:
            return "Chuyển tiền"
        case 70001:
            return "Chờ duyệt"
        default:
            return ""
        }
    }
    
//    accountFrom = 73043;
//    accountTo = 1;
//    after = 9810312;
//    amount = 100000;
//    balanceType = 4;
//    before = 9910312;
//    createdAt = 1544692399767;
//    createdBy = 73043;
//    description = "Chuy\U1ec3n 100,000 \U0111 t\U1eeb v\U00ed 0395305025 qua v\U00ed 0395305025.";
//    groupId = 76WZMAIY0G;
//    id = 3000028;
//    referId = 76WZMAIY0G;
//    referType = 60001;
//    source = "VATO_DRIVER_APP";
//    status = COMPLETED;
//    transactionDate = 1544692399745;
//    type = 90003;
//    updatedAt = 1544692399767;
//    updatedBy = 73043;
    
    var id: Int
    var transactionDate: Double
    var description: String?
    var referId: String?
    let type: Int
//    let status: Int
    let accountFrom: Int
    let accountTo: Int
    var source: String?
    var groupId: String?
    let after: Double
    var amount: Double
    let balanceType: Int
    let before: Double
    let createdAt: Int
    let createdBy: Int
    let referType: Int
    let status: Int
    
    static func <(lhs: WalletTransactionItem, rhs: WalletTransactionItem) -> Bool {
        let today = Date().timeIntervalSince1970 * 1000
        let d1 = lhs.transactionDate - today
        let d2 = rhs.transactionDate - today
        return d1 < d2
    }
}

struct WalletTransactionsHistoryResponse: Codable {
//    transactions
    // more
    var transactions: [WalletTransactionItem]?
    var more: Bool = false
}



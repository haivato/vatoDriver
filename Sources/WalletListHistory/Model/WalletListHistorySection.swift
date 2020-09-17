//  File name   : WalletListHistorySection.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

enum ListHistorySection: Error {
    case notExists
    case notChild
}

final class WalletListHistorySection: Equatable {
    private let date: Date
    private(set) var items: [WalletTransactionItem] = []
    private(set) lazy var name = date.string(from: "dd/MM/yyyy")
    var needReload: Bool = false
    
    init(by item: WalletTransactionItem) {
        let n = Date(timeIntervalSince1970: item.transactionDate / 1000)
        self.date = n
        items.append(item)
    }
    
    func add(from item: WalletTransactionItem) throws {
        let n = Date(timeIntervalSince1970: item.transactionDate / 1000)
        guard Calendar.current.isDate(date, inSameDayAs: n) else {
            throw ListHistorySection.notChild
        }
        items.append(item)
    }
    
    static func ==(lhs: WalletListHistorySection, rhs: WalletListHistorySection) -> Bool {
        return lhs.date == rhs.date
    }
}


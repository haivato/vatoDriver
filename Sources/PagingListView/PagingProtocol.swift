//  File name   : PagingProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 10/24/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

protocol PagingNextProtocol {
    static var `default`: Self { get }
    var page: Int { get }
    var size: Int { get }
    var canRequest: Bool { get }
    var next: Self? { get }
    var first: Bool { get }
    init(page: Int, canRequest: Bool, size: Int)
}

extension PagingNextProtocol {
    var next: Self? {
        guard canRequest else {
            return nil
        }
        return Self(page: page + 1, canRequest: false, size: size)
    }
    
    var first: Bool {
        return page <= 0
    }
}

enum ListUpdate<T> {
    case reload(items: [T])
    case update(items: [T])
}

struct ResponsePaging<T: Codable>: Codable {
    var data: [T]?
    var totalPage: Int = 0
    var pageSize: Int = 0
    var currentPage: Int = 0
    var next: Bool {
        let result = currentPage != totalPage
        return result
    }
}

struct Paging: PagingNextProtocol {
    static let `default` = Paging(page: -1, canRequest: true, size: 30)
    
    var page: Int
    var size: Int
    var canRequest: Bool
    
    init(page: Int, canRequest: Bool, size: Int) {
        self.page = page
        self.canRequest = canRequest
        self.size = size
    }
}

struct PagingKeyword: PagingNextProtocol {
    static let `default` = PagingKeyword(page: -1, canRequest: true, size: 30)
    var keyword: String?
    var page: Int
    var size: Int
    var canRequest: Bool
    
    var first: Bool {
        return page <= 0
    }
    
    var next: PagingKeyword? {
        guard canRequest else {
            return nil
        }
        
        return PagingKeyword(keyword: keyword, page: page, size: size, canRequest: false)
    }
    
    mutating func update(keyword: String?) {
        self.keyword = keyword
    }
    
    mutating func resetPage() {
        self.page = -1
        self.canRequest = true
    }
}

extension PagingKeyword {
    init(page: Int, canRequest: Bool, size: Int) {
        self.keyword = nil
        self.page = page
        self.canRequest = canRequest
        self.size = size
    }
    
    var params: [String: Any] {
        var p = [String: Any]()
        p["indexPage"] = page
        p["name"] = keyword
        p["sizePage"] = size
        p["sortCreateDate"] = true
        p["status"] = 4
        return p
    }
}

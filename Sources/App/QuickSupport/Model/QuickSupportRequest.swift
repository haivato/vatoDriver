//
//  QuickSupportModel.swift
//  FC
//
//  Created by khoi tran on 1/14/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation


struct QuickSupportList: Codable {
    let values: [QuickSupportRequest]?
}

protocol QuickSupportDisplay {
    var title: String? { get }
    var description: String? { get }
    var enable: Bool { get }
}

struct QuickSupportRequest: QuickSupportDisplay, Codable {
    var enable: Bool {
        return (active ?? 0 > 0)
    }
    
    var description: String? {
        return content
    }
    var id: String?
    var title: String?
    var content: String?
    var active: Int?
    var position: Int?
    var index: Int?
    var appType: Int?
    
}


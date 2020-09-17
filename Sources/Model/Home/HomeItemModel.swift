//  File name   : HomeItemModel.swift
//
//  Author      : Dung Vu
//  Created date: 8/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

enum VatoHomeSectionLandingType: String, Codable {
    case horizontal = "HORIZONTAL_LIST"
    case carousel = "CAROUSEL"
    case vertical = "VERTICAL_LIST"
    case bannerList = "BANNER_LIST"
}

struct PagingHome: PagingNextProtocol {
    static var `default`: PagingHome = PagingHome(page: -1, canRequest: true, size: 10)
    
    var page: Int
    var size: Int
    var canRequest: Bool
    
    var first: Bool {
        return page < 0
    }
    
    init(page: Int, canRequest: Bool, size: Int) {
        self.page = page
        self.size = size
        self.canRequest = canRequest
    }
}

struct VatoHomeLandingItemSection: Codable, Comparable {
    var id: String
    var name: String?
    var position: Int
    var screen_source: String?
    var title: String?
    var type: VatoHomeSectionLandingType?
    var status: Bool
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        position = try values.decode(Int.self, forKey: .position)
        screen_source = try values.decodeIfPresent(String.self, forKey: .screen_source)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        type = try values.decodeIfPresent(VatoHomeSectionLandingType.self, forKey: .type)
        if let active = try? values.decode(Bool.self, forKey: .status) {
            status = active
        } else {
            let active = try values.decode(String.self, forKey: .status)
            status = active == "ACTIVE"
        }
    }
    
    init(id: String, position: Int, status: Bool) {
        self.id = id
        self.position = position
        self.status = status
    }
    
    static func ==(lhs: VatoHomeLandingItemSection, rhs: VatoHomeLandingItemSection) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func <(lhs: VatoHomeLandingItemSection, rhs: VatoHomeLandingItemSection) -> Bool {
        return lhs.position == rhs.position
    }
}

struct BusLineHomeItem: Codable {
    var date: Date?
    var destCode: String?
    var destName: String?
    var originCode: String?
    var originName: String?
    var page: Int?
    var service_ids: [Int]?
    var valid: Bool {
        return originCode?.isEmpty == false && destCode?.isEmpty == false
    }
    
    enum CodingKeys: String, CodingKey {
        case date
        case destCode
        case destName
        case originCode
        case originName
        case page
        case service_ids
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let str = try values.decodeIfPresent(String.self, forKey: .date) {
            let format = DateFormatter()
            format.dateFormat = "dd-MM-yyyy"
            date = format.date(from: str)
        }
        destCode = try values.decodeIfPresent(String.self, forKey: .destCode)
        destName = try values.decodeIfPresent(String.self, forKey: .destName)
        originCode = try values.decodeIfPresent(String.self, forKey: .originCode)
        originName = try values.decodeIfPresent(String.self, forKey: .originName)
        
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        service_ids = try values.decodeIfPresent([Int].self, forKey: .service_ids)
    }
    
    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        try values.encodeIfPresent(destCode, forKey: .destCode)
        try values.encodeIfPresent(destName, forKey: .destName)
        try values.encodeIfPresent(originCode, forKey: .originCode)
        try values.encodeIfPresent(originName, forKey: .originName)
        try values.encodeIfPresent(page, forKey: .page)
        try values.encodeIfPresent(service_ids, forKey: .service_ids)
        
        let s = date?.string(from: "dd-MM-yyyy")
        try values.encodeIfPresent(s, forKey: .date)
    }
}

struct VatoHomeLandingItem: Codable, Equatable, ImageDisplayProtocol {
    struct Action: Codable {
        enum TargetScreen: String, Codable {
            case topup = "VATOPAY_TOPUP"
            case ridingBook = "RIDING_BOOKING"
            case delivery = "DELIVERY_BOOKING"
            case busline = "VATO_BUSLINE_TICKET"
            case ecomHome = "ECOM_HOME"
            case promotion = "PROMOTION"
            case webViewLocal = "WEB_VIEW"
            case webViewBrowser = "WEB_BROWSER"
        }
        
        enum ActionType: String, Codable {
            case open = "OPEN"
            case view = "VIEW"
            case view_web = "VIEW_WEB"
            case open_web = "OPEN_WEB"
            case popup = "POPUP"
        }
        
        struct Data: Codable {
            var service_ids: [Int]?
            var payment_method: Int?
            var category_id: Int?
            var store_id: Int?
            var code: String?
            var url: String?
            var title: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case action_type
            case data
            case target_screen
        }
        
        var action_type: ActionType?
        var data: Data?
        var target_screen: TargetScreen?
        var buslineItem: BusLineHomeItem?
        var coordinate: Coordinate?
        
        var distance: String? {
            guard let c = coordinate, let current = VatoLocationManager.shared.location else {
                return nil
            }
            let d = abs(current.distance(from: c.location)) / 1000
            return String(format: "%.1fkm", d)
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            action_type = try values.decodeIfPresent(ActionType.self, forKey: .action_type)
            target_screen = try values.decodeIfPresent(TargetScreen.self, forKey: .target_screen)
            data = try values.decodeIfPresent(Data.self, forKey: .data)
            
            if let buslineItem = try? values.decode(BusLineHomeItem.self, forKey: .data), buslineItem.valid {
                self.buslineItem = buslineItem
                return
            }
            
            if let coordinate = try? values.decode(Coordinate.self, forKey: .data) {
                self.coordinate = coordinate
                return
            }
            
        }
        
        func encode(to encoder: Encoder) throws {
            var values = encoder.container(keyedBy: CodingKeys.self)
            try values.encodeIfPresent(action_type, forKey: .action_type)
            try values.encodeIfPresent(target_screen, forKey: .target_screen)
            try values.encodeIfPresent(data, forKey: .data)
        }
    }
    
    let id: String
    let action: Action
    var image: String?
    var name: String?
    let section_id: String
    let status: Bool
    let position: Int
    var subtitle: String?
    var title: String?
    
    var imageURL: String? {
        return image
    }
    
    var cacheLocal: Bool {
        return true
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        position = try values.decode(Int.self, forKey: .position)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        action = try values.decode(Action.self, forKey: .action)
        subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
        section_id = try values.decode(String.self, forKey: .section_id)
        if let active = try? values.decode(Bool.self, forKey: .status) {
            status = active
        } else {
            let active = try values.decode(String.self, forKey: .status)
            status = active == "ACTIVE"
        }
    }
    
    static func ==(lhs: VatoHomeLandingItem, rhs: VatoHomeLandingItem) -> Bool {
        return lhs.id == rhs.id
    }
}

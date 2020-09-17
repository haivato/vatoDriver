//
//  TaxiDummyData.swift
//  FC
//
//  Created by vato. on 2/20/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

struct TaxiModel: TaxiOperationDisplay {
    var id: Int?
    var operator_name: String?
    var reason: String?
    var stationName: String?
    var stationId: Int?
    var type: TaxiModelDisplayType?
    var address: TOPickupLocation.Address?
    var distance: String?
    var orderNumber: Int?
    var queue: String?
    var firestore_listener_path : String?
    var expired_at: Double?
    var created_at: Double?
    
    init(eventModel: TOPickupInvitation, type: TaxiModelDisplayType) {
        self.id = eventModel.id
        self.type = type
        self.reason = eventModel.reason_description
        self.stationName = eventModel.pickup_station_name
        self.stationId = eventModel.pickup_station_id
        self.expired_at = eventModel.expired_at
        self.distance = eventModel.distanceStr
        self.created_at = eventModel.created_at
    }
    
    init(station: TOPickupLocation, type: TaxiModelDisplayType) {
        self.id = station.id
        self.stationName = station.name
        self.stationId = station.id
        self.type = type
        self.orderNumber = station.order_number
        self.firestore_listener_path = station.firestore_listener_path
        self.created_at = station.created_at
        self.address = station.address
        self.distance = station.distance
    }
    
    init(notify: NotifyTaxi, type: TaxiModelDisplayType) {
        self.id = notify.payload?.id
        self.operator_name = notify.payload?.operator_name
        self.reason = notify.payload?.reason
        self.stationName = notify.payload?.pickupStationName
        self.stationId = notify.payload?.pickupStationId
        self.type = type
        self.firestore_listener_path = notify.payload?.firestore_listener_path
        self.expired_at = notify.expired_at
     }
}

struct TaxiDummyData {
    static func dummyData() -> [TaxiOperationDisplay] {
        return [
            /*
            TaxiModel(id: 1, operator_name: "", reason: "", stationName: "Bệnh viện chợ rẫy", type: .none),
            TaxiModel(id: 3, operator_name: "Lương Thị Bích Trâm", reason: "Vị trí tài xế ở quá xa điểm tiếp thị. ", stationName: "Bến xe miền đông", type: .reject),
            TaxiModel(id: 4, operator_name: "", reason: "", stationName: "Takashimaja", type: .invited),
            TaxiModel(id: 5, operator_name: "", reason: "", stationName: "Sân bay tân sơn nhất", type: .watingResponse),
            TaxiModel(id: 2, operator_name: "", reason: "", stationName: "Sư vạn hạnh Mall", type: .none),
            TaxiModel(id: 6, operator_name: "", reason: "", stationName: "Bến nhà rồng", type: .none),
            TaxiModel(id: 7, operator_name: "", reason: "", stationName: "Nhà hàng Hoàng kim", type: .none)
         */
        ]
    }
}



struct Payload: Decodable {
    var id: Int?
    var operator_name: String?
    var reason: String?
    var pickupStationId: Int?
    var orderNumber: Int?
    var pickupStationName: String?
    var firestore_listener_path: String?
    var status: TaxiRequestAction?
}

struct NotifyTaxi: Decodable {
    
    var action: TaxiRequestAction?
    var expired_at: Double?
    var type: TaxiEnqueueType?
    var id: Int?
    let payload: Payload?
    
    static func ==(lhs: NotifyTaxi, rhs: NotifyTaxi) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isExpire() -> Bool {
        guard let expired_at = expired_at else { return false}
        return FireBaseTimeHelper.default.currentTime > expired_at
    }
}




//
//  ActiveFavoriteModeModel.swift
//  FC
//
//  Created by vato. on 7/24/19.
//  Copyright © 2019 Vato. All rights reserved.
//

//https://developer.apple.com/swift/blog/?id=37
import Foundation


class ActiveFavoriteModeModel : NSObject {
    var id: Int64?
    var numberActiveInDay: Int64?
    var maxActiveInDay: Int64?
    var isActive: Bool = false
    var placeId: Int64?
    var namePlace: String?
    var addressPlace: String?
    var placeTypeId: FavoritePlaceType = .Orther
    
    @objc func getID() -> Int64 {
        return self.id ?? -1
    }
    
    @objc func getNumberActiveInDay() -> Int64 {
        return self.numberActiveInDay ?? 0
    }
    
    @objc func getMaxActiveInDay() -> Int64 {
        return self.maxActiveInDay ?? 0
    }
    
    @objc func getNamePlace() -> String {
        return self.namePlace ?? ""
    }
    
    @objc func getAddressPlace() -> String {
        return self.addressPlace ?? ""
    }
    
    @objc func getIsActive() -> Bool {
        return self.isActive
    }
    
    @objc func getIconName() -> String {
        return self.placeTypeId.getIconName()
    }
    
    static func create(json: [String: Any]?) -> ActiveFavoriteModeModel? {
        if let json = json {
            let model = ActiveFavoriteModeModel()
            model.numberActiveInDay = json["numberOfActive"] as? Int64 ?? 0
            model.maxActiveInDay = json["numberOfMaxActive"] as? Int64 ?? 0
            model.isActive = json["isActive"] as? Bool ?? false
            if let placeJson = json["place"] as? [String: Any] {
                model.namePlace = placeJson["name"] as? String ?? ""
                model.addressPlace = placeJson["address"] as? String ?? ""
                let typeID =  placeJson["typeId"] as? Int ?? 3
                model.placeTypeId = FavoritePlaceType(rawValue: typeID) ?? .Orther
                model.placeId = placeJson["id"] as? Int64 ?? 0
            }
            if let historyJson = json["history"] as? [String: Any] {
                model.id = historyJson["id"] as? Int64 ?? 0
            }
            
            return model
        }
        return nil
    }
}

struct ResponseManager {
    var isSuccess: Bool?
    var error: NSError?
    var data: [String: Any]?
    
    static func create(data: Data?) -> ResponseManager? {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        
//        if let status = json?["status"] as? Int64 {
            //            if status < 200 || status >= 300,
            if let message = json?["message"] as? String,
                message.count > 0,
                message != "OK"{
                var responseManager = ResponseManager()
                responseManager.error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: message])
                responseManager.data = json?["data"] as? [String: Any]
                responseManager.isSuccess = false
                return responseManager
            }
//        }
        var responseManager = ResponseManager()
        responseManager.error = nil
        responseManager.data = json?["data"] as? [String: Any]
        responseManager.isSuccess = true
        return responseManager
    }
}


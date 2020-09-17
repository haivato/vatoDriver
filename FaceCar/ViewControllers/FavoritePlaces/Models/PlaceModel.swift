//
//  PlaceModel.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

enum FavoritePlaceType: Int, Codable {
    case Home = 1
    case Work = 2
    case Orther = 3
    case AddNew = 4
    
    func getIconName() -> String {
        switch self {
        case .Home:
            return "iconBookingHome"
        case .Work:
            return "iconBookingWork"
        case .Orther:
            return "iconBookingPlaceSaved"
        case .AddNew:
            return "iconBookingPlaceSavedOrange"
        }
    }
}


struct PlaceModel: Codable {
    var id: Int64?
    var name: String?
    var address: String?
    var typeId: FavoritePlaceType
    
    var lat: String?
    var lon: String?
    
    func getIconName() -> String {
        return self.typeId.getIconName()
    }
    
    func getName() -> String? {
        switch self.typeId {
        case .Home:
            return Text.home.localizedText
        case .Work:
            return Text.workNoun.localizedText
        case .Orther:
            return self.name
        case .AddNew:
            return "Địa điểm yêu thích"
        }
    }
    
    static func generateModel(listModelBackend: [PlaceModel]?) -> [PlaceModel] {
        let listDefautNotOther = [
            PlaceModel(id: nil, name: "Home", address: nil, typeId: .Home, lat: nil, lon: nil),
            PlaceModel(id: nil, name: "Work", address: nil, typeId: .Work, lat: nil, lon: nil)
        ]
        
        
        guard let listModelBackend = listModelBackend else { return listDefautNotOther }
        
        
        var result = [PlaceModel]()
        var homeModel = PlaceModel(id: nil, name: "Home", address: nil, typeId: .Home, lat: nil, lon: nil)
        var workModel = PlaceModel(id: nil, name: "Work", address: nil, typeId: .Work, lat: nil, lon: nil)
        
        listModelBackend.forEach { (model) in
            if model.typeId == .Home {
                homeModel = model
            } else if model.typeId == .Work {
                workModel = model
            } else {
                result.append(model)
            }
        }
        result.insert(workModel, at: 0)
        result.insert(homeModel, at: 0)
        return result
    }
}

extension PlaceModel {
    init(from active: ActiveFavoriteModeModel) {
        self.id = active.id
        self.name = active.namePlace
        self.address = active.addressPlace
        self.typeId = active.placeTypeId
    }
    //ActiveFavoriteModeModel
}




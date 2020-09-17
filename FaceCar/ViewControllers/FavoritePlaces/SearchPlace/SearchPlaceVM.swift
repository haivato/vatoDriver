//
//  UpdatePlaceVM.swift
//  Vato
//
//  Created by vato. on 7/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

struct SearchPlaceVM {
     var listModelFavorite = [PlaceModel]()
    private var listSection = [FavoritePlaceSection.Fav]
    
    func generateUpdateViewModel(indexPath: IndexPath?) -> UpdatePlaceVM? {
        if let indexPath = indexPath,
            let model = getModel(at: indexPath) {
            let updatePlaceVM = UpdatePlaceVM(model: model)
            return updatePlaceVM
        }
        let placeModel = PlaceModel(id: nil, name: nil, address: nil, typeId: .Orther, lat: nil, lon: nil)
        return UpdatePlaceVM(model: placeModel)
    }
    
    // MARK: - Process Data
    
    mutating func getData() {
        self.listModelFavorite = PlaceModel.generateModel(listModelBackend: nil)
    }
    
     func getModel(at indexPath: IndexPath) -> PlaceModel? {
        let sectionType = self.listSection[indexPath.section]
        switch sectionType {
        case .Fav:
            return self.listModelFavorite[indexPath.row]
        case .Other:
            return nil
        }
    }
    
    func getNumberRow(section: Int) -> Int {
        let sectionType = self.listSection[section]
        switch sectionType {
        case .Fav:
            return self.listModelFavorite.count
        case .Other:
            return 0
        }
    }
    
    func getNumberSection() -> Int {
        return self.listSection.count
    }
    
    func getHeaderText(section: Int) -> String {
        let sectionType = self.listSection[section]
        return sectionType.getText()
    }
    
    func generateShowPlaceVM() -> ShowPlaceVM {
        return ShowPlaceVM()
    }
    
    
    
}

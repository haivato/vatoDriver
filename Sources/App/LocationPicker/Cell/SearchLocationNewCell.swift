//
//  SearchLocationNewCell.swift
//  Vato
//
//  Created by khoi tran on 11/13/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class SearchLocationNewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func updateData(model: AddressProtocol, typeLocationPicker: LocationPickerDisplayType) {
//        let favList = FavoritePlaceManager.shared.source
//        let name = model.name ?? ""
        
//        FindFav: do { let coordinate = model.coordinate
//            let i = favList.first { (i) -> Bool in
//                guard let lat = Double(i.lat ?? ""), let lon = Double(i.lon ?? "") else {
//                    return false
//                }
//                if lat == 0 && lon == 0 {
//                    return false
//                }
//
//                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//                let distance = abs(coordinate.distance(to: location))
//                let result = distance <= 55
//                return result
//            }
//
//            let fav = i?.name ?? ""
//            self.nameLabel.text = !fav.isEmpty ? fav : name
//        }
        
        self.nameLabel.text = model.name ?? ""
        self.addressLabel.text = model.subLocality.isEmpty ? "  " : model.subLocality
        
        if let distance = model.distance {
            let km = distance / 1000
            let text = String(format: "%.1f km", km)
            self.distanceLabel.text = text
            
        } else {
            if let current = VatoLocationManager.shared.location {
                let coor = model.coordinate
                if (coor != kCLLocationCoordinate2DInvalid) && (coor.latitude != 0 && coor.longitude != 0) {
                    let d = current.coordinate.distance(to: coor)
                    let km = d / 1000
                    let text = String(format: "%.1f km", km)
                    self.distanceLabel.text = text
                } else {
                    self.distanceLabel.text = "--"
                }
            } else {
                self.distanceLabel.text = "--"
            }
        }
        
        if model.isDatabaseLocal {
            if model.counter > 100 {
                self.counterLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                self.counterLabel.text = "99+"
            } else {
                self.counterLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                self.counterLabel.text = "\(model.counter)"
            }
            
        }
        switch typeLocationPicker {
        case .updatePlaceMode:
            self.addButton.isHidden = true
            self.counterLabel.isHidden = false
        case .full:
            self.addButton.isHidden = model.isDatabaseLocal
            self.counterLabel.isHidden = !model.isDatabaseLocal
        }
    }
    
}

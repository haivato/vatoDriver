//
//  VatoLocationHeaderView.swift
//  Vato
//
//  Created by khoi tran on 11/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import CoreLocation

class VatoLocationHeaderView: UIView, UpdateDisplayProtocol {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnSearchAddress: UIButton?
    @IBOutlet weak var mapLabel: UILabel!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//        titleLabel.text = Text.yourLocation.localizedText
//        mapLabel.text = Text.map.localizedText
//    }

    
    
    func setupDisplay(item: AddressProtocol?) {
//        let favList = FavoritePlaceManager.shared.source
//        var name = item?.name ?? ""
//        name = name == Text.unnamedRoad.localizedText ? "Vị Trí Đang Ghim" : name
//
//        FindFav: if let coordinate = item?.coordinate {
//            let i = favList.first { (i) -> Bool in
//                guard let lat = Double(i.lat ?? ""), let lon = Double(i.lon ?? "") else {
//                    return false
//                }
//                if lat  == 0 && lon == 0 {
//                    return false
//                }
//                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//                let distance = abs(coordinate.distance(to: location))
//                let result = distance <= 55
//                return result
//            }
//
//            let fav = i?.name ?? ""
//            nameLabel.text = !fav.isEmpty ? fav : name
//        } else {
//            nameLabel.text = name
//        }
    }
}

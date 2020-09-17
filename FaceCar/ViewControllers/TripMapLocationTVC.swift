//
//  TripMapLocationTVC.swift
//  FC
//
//  Created by khoi tran on 3/23/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

struct TripMapAddress: AddressProtocol {
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var thoroughfare: String = ""
    var streetNumber: String = ""
    var streetName: String = ""
    var locality: String = ""
    var subLocality: String
    var administrativeArea: String = ""
    var postalCode: String = ""
    var country: String = ""
    var lines: [String] = []
    var isDatabaseLocal: Bool = false
    var hashValue: Int = 1
    var zoneId: Int = 0    
    var favoritePlaceID: Int64 = 0
    var isOrigin: Bool
    var counter: Int = 0
    var placeId: String?
    var distance: Double?
    
    func increaseCounter() {}
    func update(isOrigin: Bool) {}
    func update(zoneId: Int) {}
    func update(placeId: String?) {}
    func update(coordinate: CLLocationCoordinate2D?) {}
    
    init(coordinate: CLLocationCoordinate2D, name: String?, subLocality: String, isOrigin: Bool) {
        self.coordinate = coordinate
        self.name = name
        self.subLocality = subLocality
        self.isOrigin = isOrigin
    }
}


struct TripMapLocationModel: TripMapLocationDisplay {
    var isOrigin: Bool
    let locationName: String?
    let locationAddress: String?
    let address: AddressProtocol?
    
    
    static func initStartLocation(bookInfo: FCBookInfo) -> TripMapLocationModel {
        
        let address = TripMapAddress(coordinate: CLLocationCoordinate2D(latitude: bookInfo.startLat, longitude: bookInfo.startLon), name: bookInfo.startName, subLocality: bookInfo.startAddress, isOrigin: true)
        return TripMapLocationModel(isOrigin: true, locationName: bookInfo.startName, locationAddress: bookInfo.startAddress, address: address)
    }
    
    
    static func initDestinationLocation(bookInfo: FCBookInfo) -> TripMapLocationModel? {
        guard let endAddress: String = bookInfo.endAddress else {
            return nil
        }
        
        if (bookInfo.endLat == 0 && bookInfo.endLon == 0) {
            return nil
        }
                
        let address = TripMapAddress(coordinate: CLLocationCoordinate2D(latitude: bookInfo.endLat, longitude: bookInfo.endLon), name: bookInfo.endName ?? "", subLocality: endAddress, isOrigin: false)
        return TripMapLocationModel(isOrigin: false, locationName: bookInfo.endName ?? "", locationAddress: endAddress, address: address)
    }
    
    init(isOrigin: Bool, locationName: String?, locationAddress: String?, address: AddressProtocol?) {
        self.isOrigin = isOrigin
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.address = address
    }
    

    init(address: AddressProtocol) {
        self.isOrigin = address.isOrigin
        self.locationName = address.name
        self.locationAddress = address.subLocality
        
        self.address = address
    }
    
    static func initLocations(addDestinationTripInfo: AddDestinationTripInfo) -> [TripMapLocationModel] {
        guard let trip = addDestinationTripInfo.trip  else {
            return []
        }
        
        
        return trip.getAddresses().map { TripMapLocationModel.init(address: $0) }
    }
}


protocol TripMapLocationDisplay  {
    var isOrigin: Bool { get }
    var locationName: String? { get }
    var locationAddress: String? { get }
    var address: AddressProtocol? { get }
}



class TripMapLocationTVC: UITableViewCell, UpdateDisplayProtocol {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var imvType: UIImageView!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var imvDot: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
        
    func setupDisplay(item: TripMapLocationDisplay?) {
        guard let item = item else { return }
        self.lblName.text = item.locationName
        self.lblAddress.text = item.locationAddress
        self.imvType.image = item.isOrigin ? UIImage(named: "iconBookingPickup") : UIImage(named: "iconBookingDestination")
        
        
    }
    
    func updateDisplay(isAllowEdit: Bool, isAllowAddNew: Bool, viewDotHidden: Bool) {
        self.btnEdit.isHidden = !isAllowEdit
        self.btnAdd.isHidden = !isAllowAddNew
        self.imvDot.isHidden = viewDotHidden
    }
    
}

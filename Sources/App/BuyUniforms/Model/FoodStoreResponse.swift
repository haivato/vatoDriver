/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import CoreLocation
import Kingfisher

struct FoodStoreItem : Codable, DisplayShortDescriptionProtocol {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : Int?
	var name : String?
	let address : String?
	var lat : Double?
	var lon : Double?
	let bannerImage : [String]?
	let otherImage : [String]?
	let phoneNumber : String?
	var workingHours : WorkingHoursType?
	let status : Int?
	let zoneName : String?
	let zoneId : Int?
	let urlRefer : String?
    
    let infoStoreVerify: StoreInfoVerify?
    
    var valid: Bool {
        return status == 4
    }

    var imageURL: String? {
        return bannerImage?.first
    }
    
    var descriptionCat: String? {
        return nil
    }

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case name = "name"
		case address = "address"
		case lat = "lat"
		case lon = "lon"
		case bannerImage = "bannerImage"
		case otherImage = "otherImage"
		case phoneNumber = "phoneNumber"
		case workingHours = "workingHours"
		case status = "status"
		case zoneName = "zoneName"
		case zoneId = "zoneId"
		case urlRefer = "urlRefer"
        case infoStoreVerify
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		lat = try values.decodeIfPresent(Double.self, forKey: .lat)
		lon = try values.decodeIfPresent(Double.self, forKey: .lon)
		bannerImage = try values.decodeIfPresent([String].self, forKey: .bannerImage)
		otherImage = try values.decodeIfPresent([String].self, forKey: .otherImage)
		phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
		workingHours = try values.decodeIfPresent(WorkingHoursType.self, forKey: .workingHours)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		zoneName = try values.decodeIfPresent(String.self, forKey: .zoneName)
		zoneId = try values.decodeIfPresent(Int.self, forKey: .zoneId)
		urlRefer = try values.decodeIfPresent(String.self, forKey: .urlRefer)
        infoStoreVerify = try values.decodeIfPresent(StoreInfoVerify.self, forKey: .infoStoreVerify)
	}
}

struct FoodStoreResponse : Codable, ResponsePagingProtocol {
    var listStore: [FoodExploreItem]?
    
    var items: [FoodExploreItem]? {
        return listStore
    }
    
    var next: Bool {
        guard let idx = indexPage, let total = totalPage  else {
            return false
        }
        
        return idx < total
    }
    
    var indexPage: Int?
    var totalPage: Int?
}

struct FoodSearchStoreResponse : Codable {
    var listStore: [FoodExploreItem]?
    var next: Bool
    
    enum CodingKeys: String, CodingKey {
        case listStore = "data"
        case next
    }
}

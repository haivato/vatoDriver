

import Foundation
struct MerchantCategoryBase : Codable {
	let id : Int?
	let name : String?
	let children : [MerchantCategory]?
	let catImage : [String]?
	let status : Int?
	let parentId : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case children = "children"
		case catImage = "catImage"
		case status = "status"
		case parentId = "parentId"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		children = try values.decodeIfPresent([MerchantCategory].self, forKey: .children)
		catImage = try values.decodeIfPresent([String].self, forKey: .catImage)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		parentId = try values.decodeIfPresent(Int.self, forKey: .parentId)
	}

}

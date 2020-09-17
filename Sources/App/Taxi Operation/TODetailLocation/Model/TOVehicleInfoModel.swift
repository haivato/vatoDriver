/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct TOVehicleInfoModel : Codable {
	let id : Int64?
	let type : Int?
	let rank : Int?
	let plate : String?
	let color : String?
	let brand : String?
	let image : String?
	let active : Bool?
	let taxi : Bool?
	let express : Bool?
	let food : Bool?
	let user_id : Int?
	let market_name : String?
	let taxi_brand : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case type = "type"
		case rank = "rank"
		case plate = "plate"
		case color = "color"
		case brand = "brand"
		case image = "image"
		case active = "active"
		case taxi = "taxi"
		case express = "express"
		case food = "food"
		case user_id = "user_id"
		case market_name = "market_name"
		case taxi_brand = "taxi_brand"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int64.self, forKey: .id)
		type = try values.decodeIfPresent(Int.self, forKey: .type)
		rank = try values.decodeIfPresent(Int.self, forKey: .rank)
		plate = try values.decodeIfPresent(String.self, forKey: .plate)
		color = try values.decodeIfPresent(String.self, forKey: .color)
		brand = try values.decodeIfPresent(String.self, forKey: .brand)
		image = try values.decodeIfPresent(String.self, forKey: .image)
		active = try values.decodeIfPresent(Bool.self, forKey: .active)
		taxi = try values.decodeIfPresent(Bool.self, forKey: .taxi)
		express = try values.decodeIfPresent(Bool.self, forKey: .express)
		food = try values.decodeIfPresent(Bool.self, forKey: .food)
		user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
		market_name = try values.decodeIfPresent(String.self, forKey: .market_name)
		taxi_brand = try values.decodeIfPresent(Int.self, forKey: .taxi_brand)
	}

}

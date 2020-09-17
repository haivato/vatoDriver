/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct TOPermissions : Codable {
	let id : Int?
	let role : String?
	let active : Bool?
	let created_by : Int?
	let updated_by : Int?
	let created_at : Double?
	let updated_at : Double?
	let pickup_station_id : Int?
	let user_id : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case role = "role"
		case active = "active"
		case created_by = "created_by"
		case updated_by = "updated_by"
		case created_at = "created_at"
		case updated_at = "updated_at"
		case pickup_station_id = "pickup_station_id"
		case user_id = "user_id"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		role = try values.decodeIfPresent(String.self, forKey: .role)
		active = try values.decodeIfPresent(Bool.self, forKey: .active)
		created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
		updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
		created_at = try values.decodeIfPresent(Double.self, forKey: .created_at)
		updated_at = try values.decodeIfPresent(Double.self, forKey: .updated_at)
		pickup_station_id = try values.decodeIfPresent(Int.self, forKey: .pickup_station_id)
		user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
	}

}

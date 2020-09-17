/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct TOPickupStation : Codable {
	let id : Int?
	let name : String?
	let address : TOAddress?
	let radius : Int?
	let created_by : Int?
	let updated_by : Int?
	let created_at : Double?
	let updated_at : Double?
	let max_ready : Int?
	let max_queue : Int?
	let available_slot : Int?
	let request_time : Int?
	let register_expired_in : Int?
	let invite_expired_in : Int?
	let permissions : [TaxiPermisson]?
	let firestore_listener_path : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case address = "address"
		case radius = "radius"
		case created_by = "created_by"
		case updated_by = "updated_by"
		case created_at = "created_at"
		case updated_at = "updated_at"
		case max_ready = "max_ready"
		case max_queue = "max_queue"
		case available_slot = "available_slot"
		case request_time = "request_time"
		case register_expired_in = "register_expired_in"
		case invite_expired_in = "invite_expired_in"
		case permissions = "permissions"
		case firestore_listener_path = "firestore_listener_path"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		address = try values.decodeIfPresent(TOAddress.self, forKey: .address)
		radius = try values.decodeIfPresent(Int.self, forKey: .radius)
		created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
		updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
		created_at = try values.decodeIfPresent(Double.self, forKey: .created_at)
		updated_at = try values.decodeIfPresent(Double.self, forKey: .updated_at)
		max_ready = try values.decodeIfPresent(Int.self, forKey: .max_ready)
		max_queue = try values.decodeIfPresent(Int.self, forKey: .max_queue)
		available_slot = try values.decodeIfPresent(Int.self, forKey: .available_slot)
		request_time = try values.decodeIfPresent(Int.self, forKey: .request_time)
		register_expired_in = try values.decodeIfPresent(Int.self, forKey: .register_expired_in)
		invite_expired_in = try values.decodeIfPresent(Int.self, forKey: .invite_expired_in)
		permissions = try values.decodeIfPresent([TaxiPermisson].self, forKey: .permissions)
		firestore_listener_path = try values.decodeIfPresent(String.self, forKey: .firestore_listener_path)
	}

}

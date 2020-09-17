/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct TaxiPermisson : Codable {
	let id : Int?
	let created_by : Int?
	let updated_by : Int?
	let full_name : String?
	let nickname : String?
	let avatar_url : String?
	let firebase_id : String?
	let admin_zone_id : Int?
	let type : Int?
	let card_id : Int?
	let phone : String?
	let original_phone : String?
	let email : String?
	let birthday : String?
	let device_token : String?
	let app_version : String?
	let zone_id : Int?
	let sub_zone_id : Int?
	let level : Int?
	let active : Bool?
	let personal_document : Int?
	let organization : TOOrganization?
	let pickup_station : TOPickupStation?
	let user_permissions : [TOUserPermissions]?
	let driver_group : TODriverGroup?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case created_by = "created_by"
		case updated_by = "updated_by"
		case full_name = "full_name"
		case nickname = "nickname"
		case avatar_url = "avatar_url"
		case firebase_id = "firebase_id"
		case admin_zone_id = "admin_zone_id"
		case type = "type"
		case card_id = "card_id"
		case phone = "phone"
		case original_phone = "original_phone"
		case email = "email"
		case birthday = "birthday"
		case device_token = "device_token"
		case app_version = "app_version"
		case zone_id = "zone_id"
		case sub_zone_id = "sub_zone_id"
		case level = "level"
		case active = "active"
		case personal_document = "personal_document"
		case organization = "organization"
		case pickup_station = "pickup_station"
		case user_permissions = "user_permissions"
		case driver_group = "driver_group"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		created_by = try values.decodeIfPresent(Int.self, forKey: .created_by)
		updated_by = try values.decodeIfPresent(Int.self, forKey: .updated_by)
		full_name = try values.decodeIfPresent(String.self, forKey: .full_name)
		nickname = try values.decodeIfPresent(String.self, forKey: .nickname)
		avatar_url = try values.decodeIfPresent(String.self, forKey: .avatar_url)
		firebase_id = try values.decodeIfPresent(String.self, forKey: .firebase_id)
		admin_zone_id = try values.decodeIfPresent(Int.self, forKey: .admin_zone_id)
		type = try values.decodeIfPresent(Int.self, forKey: .type)
		card_id = try values.decodeIfPresent(Int.self, forKey: .card_id)
		phone = try values.decodeIfPresent(String.self, forKey: .phone)
		original_phone = try values.decodeIfPresent(String.self, forKey: .original_phone)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		birthday = try values.decodeIfPresent(String.self, forKey: .birthday)
		device_token = try values.decodeIfPresent(String.self, forKey: .device_token)
		app_version = try values.decodeIfPresent(String.self, forKey: .app_version)
		zone_id = try values.decodeIfPresent(Int.self, forKey: .zone_id)
		sub_zone_id = try values.decodeIfPresent(Int.self, forKey: .sub_zone_id)
		level = try values.decodeIfPresent(Int.self, forKey: .level)
		active = try values.decodeIfPresent(Bool.self, forKey: .active)
		personal_document = try values.decodeIfPresent(Int.self, forKey: .personal_document)
		organization = try values.decodeIfPresent(TOOrganization.self, forKey: .organization)
		pickup_station = try values.decodeIfPresent(TOPickupStation.self, forKey: .pickup_station)
		user_permissions = try values.decodeIfPresent([TOUserPermissions].self, forKey: .user_permissions)
		driver_group = try values.decodeIfPresent(TODriverGroup.self, forKey: .driver_group)
	}

}

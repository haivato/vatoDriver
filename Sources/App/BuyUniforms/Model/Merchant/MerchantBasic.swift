
import Foundation
struct MerchantBasic : Codable {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : Int?
	let name : String?
	let shortDescription : String?
	let description : String?
	let phoneNumber : String?
	let status : Int?
	let reasonApproved : String?
	let ownerId : Int?
	let version : Int?
    let avatarUrl: String?

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case name = "name"
		case shortDescription = "shortDescription"
		case description = "description"
		case phoneNumber = "phoneNumber"
		case status = "status"
		case reasonApproved = "reasonApproved"
		case ownerId = "ownerId"
		case version = "version"
        case avatarUrl = "avatarUrl"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		shortDescription = try values.decodeIfPresent(String.self, forKey: .shortDescription)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		reasonApproved = try values.decodeIfPresent(String.self, forKey: .reasonApproved)
		ownerId = try values.decodeIfPresent(Int.self, forKey: .ownerId)
		version = try values.decodeIfPresent(Int.self, forKey: .version)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
	}

}

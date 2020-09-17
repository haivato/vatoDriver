import Foundation

struct Tree<T>: Comparable where T: Hashable, T: Comparable, T: Equatable  {
    static func < (lhs: Tree<T>, rhs: Tree<T>) -> Bool {
        return lhs.key < rhs.key
    }
    
    var key: T
    var child: [T: Tree<T>]?
    
    func listChild() -> [Tree<T>]? {
        guard let child = child else {
            return nil
        }
    
        let results = child.compactMap({ $0.value }).sorted(by: <)
        
        return results
       
    }
}

protocol TreeProrocol {
    associatedtype T:Hashable, Comparable
    func toTree() -> Tree<T>
}

protocol CategoryDisplayItemView {
    var name: String? { get }
    var id: Int? { get }
}

struct MerchantCategory : Codable, Hashable, TreeProrocol, Comparable, CategoryDisplayItemView, Equatable {
    
    static func < (lhs: MerchantCategory, rhs: MerchantCategory) -> Bool {
        let lId = lhs.id ?? 0
        let rId = rhs.id ?? 0
        
        return lId < rId
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : Int?
	let name : String?
	let children : [MerchantCategory]?
	let catImage : [String]?
	let toggled : Bool?
	let status : Int?
	let parentId : Int?
    let iconUrl: String?
    let ancestry: String?

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case name = "name"
		case children = "children"
		case catImage = "catImage"
		case toggled = "toggled"
		case status = "status"
		case parentId = "parentId"
        case iconUrl = "iconUrl"
        case ancestry = "ancestry"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		children = try values.decodeIfPresent([MerchantCategory].self, forKey: .children)
		catImage = try values.decodeIfPresent([String].self, forKey: .catImage)
		toggled = try values.decodeIfPresent(Bool.self, forKey: .toggled)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		parentId = try values.decodeIfPresent(Int.self, forKey: .parentId)
        iconUrl = try values.decodeIfPresent(String.self, forKey: .iconUrl)
        ancestry = try values.decodeIfPresent(String.self, forKey: .ancestry)
	}
    
    
    var hashValue: Int {
        return id ?? 0
    }
    
    
    func toTree() -> Tree<MerchantCategory> {
        var tree = Tree(key: self, child: nil)
        
        if let children = self.children?.compactMap({$0}), children.count > 0 {
            var child:[MerchantCategory: Tree<MerchantCategory>] = [:]
            for c in children {
                child[c] = c.toTree()
            }
            tree.child = child
        }
        
        return tree
    }
}

extension Array where Element == MerchantCategory {
    func getAncestryName() -> String {
        var temp = self
        temp.removeLast(2)
        let nameArray: [String] = temp.map{ $0.name ?? ""}.reversed()
        return nameArray.joined(separator: " -> ")
    }
}

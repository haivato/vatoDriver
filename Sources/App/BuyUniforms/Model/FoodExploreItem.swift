/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import KeyPathKit
import UIKit

enum FoodWeekDayType: String, Codable, CaseIterable {
    case mon = "2"
    case tue = "3"
    case wed = "4"
    case thu = "5"
    case fri = "6"
    case sat = "7"
    case sun = "8"

    var color: UIColor {
        switch self {
        case .mon:
            return #colorLiteral(red: 0.1803921569, green: 0.7960784314, blue: 0.8862745098, alpha: 1)
        case .tue:
            return #colorLiteral(red: 1, green: 0.5137254902, blue: 0.6078431373, alpha: 1)
        case .wed:
            return #colorLiteral(red: 0.9960784314, green: 0.7019607843, blue: 0.2666666667, alpha: 1)
        case .thu:
            return #colorLiteral(red: 0.3333333333, green: 0.6588235294, blue: 1, alpha: 1)
        case .fri:
            return #colorLiteral(red: 0.3098039216, green: 0.7529411765, blue: 0.4431372549, alpha: 1)
        case .sat:
            return #colorLiteral(red: 0.3764705882, green: 0.4274509804, blue: 1, alpha: 1)
        case .sun:
            return #colorLiteral(red: 0.1215686275, green: 0.6588235294, blue: 0.9921568627, alpha: 1)
        }
    }
    
    var colorUnselect: UIColor {
        switch self {
        case .mon:
            return #colorLiteral(red: 0.1803921569, green: 0.7960784314, blue: 0.8862745098, alpha: 0.15)
        case .tue:
            return #colorLiteral(red: 1, green: 0.5137254902, blue: 0.6078431373, alpha: 0.15)
        case .wed:
            return #colorLiteral(red: 0.9960784314, green: 0.7019607843, blue: 0.2666666667, alpha: 0.15)
        case .thu:
            return #colorLiteral(red: 0.3333333333, green: 0.6588235294, blue: 1, alpha: 0.15)
        case .fri:
            return #colorLiteral(red: 0.3098039216, green: 0.7529411765, blue: 0.4431372549, alpha: 0.15)
        case .sat:
            return #colorLiteral(red: 0.3764705882, green: 0.4274509804, blue: 1, alpha: 0.15)
        case .sun:
            return #colorLiteral(red: 0.1215686275, green: 0.6588235294, blue: 0.9921568627, alpha: 0.15)
        }
    }
    
    var colorBg: UIColor {
        switch self {
        case .mon:
            return #colorLiteral(red: 0.1803921569, green: 0.7960784314, blue: 0.8862745098, alpha: 0.06)
        case .tue:
            return #colorLiteral(red: 1, green: 0.5137254902, blue: 0.6078431373, alpha: 0.06)
        case .wed:
            return #colorLiteral(red: 0.9960784314, green: 0.7019607843, blue: 0.2666666667, alpha: 0.06)
        case .thu:
            return #colorLiteral(red: 0.3333333333, green: 0.6588235294, blue: 1, alpha: 0.06)
        case .fri:
            return #colorLiteral(red: 0.3098039216, green: 0.7529411765, blue: 0.4431372549, alpha: 0.06)
        case .sat:
            return #colorLiteral(red: 0.3764705882, green: 0.4274509804, blue: 1, alpha: 0.06)
        case .sun:
            return #colorLiteral(red: 0.1215686275, green: 0.6588235294, blue: 0.9921568627, alpha: 0.06)
        }
    }
    
    var name: String {
        switch self {
        case .sun:
            return "CN"
        default:
            return "Thu \(self.rawValue)"
        }
    }
    
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "vi_VN")
        return calendar
    }()
    
    static func today() -> FoodWeekDayType? {
        let components = calendar.component(.weekday, from: Date())
        return FoodWeekDayType(rawValue: "\(components)")
    }
}

struct FoodTimeWorking: Codable {
    var open: Int
    var close: Int
    
    var valid: Bool {
        return open >= 0 && open < close
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
//        let timeOpen = try values.decodeIfPresent(String.self, forKey: .open)
//        let timeClose = try values.decodeIfPresent(String.self, forKey: .close)
        self.open = try values.decodeIfPresent(Int.self, forKey: .open) ?? 0
        self.close = try values.decodeIfPresent(Int.self, forKey: .close) ?? 0
    }
    
    init(open: Int, close: Int) {
        self.open = open
        self.close = close
    }
    
    var stringValue: String {
        return self.minuteTimeToString(minute: open) + " - " + self.minuteTimeToString(minute: close)
    }
    
    func minuteTimeToString(minute: Int) -> String {
        let hours = Int(minute/60)
        let minutes = minute % 60
        
        let hoursString = hours < 10 ? "0\(hours)" : "\(hours)"
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"

        return hoursString + ":" + minutesString
    }
}

struct FoodWorkingWeekDay: Codable {
    private enum CodingKeys: String, CodingKey {
        case time
        case day
    }
    let day: FoodWeekDayType
    let time: FoodTimeWorking
    
    var opening: Bool {
        let current = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let h = current.hour ?? 0
        let m = current.minute ?? 0
        let total = h * 60 + m
        guard time.valid else { return false }
        let result = time.open...time.close ~= total
        return result
    }
    
    var openText: String {
        return opening ? "Mở cửa" : "Đóng cửa"
    }
    
    var color: UIColor {
        return opening ? #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 1) : #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
    }
    
    init(day: FoodWeekDayType, time: FoodTimeWorking) {
        self.day = day
        self.time = time
    }

}

struct FoodWorkingHours: Codable {
    
    var daily: [FoodWeekDayType: FoodWorkingWeekDay]?
    private var items: [FoodWorkingWeekDay]? {
        return daily?.lazy.map { $0.value }
    }
    
    var minOpen: Int {
        return items?.min(\.time.open) ?? 0
    }
    
    var maxOpen: Int {
        return items?.max(\.time.close) ?? 0
    }
    
    var range: ClosedRange<Int> {
        return minOpen...maxOpen
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let v = try values.decodeIfPresent([String: FoodTimeWorking].self, forKey: .daily) else {
            return
        }
        
        daily = v.reduce(into: [FoodWeekDayType: FoodWorkingWeekDay]()) { (r, element) in
            guard let key = FoodWeekDayType(rawValue: element.key) else {
                return
            }
            let item = FoodWorkingWeekDay(day: key, time: element.value)
            r[key] = item
        }
    }
    
    init() {

    }
    
    func getCloseTime() -> String {
                
        guard let today = FoodWeekDayType.today(),let working = daily?[today] else { return "" }
        
        return working.time.minuteTimeToString(minute: working.time.close)
    }
}
typealias WorkingHoursType = FoodWorkingHours
protocol DisplayShortDescriptionProtocol: ImageDisplayProtocol {
    var workingHours : WorkingHoursType? { get }
    var lat : Double? { get }
    var lon : Double? { get }
    var name : String? { get }
    var descriptionCat: String? { get }
    var infoStoreVerify: StoreInfoVerify? { get }
}

extension DisplayShortDescriptionProtocol {
    var coordinate: CLLocationCoordinate2D {
        guard let lat = self.lat, let lon = self.lon else {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct StoreInfoVerify : Codable, ImageDisplayProtocol {
    let createdBy : TimeInterval?
    let updatedBy : TimeInterval?
    let createdAt : TimeInterval?
    let updatedAt : TimeInterval?
    let id : Int?
    let urlImgAuth : String?
    let label : String?
    let typeAuth : String?
    let colorLabel: String?
    
    var color: UIColor {
        guard let hex = colorLabel else {
            return .clear
        }
        return UIColor(hexString: hex)
    }
    
    var imageURL: String? {
        return urlImgAuth
    }

    enum CodingKeys: String, CodingKey {

        case createdBy = "createdBy"
        case updatedBy = "updatedBy"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case id = "id"
        case urlImgAuth = "urlImgAuth"
        case label = "label"
        case typeAuth = "typeAuth"
        case colorLabel
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdBy = try values.decodeIfPresent(TimeInterval.self, forKey: .createdBy)
        updatedBy = try values.decodeIfPresent(TimeInterval.self, forKey: .updatedBy)
        createdAt = try values.decodeIfPresent(TimeInterval.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(TimeInterval.self, forKey: .updatedAt)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        urlImgAuth = try values.decodeIfPresent(String.self, forKey: .urlImgAuth)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        typeAuth = try values.decodeIfPresent(String.self, forKey: .typeAuth)
        colorLabel = try values.decodeIfPresent(String.self, forKey: .colorLabel)
    }

}


struct FoodExploreItem : Codable, DisplayShortDescriptionProtocol {
	let createdBy : TimeInterval?
	let updatedBy : TimeInterval?
	let createdAt : TimeInterval?
	let updatedAt : TimeInterval?
	let id : Int?
	var name : String?
	let address : String?
	var lat : Double?
	var lon : Double?
	let bannerImage : [String]?
	let otherImage : [String]?
	let phoneNumber : String?
    var workingHours : WorkingHoursType?
	let merchant : MerchantBasic?
	let category : [MerchantCategory]?
	let status : Int
	let zoneName : String?
	let zoneId : Int?
	let urlRefer : String?
    let infoStoreVerify: StoreInfoVerify?
    
    var imageURL: String? {
        return bannerImage?.first
    }
    
    var descriptionCat: String? {
        let arr = category?.compactMap { $0.name }
        return arr?.joined(separator: ", ")
    }
    
    var currentDistance: Double? {
        let coordinate = CLLocationCoordinate2D(latitude: lat ?? 0, longitude: lon ?? 0)
        guard let currentLocation = VatoLocationManager.shared.location, coordinate != kCLLocationCoordinate2DInvalid else {
            return nil
        }
        
        return currentLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    var distance: String? {
        guard let d = self.currentDistance else { return "" }
        if d >= 1000 {
            return String(format: "Cách %.2fkm", d/1000)
        } else {
            return String(format: "Cách %.0fm", d)
        }
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
		case merchant = "merchant"
		case category = "category"
		case status = "status"
		case zoneName = "zoneName"
		case zoneId = "zoneId"
		case urlRefer = "urlRefer"
        case infoStoreVerify
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(TimeInterval.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(TimeInterval.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(TimeInterval.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(TimeInterval.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		lat = try values.decodeIfPresent(Double.self, forKey: .lat)
		lon = try values.decodeIfPresent(Double.self, forKey: .lon)
		bannerImage = try values.decodeIfPresent([String].self, forKey: .bannerImage)
		otherImage = try values.decodeIfPresent([String].self, forKey: .otherImage)
		phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        if let w = try values.decodeIfPresent(String.self, forKey: .workingHours), let data = w.data(using: .utf8) {
            let json = (try JSONSerialization.jsonObject(with: data, options: [])) as? JSON
            do {
                workingHours = try WorkingHoursType.toModel(from: json)
            } catch {
                print(error.localizedDescription)
            }
            
        }
		merchant = try values.decodeIfPresent(MerchantBasic.self, forKey: .merchant)
		category = try values.decodeIfPresent([MerchantCategory].self, forKey: .category)
        status = try values.decode(Int.self, forKey: .status)
		zoneName = try values.decodeIfPresent(String.self, forKey: .zoneName)
		zoneId = try values.decodeIfPresent(Int.self, forKey: .zoneId)
		urlRefer = try values.decodeIfPresent(String.self, forKey: .urlRefer)
        infoStoreVerify = try values.decodeIfPresent(StoreInfoVerify.self, forKey: .infoStoreVerify)
	}

}

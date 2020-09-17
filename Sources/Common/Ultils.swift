//
//  Ultils.swift
//  FaceCar
//
//  Created by Dung Vu on 9/21/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation
import FwiCore
import RIBs
import RxCocoa
import RxSwift
import FwiCoreRX
import FwiCore
import Atributika
import KeyPathKit
import Kingfisher

// MARK: Helper
protocol LoadXibProtocol {}
extension LoadXibProtocol where Self: UIView {
    static func loadXib() -> Self {
        let bundle = Bundle(for: self)
        let name = "\(self)"
        guard let view = bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? Self else {
            fatalError("error xib \(name)")
        }
        return view
    }
}
extension UIView: LoadXibProtocol {}
extension UIViewController {
    public static var name: String {
        return "\(self)"
    }
}
enum SeperatorPositon {
    case top
    case bottom
    case right
    case left
    
}
extension UIView {
    static var nib: UINib? {
        let bundle = Bundle(for: self)
        let name = "\(self)"
        guard bundle.path(forResource: name, ofType: "nib") != nil else {
            return nil
        }
        return UINib(nibName: name, bundle: nil)
    }
    
    @discardableResult
    func addSeperator(with edges: UIEdgeInsets = .zero, position: SeperatorPositon = .bottom) -> UIView {
        let s = UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        }
        
        switch position {
        case .top:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.height.equalTo(0.5)
                    make.left.equalTo(edges.left)
                    make.right.equalTo(-edges.right).priority(.low)
                    make.top.equalToSuperview()
                })
            }
        case .bottom:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.height.equalTo(0.5)
                    make.left.equalTo(edges.left)
                    make.right.equalTo(-edges.right).priority(.low)
                    make.bottom.equalTo(-edges.bottom)
                })
            }
        case .right:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(0.5)
                    make.top.bottom.equalToSuperview()
                    make.right.equalTo(-edges.right)
                })
            }
        case .left:
            s >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(0.5)
                    make.top.bottom.equalToSuperview()
                    make.left.equalTo(edges.left)
                })
            }
        }
        return s
    }
}

extension CLLocationCoordinate2D {
    var value: String {
        return "\(self.latitude),\(self.longitude)"
    }
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }

    func distance(to: CLLocationCoordinate2D) -> Double {
        let result = self.location.distance(from: to.location)
        return result
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension Dictionary {
    func value<E>(for key: Key, defaultValue: @autoclosure () -> E) -> E {
        guard let result = self[key] as? E else {
            return defaultValue()
        }
        return result
    }

    func toData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: [])
    }
}

// MARK: Double
extension Double {
    func round(to places: Int) -> Double {
        let space = pow(10.0, Double(places))
        let v = (self * space).rounded() / space
        return v
    }
    
    func roundPrice() -> UInt32 {
        let average: UInt32
        let min = UInt32(self) / 1000
        if Int(self) % 1000 > 0 {
            average = min * 1000 + 1000
        } else {
            average = min * 1000
        }
        return average
    }
    
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Array {
    func toData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension Decodable {
    static func toModel(from data: Data, block: ((JSONDecoder) -> Void)? = nil) throws -> Self {
        let decoder = JSONDecoder()
        let d = data
        // custom
        block?(decoder)
        do {
            let result = try decoder.decode(self, from: d)
            return result
        } catch let err as NSError {
            debugPrint(err)
            throw err
        }
    }

    static func toModel(from json: JSON?, block: ((JSONDecoder) -> Void)? = nil) throws -> Self {
        guard let data = try json?.toData() else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: "Not available data!!!"])
        }
        return try self.toModel(from: data, block: block)
    }
}

typealias JSON = [String: Any]
extension Data {
    var json: JSON? {
        let result = try? JSONSerialization.jsonObject(with: self, options: [])
        return result as? JSON
    }
}

infix operator >>>: Display
precedencegroup Display {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: AdditionPrecedence
}

@discardableResult
func >>> <E: AnyObject>(lhs: E, block: (E) -> Void) -> E {
    block(lhs)
    return lhs
}

@discardableResult
func >>> <E: AnyObject>(lhs: E?, block: (E?) -> Void) -> E? {
    block(lhs)
    return lhs
}

func >>> <E, F>(lhs: E, rhs: F) -> E where E: UIView, F: UIView {
    rhs.addSubview(lhs)
    return lhs
}

func >>> <E, F>(lhs: E, rhs: F?) -> E where E: UIView, F: UIView {
    rhs?.addSubview(lhs)
    return lhs
}

func >>> (rhs: FireBaseTable, lhs: FireBaseTable) -> NodeTable {
    let newPath = "\(rhs.name)" + "/" + "\(lhs.name)"
    return NodeTable(currentTable: lhs, path: newPath)
}

func >>> (rhs: NodeTable, lhs: FireBaseTable) -> NodeTable {
    let newPath = "\(rhs.path)" + "/" + "\(lhs.name)"
    return NodeTable(currentTable: lhs, path: newPath)
}

struct NodeTable {
    let currentTable: FireBaseTable
    let path: String
}

@objc
extension NSNumber {
    static let formatCurrency = format()
    
    private static func format() -> NumberFormatter {
        let format = NumberFormatter()
        format.locale = Locale(identifier: "vi_VN")
        format.numberStyle = .currency
        format.currencyGroupingSeparator = ","
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = 0
        format.positiveFormat = "#,###\u{00a4}"
        
        return format
    }
    
    func money() -> String? {
       return NSNumber.formatCurrency.string(from: self)
    }
    
    static let formatPoint = point()
    private static func point() -> NumberFormatter {
        let format = NumberFormatter()
        format.groupingSeparator = ","
        format.numberStyle = .decimal
        return format
    }

    func point() -> String? {
        return NSNumber.formatPoint.string(from: NSNumber(value: self.intValue))
    }
}


extension Numeric {
    var currency: String {
        return (self as? NSNumber)?.money() ?? ""//.currency(withISO3: "VND", placeSymbolFront: false) ?? ""
        // return (self as? NSNumber)?.currency(withISO3: "VND", placeSymbolFront: false) ?? ""
    }
    var point: String {
        return (self as? NSNumber)?.point() ?? ""
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let customDateFireBase = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let time = try container.decode(TimeInterval.self)
        let date = Date(timeIntervalSince1970: time / 1000)

        return date
    }
}

// MARK: -- Observable
protocol OptionalType {
    associatedtype Wrapped
    var optionalValue: Wrapped? { get }
}

extension Swift.Optional: OptionalType {
    var optionalValue: Wrapped? {
        return self
    }
}

extension UIImage {
    static func image(from color: UIColor, with size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resize(to targetSize: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let i = self
        let sizeImg = i.size
        let ratio = max(targetSize.width / sizeImg.width, targetSize.height / sizeImg.height)
        let rect = CGRect(origin: .zero, size: sizeImg * ratio)
        let render = UIGraphicsImageRenderer(bounds: rect)
        let result = render.image { _ in
            i.draw(in: rect)
        }
        return result
    }
}

extension UIView {
    var edgeSafe: UIEdgeInsets {
        if #available(iOS 11, *) {
            return self.safeAreaInsets
        }
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}

// MARK: Indicator
private struct ActivityToken<E>: ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable

    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    func dispose() {
        _dispose.dispose()
    }

    func asObservable() -> Observable<E> {
        return _source
    }
}


// MARK: Debug Log
func printDebug(_ items: Any..., file: String = #file, line: Int = #line) {
    #if DEBUG
        let p = file.components(separatedBy: "/").last ?? ""
        print("DEBUG \(p), Line: \(line): \(items)")
    #endif
}

//extension URL: ExpressibleByStringLiteral {
//    public init(stringLiteral value: String) {
//        guard let url = URL(string: value) else {
//            fatalError("check \(value) is not URL")
//        }
//        self = url
//    }
//}
// MARK: Try catch
func tryNotThrow<T>(_ block: () throws -> T, default: @autoclosure () -> T) -> T {
    do {
        return try block()
    } catch {
        printDebug(error.localizedDescription)
        return `default`()
    }
}


// MARK: KeyPath
prefix operator ~

prefix func ~ <A, B>(_ keyPath: KeyPath<A, B>) -> (A) -> B {
    return { $0[keyPath: keyPath] }
}

//prefix func ~ <A, B>(_ keyPath: KeyPath<A, B>) -> (A, A) -> Bool where B: Comparable {
//    return { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
//}

//prefix func ~ <A>(_ keyPath: KeyPath<A, Bool>) -> (A) -> Bool {
//    return { $0[keyPath: keyPath] }
//}

struct WritableKeyPathApplicator<Type> {
    private let applicator: (Type, Any) -> Type
    init<ValueType>(_ keyPath: WritableKeyPath<Type, ValueType>) {
        applicator = {
            var instance = $0
            if let value = $1 as? ValueType {
                instance[keyPath: keyPath] = value
            }
            return instance
        }
    }
    func apply(value: Any, to: Type) -> Type {
        return applicator(to, value)
    }
}

func setter<Object: AnyObject, Value>(for object: Object, keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Void {
    return { [weak object] value in
        object?[keyPath: keyPath] = value
    }
}

func setter<Object: AnyObject, Value>(for object: Object?, keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Void {
    return { [weak object] value in
        object?[keyPath: keyPath] = value
    }
}

// MARK : Attribute String
extension String {
    var attribute: NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    var url: URL? {
        guard let n = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: n)
    }
}

enum AttributeStyle {
    case color(c: UIColor)
    case paragraph(p: NSParagraphStyle)
    case font(f: UIFont)
    case strike(v: CGFloat)
    case underline(u: Int)
    
    var key: NSAttributedString.Key {
        switch self {
        case .color:
            return .foregroundColor
        case .paragraph:
            return .paragraphStyle
        case .font:
            return .font
        case .strike:
            return .strikethroughStyle
        case .underline:
            return .underlineStyle
        }
    }
    
    var value: Any {
        switch self {
        case .color(let c):
            return c
        case .paragraph(let p):
            return p
        case .font(let f):
            return f
        case .strike(let v):
            return v
        case .underline(let u):
            return u
        }
    }
}

extension NSAttributedString {
    func add(attribute: AttributeStyle) -> NSAttributedString {
        let text = self.string
        guard !text.isEmpty else {
            return self
        }
        
        let mAttribute = NSMutableAttributedString(attributedString: self)
        let range = NSMakeRange(0, text.count)
        mAttribute.addAttributes([attribute.key : attribute.value], range: range)
        return mAttribute
    }
    func add(from attribute: NSAttributedString) -> NSAttributedString {
        let text = attribute.string
        guard !text.isEmpty else {
            return self
        }
        
        let mAttribute = NSMutableAttributedString(attributedString: self)
        mAttribute.append(attribute)
        return mAttribute
    }
}

func >>> (lhs: NSAttributedString, rhs: AttributeStyle) -> NSAttributedString {
    return lhs.add(attribute: rhs)
}

func >>> (lhs: NSAttributedString?, rhs: AttributeStyle) -> NSAttributedString? {
    return lhs?.add(attribute: rhs)
}

func >>> (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    return lhs.add(from: rhs)
}

infix operator ~~>: AttributeCustom
precedencegroup AttributeCustom {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: AdditionPrecedence
}
func ~~> (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let a = NSMutableAttributedString(attributedString: lhs)
    a.append(rhs)
    return a
}

// MARK: Date
extension Date {
    func string(from format: String = "dd/MM/yyyy") -> String {
        let formatDate = DateFormatter()
        formatDate.dateFormat = format
        let result = formatDate.string(from: self)
        return result
    }
    
    static func date(from str: String?, format: String, identifier: DateIdentifier = .utc) -> Date? {
        guard let str = str, !str.isEmpty else {
            return nil
        }
        precondition(!format.isEmpty, "Format is not empty.")
        let formater = DateFormatter()
        formater.dateFormat = format
        formater.timeZone = TimeZone(identifier: identifier.rawValue)
        let result = formater.date(from: str)
        return formater.date(from: str)
    }
}

// MARK: Array
extension Array {
    subscript(safe idx: Int) -> Element? {
        guard 0..<self.count ~= idx else {
            return nil
        }
        return self[idx]
    }
    
    mutating func addOptional(_ element: Element?) {
        guard let element = element else {
            return
        }
        self.append(element)
    }
}

// MARK: Set status
extension UIApplication {
    static func setStatusBar(using type: UIStatusBarStyle) {
        UIApplication.shared.statusBarStyle = type
    }
}

extension UIButton {
    func setBackground(using color: UIColor, state: UIControl.State) {
        let img = UIImage.image(from: color, with: CGSize(width: 20.0, height: 20.0))
        self.setBackgroundImage(img, for: state)
    }
}



fileprivate struct Loading {
    static var name = "indicator"
}

extension CGSize {
    static func / (lhs: CGSize, value: CGFloat) -> CGSize {
        precondition(value != 0, "Value is not equal 0!!!")
        return CGSize(width: lhs.width / value, height: lhs.height / value)
    }
    
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

// MARK: - Safe protocol
protocol SafeAccessProtocol {
    var lock: NSRecursiveLock { get }
}

extension SafeAccessProtocol {
    @discardableResult
    func excute<T>(block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
}
// MARK: - Firebase Time
@objcMembers
final class FireBaseTimeHelper:NSObject, SafeAccessProtocol {
    static let `default` = FireBaseTimeHelper()
    private struct Config {
        static let timeUpdate: Int = 10
    }
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private var diposeAble: Disposable?
    private var _currentTime: TimeInterval = 0
    private var _offset: TimeInterval = 0
    private (set) var offset: TimeInterval {
        get {
            return excute { _offset }
        }
        
        set {
            excute { _offset = newValue }
        }
    }
    var currentTime: TimeInterval {
        return self.excute(block: { _currentTime > 0 ? _currentTime : Date().toGMT().timeIntervalSince1970 * 1000 })
    }
    
    func startUpdate() {
        diposeAble?.dispose()
        diposeAble = Observable<Int>.interval(.seconds(Config.timeUpdate), scheduler: SerialDispatchQueueScheduler(qos: .background)).startWith(-1).debug("Interval Check").bind { (_) in
            self.requestTime()
        }
    }
    
    private func requestTime() {
        let db = Database.database().reference(withPath: ".info/serverTimeOffset")
        db.observe(.value) { (d) in
            let offset = d.value as? Double
            let c = Date().timeIntervalSince1970
            let interval = c * 1000 + (offset ?? 0)
            self.update(by: interval)
        }
    }
    
    private func update(by time: TimeInterval) {
        self.excute { self._currentTime = time.rounded(.awayFromZero) }
    }
    
    func stopUpdate() {
        diposeAble?.dispose()
        diposeAble = nil
    }
}


// MARK: - weakitify code
protocol Weakifiable: AnyObject {}
extension Weakifiable {
    func weakify(_ code: @escaping (Self) -> Void) -> () -> Void {
        return { [weak self] in
            guard let self = self else { return }
            code(self)
        }
    }
    
    func weakify<T>(_ code: @escaping (T, Self) -> Void) -> (T) -> Void {
        return { [weak self] arg in
            guard let self = self else { return }
            code(arg, self)
        }
    }
}
protocol TaskExcuteProtocol {
    var identifier: String { get }
    func cancel()
}

extension DownloadTask: TaskExcuteProtocol {
    var identifier: String {
        return "DownloadTask"
    }
}
extension UIViewController: Weakifiable {}

func mainAsync<T>(block: ((T) -> ())?) -> (T) -> () {
    return { value in
        DispatchQueue.main.async {
            block?(value)
        }
    }
}

enum DateIdentifier: String {
    case utc = "UTC"
    case vn = "Asia/Ho_Chi_Minh"
}

extension Date {
    func toGMT(for identifier: DateIdentifier = .utc) -> Date {
        let next = TimeZone(identifier: identifier.rawValue)?.secondsFromGMT() ?? 0
        let current = TimeZone.current.secondsFromGMT()
        let delta = next - current
        return addingTimeInterval(TimeInterval(delta))
    }

    func to24h() -> TimeInterval {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.dateComponents([.hour, .minute, .second], from: self)
        let hour = component.hour ?? 0
        let minute = component.minute ?? 0
        let seconds = component.second ?? 0
        return Double(hour) + Double(minute) / 60 + Double(seconds) / 3600
    }
}

// MARK: - Color
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

protocol EmptyProtocol {
    var isEmpty: Bool { get }
}

extension EmptyProtocol {
    func orEmpty(_ default: @autoclosure () -> Self) -> Self {
        guard !self.isEmpty else {
            return `default`()
        }
        return self
    }
}

extension String: EmptyProtocol {}

@objc
extension NSString {
    static func generate(text: String,
                         tag: String,
                         color: UIColor,
                         font: UIFont) -> NSAttributedString
    {
        let style = Atributika.Style("\(tag)").foregroundColor(color).font(font)
        let s = text.style(tags: style)
        return s.attributedString
    }
    
    static func generateNoteSupply(str: String?) -> NSAttributedString? {
        guard let s = str else {
            return nil
        }
        let styleA = Atributika.Style("a").foregroundColor(#colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)).font(.systemFont(ofSize: 14, weight: .regular))
        let styleB = Atributika.Style("b").foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).font(.systemFont(ofSize: 13, weight: .regular))
        let p = NSMutableParagraphStyle()
        p.lineSpacing = 5
        p.alignment = .left
        let styleAll = Atributika.Style.foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)).paragraphStyle(p)
        let att = s.style(tags: styleA, styleB).styleAll(styleAll).attributedString
        return att
    }
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    static func makeStringWithoutEmpty(from others: String?..., seperator: String) -> String {
        let new = others.compactMap { $0 }.filter(where: \.isEmpty == false).joined(separator: seperator)
        return new
    }
}

@objc
extension UIApplication {
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        guard let controller = controller else {
            return nil
        }
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}

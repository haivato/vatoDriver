//
//  Utils.swift
//  FC
//
//  Created by khoi tran on 2/21/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Kingfisher
import SDWebImage
import RxSwift
import SnapKit

struct ImageProcessorDisplay: ImageProcessor {
    var identifier: String
    let targetSize: CGSize
    
    init(target: CGSize) {
        targetSize = target
        identifier = "com.upfit.\(Int64(Date().timeIntervalSince1970))"
    }
    
    func process(item: ImageProcessItem, options _: KingfisherParsedOptionsInfo) -> Image? {
        var img: Image?
        switch item {
        case let .data(data):
            img = Image(data: data)
        case let .image(image):
            img = image
        }
        
        guard let i = img else {
            return nil
        }
        
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
protocol ImageDisplayProtocol {
    var imageURL: String? { get }
    var sourceImage: Source? { get }
}
extension ImageDisplayProtocol {
    var sourceImage: Source? {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            return nil
        }
        
        return .network(url)
    }
}

extension String: ImageDisplayProtocol {
    var imageURL: String? {
        return self
    }
}

extension String {
    var asciiArray: [Int32] {
           return unicodeScalars.filter { $0.isASCII }.map { Int32($0.value) }
       }
       func javaHash() -> Int32 {
           let codes = asciiArray
           let result = codes.reduce(0) { (result, next) -> Int32 in
               let r = result.multipliedReportingOverflow(by: 31)
               let f = r.partialValue.addingReportingOverflow(next)
               return f.partialValue
           }
           return abs(result)
       }

}
extension UILabel {
    func underlineText(originString: String?, at range: NSRange) {
        let customizedText = NSMutableAttributedString(string: originString ?? "")
        customizedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        customizedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange, range: range)
        self.attributedText = customizedText
        
    }
}

extension UIImageView {
    @discardableResult
    func setImage(from source: ImageDisplayProtocol?, placeholder: UIImage? = nil, size: CGSize? = nil) -> DownloadTask? {
        image = nil
        guard let s = source else { return nil }
        layoutSubviews()
        let mSize = size ?? bounds.size
        precondition(mSize != .zero, "Recheck size")
        var key: String = ""
        let processor = ImageProcessorDisplay(target: mSize)
        TryLoad: if let url = source?.sourceImage?.url {
            key = url.absoluteString
            guard let image = SDImageCache.shared.imageFromCache(forKey: key) else {
                break TryLoad
            }
            self.image = image
            return nil
        }
        kf.indicatorType = .activity
        let task = kf.setImage(with: s.sourceImage, placeholder: placeholder, options: [.processor(processor)]) { (result) in
            guard !key.isEmpty else { return }
            switch result {
            case .success(let r):
                SDImageCache.shared.store(r.image, forKey: key, completion: nil)
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        
        return task
    }
}

@objcMembers
class Utils: NSObject{
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}

extension Encodable {
    func toJSON() throws -> JSON {
        let data = try toData()
        let value = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = value as? JSON else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey : "Failed make json!!!!"])
        }
        return json
    }
    
    func toData() throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return data
    }
}

extension UIViewController {
    func visualizeButtonLeft(imgLeft: String = "ic_arrow_navi_left") -> UIButton {
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: imgLeft), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        return buttonLeft
    }
    
    func visualizeButtonRight(imgRight: String) -> UIButton {
        let buttonRight = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonRight.setImage(UIImage(named: imgRight), for: .normal)
        let rightBarButton = UIBarButtonItem(customView: buttonRight)
        navigationItem.rightBarButtonItem = rightBarButton
        return buttonRight
    }
    
    func visualizeNavigationBar(color: UIColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1), titleStr: String) {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = color
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .medium) ]
        UIApplication.setStatusBar(using: .lightContent)
        title = titleStr
    }
    
    func visualizeWhiteNavigationBar(titleStr: String) {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.setBackgroundImage(UIImage(), for:.default)
        navigationBar?.shadowImage = UIImage()
        navigationBar?.layoutIfNeeded()
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .medium) ]
        visualizeNavigationBar(color: .white, titleStr: titleStr)
    }
}


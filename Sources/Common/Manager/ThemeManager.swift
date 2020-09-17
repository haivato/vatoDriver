//  File name   : ThemeManager.swift
//
//  Author      : Dung Vu
//  Created date: 1/8/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Zip
import Alamofire
import RxSwift
import RxCocoa
import FwiCore
import Kingfisher
import SDWebImage
import SDWebImagePDFCoder
import FirebaseFirestore

struct ThemeModel: Codable {
    var theme_storage_path_android_client: String?
    var theme_storage_path_ios_client: String?
}


struct PDFProcessorDisplay: ImageProcessor {
    let identifier: String = "com.vato.pdfprocess"
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let i):
            return i
        case .data(let data):
            return UIImage.createImagePDF(from: data)
        }
    }
}

extension UIImage {
    static func createImagePDF(from data: Data) -> UIImage? {
        let pdfData = data as CFData
        guard let provider: CGDataProvider = CGDataProvider(data: pdfData) else {return nil}
        guard let pdfDoc: CGPDFDocument = CGPDFDocument(provider) else {return nil}
        guard let pdfPage: CGPDFPage = pdfDoc.page(at: 1) else {return nil}
        let pdfImage = getImage(from: pdfPage)
        return pdfImage
    }
    
    private static func getImage(from pdfPage: CGPDFPage) -> UIImage? {
        var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
        pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
        UIGraphicsBeginImageContextWithOptions(pageRect.size, false, UIScreen.main.scale)
        guard let context:CGContext = UIGraphicsGetCurrentContext()  else {return nil}
        context.saveGState()
        context.translateBy(x: 0.0, y: pageRect.size.height)
        context.scaleBy(x: 1, y: -1)
        context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect:  pageRect, rotate: 0, preserveAspectRatio: true))
        context.drawPDFPage(pdfPage)
        context.restoreGState()
        let pdfImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return pdfImage
    }
    
    static func loadListImage(from pdfFile: String) -> [UIImage] {
        guard let f = Bundle.main.url(forResource: pdfFile, withExtension: "pdf") else {
            return []
        }
        do {
            let data = try Data(contentsOf: f)
            var current: Int = 1
            let pdfData = data as CFData
            guard let provider: CGDataProvider = CGDataProvider(data: pdfData) else { return [] }
            guard let pdfDoc: CGPDFDocument = CGPDFDocument(provider) else { return [] }
            guard let fPage: CGPDFPage = pdfDoc.page(at: current) else { return [] }
            let pages = sequence(first: fPage) { (_) -> CGPDFPage? in
                current += 1
                return pdfDoc.page(at: current)
            }
            let images = pages.compactMap(getImage(from:))
            return images
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
}

@objcMembers
final class ThemeManager: NSObject, Weakifiable {
    struct Configs {
    }
    static let instance = ThemeManager()
    private lazy var pathRoot = URL.documentDirectory()
    private lazy var subFolder = "Theme_iOS"
    private lazy var pathSave = pathRoot?.appendingPathComponent(subFolder)
    private lazy var fileManager = FileManager.default
    @LoadUserDefault("Theme_iOS_Link", defaultValue: "") private var currentUrl: String
    
    private lazy var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        let PDFCoder = SDImagePDFCoder.shared
        SDImageCodersManager.shared.addCoder(PDFCoder)
    }
    
    private func reset() {
        do {
            try fileManager.removeDirectory(pathSave)
        } catch {
            print(error.localizedDescription)
        }
        self.currentUrl = ""
    }
    
    private func findStorage(from path: String?) -> Observable<URL?> {
           guard let path = path else { return Observable.just(nil) }
           let storage = Storage.storage()
           let storageRef = storage.reference(withPath: path)
           return Observable.create { (s) -> Disposable in
               storageRef.downloadURL { (url, e) in
                   s.onNext(url)
                   s.onCompleted()
               }
               return Disposables.create()
           }
       }
    
    func prepare(urlStr: String?) {
       guard let urlStr = urlStr,
            !urlStr.isEmpty else { return reset() }
        
        findStorage(from: urlStr).filterNil().bind { [weak self](url) in
            guard let wSelf = self else { return }
            guard wSelf.currentUrl != url.absoluteString else {
                return
            }
            let cache = ImageCache.default
            cache.clearDiskCache()
            cache.clearMemoryCache()
            wSelf.downloadZip(url: url)
        }.disposed(by: disposeBag)
        
    }
    
    private func downloadZip(url: URL) {
        download(url: url).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let urlStore):
                wSelf.extract(file: urlStore, urldowload: url)
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposed(by: disposeBag)
    }
    
    private func extract(file: URL, urldowload: URL) {
        guard let pRoot = self.pathSave else {
            return
        }
        do {
            try? fileManager.removeDirectory(pRoot)
            try? fileManager.createDirectory(pRoot)
            try Zip.unzipFile(file, destination: pRoot, overwrite: true, password: nil)
            try? fileManager.removeFile(file)
            self.currentUrl = urldowload.absoluteString
        } catch {
//            assert(false, error.localizedDescription)
        }
    }
    
    private func download(url: URL) -> Observable<Swift.Result<URL, Error>> {
        let manager = Alamofire.Session.default
        return Observable.create { (s) -> Disposable in
            let task = manager.download(url, to: { _, response in
                let cacheURL = URL.cacheDirectory()
                let fName = response.suggestedFilename ?? "theme"
                guard let path = cacheURL?.appendingPathComponent("\(fName).zip") else {
                    fatalError("Please Implement")
                }
                return (path, .removePreviousFile)
            })
            
            task.response { response in
                defer {
                    s.onCompleted()
                }
                
                if let e = response.error {
                    s.onNext(.failure(e))
                    return
                }
                
                if let p = response.fileURL {
                    s.onNext(.success(p))
                } else {
                    let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "File not exit"])
                    s.onNext(.failure(e))
                }
            }
            
            return Disposables.create {
                task.cancel(producingResumeData: true)
            }
        }
    }
    
    func loadPDFImage(name: String) -> UIImage? {
        guard let p = pathSave?.appendingPathComponent("\(name).pdf"), fileManager.fileExists(p) else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: p) else {
            return nil
        }
        let result = UIImage.createImagePDF(from: data)
        return result
    }
    
    func setPDFImage(name: String, view: UIImageView, placeholder: UIImage?) {
        guard let p = pathSave?.appendingPathComponent("\(name).pdf"), fileManager.fileExists(p) else {
            return
        }
        let provider = LocalFileImageDataProvider(fileURL: p)
        let s: Source = .provider(provider)
        let processor = PDFProcessorDisplay()
        view.kf.setImage(with: s, placeholder: placeholder, options: [.processor(processor)])
    }

    func requestThemConfig() {
        
        let documentRef = Firestore.firestore().documentRef(collection: .theme, storePath: .custom(path: "Source") , action: .read)
        
        documentRef.find(action: .get, json: nil, source: .server)
            .filterNil()
            .map { try? $0.decode(to: ThemeModel.self) }
            .bind { (config) in
                ThemeManager.instance.prepare(urlStr: config?.theme_storage_path_ios_client)
        }.disposed(by: disposeBag)
    }
    
    func loadListPDF(by prefix: String) -> [UIImage] {
        guard let folderURL = pathSave,
            fileManager.directoryExists(pathSave) else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [], options: []).filter { $0.lastPathComponent.lowercased().hasPrefix(prefix.lowercased()) }.sorted(by: { (url1, url2) -> Bool in
                let url1 = url1.deletingPathExtension()
                let url2 = url2.deletingPathExtension()
                
                let s1 = url1.lastPathComponent.lowercased().replacingOccurrences(of: prefix, with: "")
                let s2 = url2.lastPathComponent.lowercased().replacingOccurrences(of: prefix, with: "")
                
                let i1 = Int(s1) ?? 0
                let i2 = Int(s2) ?? 0
                return i1 < i2
            })
            
            let result = urls.compactMap { (url) -> UIImage? in
                guard let data = try? Data(contentsOf: url) else {
                    return nil
                }
                let result = UIImage.createImagePDF(from: data)
                return result
            }
            return result
        } catch {
            //            assert(false, error.localizedDescription)
            return []
        }
        
    }

}

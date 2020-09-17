//  File name   : UploadFileStorage.swift
//
//  Author      : Dung Vu
//  Created date: 10/24/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import FirebaseStorage
import Alamofire
import VatoNetwork

struct UploadFoodImage {
    static func detele(path: String) -> Observable<Void> {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: path)
        return Observable.create({ (s) -> Disposable in
            storageRef.delete { (e) in
                if let e = e {
                    s.onError(e)
                } else {
                    s.onNext(())
                    s.onCompleted()
                }
            }
            return Disposables.create()
            
        })
    }
    
    
    
    static func upload(image: UIImage, path: String) -> Observable<URL?> {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return Observable.empty() }
        guard let token = FirebaseTokenHelper.instance.token else {
            return Observable.error(NSError.init(domain: "Invalid token", code: 0, userInfo: nil))
        }
        let headers = [
            "x-access-token": token,
            "Content-Type":"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__",
        ]
        let filename = String(format: "%.0f.jpeg", Date().timeIntervalSince1970 )
        let urlLink = VatoFoodApi.uploadHost + "/image/uploadFile"
        // Fetch Request
        let h = HTTPHeaders(with: headers)
        return Observable.create { (s) -> Disposable in
            let task = Alamofire.Session.default.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(path.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"targetPath")
                multipartFormData.append(data, withName: "file", fileName: filename, mimeType: "image/jpg")
            }, to: urlLink, usingThreshold: 10*1024000, method: .post, headers: h)
            
            task.responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    if let value: JSON = value as? JSON {
                        if let urlString: String = value.value("fileDownloadUri", defaultValue: nil), let url = URL(string: urlString) {
                            s.onNext(url)
                            s.onCompleted()
                        } else {
                            let e = NSError.init(domain: "Error: Parsing upload image error", code: 0, userInfo: nil)
                            s.onError(e)
                        }
                    } else {
                        let e = NSError.init(domain: "Error: Parsing upload image error", code: 0, userInfo: nil)
                        s.onError(e)
                    }
                case .failure(let e):
                    s.onError(e)
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }.observeOn(SerialDispatchQueueScheduler(qos: .background))
        
    }
    
    static func uploadMutiple(images: [UIImage], path: String) -> Observable<[URL?]> {
        let events = images.map { item -> Observable<URL?> in
            return self.upload(image: item, path: path)
        }
        return Observable.zip(events)
    }
}

extension StorageReference {
    func downloadURL() -> Observable<URL?> {
        return Observable.create { [unowned self](s) -> Disposable in
            self.downloadURL { (url, e) in
                if let e = e {
                    return s.onError(e)
                }
                
                s.onNext(url)
                s.onCompleted()
            }
            return Disposables.create()
        }
    }
}

struct QRImageGenerate {
    struct Configs {
        static let folder = "QRImages"
    }
    
    private static var cached: [String: URL] = [:]
    
    private static func reference(by path: String) -> StorageReference {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: path)
        return storageRef
    }
    
    private static func upload(ref: StorageReference, generate: @escaping () throws -> Data) -> Observable<URL?> {
        return Observable.create { (s) -> Disposable in
            var task: StorageUploadTask?
            do {
                let data = try generate()
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                task = ref.putData(data, metadata: metadata, completion: { _, e in
                    if let e = e {
                        s.onError(e)
                    } else {
                        ref.downloadURL(completion: { url, e1 in
                            if let e1 = e1 {
                                s.onError(e1)
                            } else {
                                s.onNext(url)
                                s.onCompleted()
                            }
                        })
                    }
                })
            } catch {
                s.onError(error)
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    enum GenerateQRError: Error {
        case filter
        case ouput
        case result
        
        var localizedDescription: String {
            switch self {
            case .filter:
                return "Not have filter"
            case .ouput:
                return "No file"
            case .result:
                return "Not generate file"
            }
        }
    }
    
    static func generate(code: String) throws -> Data {
        let data = code.data(using: String.Encoding.ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            throw GenerateQRError.filter
        }
        
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        guard let output = filter.outputImage?.transformed(by: transform) else {
            throw GenerateQRError.ouput
        }
        
        var image = UIImage(ciImage: output)
        image = image.resize(to: CGSize(width: 92, height: 92))
        guard let result = image.jpegData(compressionQuality: 0.8) else {
            throw GenerateQRError.result
        }
        return result
    }
    
    static func loadImage(by code: String?) -> Observable<URL?> {
        guard let code = code, !code.isEmpty else {
            return Observable.just(nil)
        }
        
        if let url = cached[code] {
            return Observable.just(url)
        }
        
        let fName = "\(code).png"
        let path = Configs.folder + "/\(fName)"
        let ref = reference(by: path)
        
        return ref.downloadURL().catchErrorJustReturn(nil).flatMap { (url) -> Observable<URL?> in
            if let url = url {
                return Observable.just(url)
            } else {
                return upload(ref: ref) { () -> Data in
                    return try generate(code: code)
                }
            }
        }.do(onNext: { (url) in
            cached[code] = url
        })
    }
}



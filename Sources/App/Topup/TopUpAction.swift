//  File name   : TopUpAction.swift
//
//  Author      : Dung Vu
//  Created date: 11/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import UIKit
import VatoNetwork
import SVProgressHUD
import FwiCore
import Alamofire
import MomoiOSSwiftSdk
import FwiCoreRX
import FwiCore

fileprivate struct TopupResponse: Codable {
    let zptranstoken: String
}

fileprivate struct MomoTopupResponse: Codable {
    let status: Int
    let message: String
}

enum TopUpActionError: Error {
    case topupInstallApp
    case topupInstallAppMoMo
    case topupFail(message: String?)
    case topupFailMomo(title: String?, message: String?)
}

protocol PayHandlerDelegate: class {
    func showAlert(message: String)
    func showError(error: TopUpActionError)
    func track(by name: String, json: JSON, addAmount: Bool)
    func popToRootViewController(animated: Bool)
    func showWebVC(htmlString: String, redirectUrl: String?) -> Observable<Bool>
}

//fileprivate class PayHandler: NSObject {
class PayHandler: NSObject, LoadingAnimateProtocol, DisposableProtocol {
    weak var delegate: PayHandlerDelegate?
    lazy var disposeBag = DisposeBag()
//    let indicator: ActivityIndicator = ActivityIndicator()
//    let indicator: ActivityProgressIndicator = ActivityProgressIndicator()
    
    static let indicator: ActivityProgressIndicator = ActivityProgressIndicator()
    var amount: Int = 0
    let appId: Int = 366
    
    func initPayment(amount: Int) {
        self.amount = amount
    }
    
    func setupRX() {
//        self.indicator.asObservable().observeOn(MainScheduler.asyncInstance).bind {
//            $0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
//            }.disposed(by: disposeBag)
//        showLoading(use: self.indicator.asObservable())
        
            showLoading(use: PayHandler.indicator.asObservable())
    }
    
    func requestToken() {
        
    }
    
    func token() -> Observable<String?> {
        return Observable<String?>.create({ (s) -> Disposable in
            UserDataHelper.shareInstance().getAuthToken { (t, e) in
                if let e = e {
                    s.onError(e)
                    return
                }
                
                s.onNext(t)
                s.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    func generateTransactionID () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        var result = formatter.string(from: Date())
        result = result + "_" + String(UserDataHelper.shareInstance().userId())
        return result
    }
    
}

fileprivate class MomoPayHandler: PayHandler {
    
    private var orderId: String
    private var numberRetry: Int = 0
    override init() {
        self.orderId = ""
        super.init()
    }
    
    override func initPayment(amount: Int) {
        self.amount = amount
        self.setupRX()
    }
    
    override func setupRX() {
        //Registration MOMO NOTIFICATION by self
        super.setupRX()
        NotificationCenter.default.addObserver(self, selector: #selector(self.NoficationCenterTokenReceived), name:NSNotification.Name(rawValue: "NoficationCenterTokenReceived"), object: nil)
    }
    
    override func requestToken() {
        self.orderId = generateTransactionID()
        let paymentinfo = NSMutableDictionary()
        paymentinfo["merchantcode"] = "MOMOS0DC20190726"
        paymentinfo["merchantname"] = "VATO"
        paymentinfo["merchantnamelabel"] = "Nạp tiền"
        paymentinfo["orderId"] = self.orderId
        paymentinfo["amount"] = amount
        paymentinfo["description"] = "Nạp tiền vào tài khoản"
        paymentinfo["appScheme"] = "momos0dc20190727"
        MoMoPayment.createPaymentInformation(info: paymentinfo)
        
        if self.checkMomoInstalled(with: paymentinfo) {
            MoMoPayment.requestToken()
        } else {
            self.delegate?.showError(error: .topupInstallAppMoMo)
        }
    }
    
    @objc func NoficationCenterTokenReceived(notif: NSNotification) {
        //Token Replied - Call Payment to MoMo Server
        guard let response = notif.object as? [String: Any] else { return }
        print("::MoMoPay Log::Received Token Replied::\(response)")
        let _statusStr = response["status"] as? String ?? ""
        if (_statusStr == "0") {
            //            print(">>phone \(response["phonenumber"] as! String)   :: data \(response["data"] as! String)")
            print("Get token success! Processing payment...")
            let number = response["phonenumber"] as? String ?? ""
            let data = response["data"] as? String ?? ""
            executeMomoTopup(customerNumber: number, appData: data)
        } else {
            delegate?.showAlert(message: "Giao dịch thanh toán không thành công, xin vui lòng kiểm tra và thử lại");
        }
    }
    
    private func topup(customerNumber : String, appData: String) -> Observable<(HTTPURLResponse, OptionalMessageDTO<MomoTopupResponse>)> {
        return self.token().filterNil().flatMap { (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<MomoTopupResponse>)> in
            let router = VatoAPIRouter.topUpMomo(authToken: token, transId: self.orderId, amount: self.amount, appId: self.appId, customerNumber: customerNumber, appData: appData)
            let request: Observable<(HTTPURLResponse, OptionalMessageDTO<MomoTopupResponse>)> = Requester.requestDTO(using: router, method: .post, encoding: JSONEncoding.default)
            return request
//            }.observeOn(MainScheduler.asyncInstance).trackActivity(self.indicator).catchError({ [weak self](e) -> Observable<(HTTPURLResponse, OptionalMessageDTO<MomoTopupResponse>)> in
            }.observeOn(MainScheduler.asyncInstance).trackProgressActivity(PayHandler.indicator).catchError({ [weak self](e) -> Observable<(HTTPURLResponse, OptionalMessageDTO<MomoTopupResponse>)> in

                guard let wSelf = self else {
                    return Observable.empty()
                }
                
                let error = e as NSError
                if error.code == -1011 && wSelf.numberRetry < 3 {
                    wSelf.numberRetry += 1
                    return wSelf.topup(customerNumber: customerNumber, appData: appData)
                } else {
                    return Observable.error(e)
                }
            }).do(onNext: { [weak self](_) in
                self?.numberRetry = 0
                }, onError: { [weak self](_) in
                    self?.numberRetry = 0
            })
    }
    
    func executeMomoTopup(customerNumber : String, appData: String) {
        self.topup(customerNumber: customerNumber, appData: appData)
            .subscribe { [weak self](e) in
                switch e {
                case .next(let response):
                    if let status = response.1.data?.status, status != 0 {
                        var title = "Giao dịch không thành công"
                        if status == 9000 {
                            title = "Thông báo từ MoMo"
                        }
                        self?.delegate?.showError(error: .topupFailMomo(title: title, message: response.1.data?.message ?? ""))
                    } else {
                        defer {
                            self?.delegate?.track(by: "MomoTopupResults", json: ["Status" : "Success"], addAmount: true)
                        }
                        self?.delegate?.popToRootViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                            NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
                        })
                    }
                case .error(let e):
                    self?.delegate?.showError(error: .topupFail(message: e.localizedDescription))
                    
                case .completed:
                    printDebug("Completed")
                }
            }.disposed(by: disposeBag)
    }
    
    private func checkMomoInstalled(with paymentInfo: NSMutableDictionary?) -> Bool {
        
        if (paymentInfo as NSMutableDictionary?) == nil {
            print("<MoMoPay> Payment pakageApp should not be null.")
            return false
        }
        
        print("<MoMoPay> requestToken")
        let bundleId = Bundle.main.bundleIdentifier
        //Open MoMo App to get token
        var inputParams = "action=gettoken&partner=merchant"
        paymentInfo?["accesskey"] = ""
        paymentInfo?["ipaddress"] = "10.10.100.100"
        paymentInfo?["clientos"] = self.getDeviceInfoString()
        paymentInfo?["appSource"] = bundleId
        paymentInfo?["sdkversion"] = "2.2"
        let allkeys = paymentInfo?.allKeys ?? []
        for key in allkeys {
            let _value = paymentInfo?[key] as? String
            if _value == nil {
                inputParams.append("&\(key as? String ?? "")=\(paymentInfo?[key] as? Int ?? 0)")
            }
            else{
                let _key = key as? String
                if _key == "extra" || _key == "extra" {
                    
                    //print("UTF8 Original: \(_value)")
                    
                    let utf8str = _value?.data(using: String.Encoding.utf8)
                    
                    if let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                    {
                        //print("UTF8 Encoded:  \(base64Encoded)")
                        inputParams.append("&\(key as? String ?? "")=\(base64Encoded)")
                    }
                    else{
                        inputParams.append("&\(key as? String ?? "")=\(paymentInfo?[key] as? String ?? "")")
                    }
                    
                }
                else {
                    inputParams.append("&\(key as? String ?? "")=\(paymentInfo?[key] as? String ?? "")")
                }
                print("<MoMoPay> request param > \(key) = \(paymentInfo?[key] as? String ?? "")")
            }
            
        }
        
        var appSource:String = "momo://?\(inputParams)"
        
        appSource = appSource.removingPercentEncoding! as String
        appSource = appSource.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        print("<MoMoPay> open url \(appSource)")
        
        if let urlAppMoMo = URL(string: appSource) {
            if UIApplication.shared.canOpenURL(urlAppMoMo) {
                return true
            }
            else {
                return false
            }
        }
        else {
            print("<MoMoPay> momoAppURL fail")
        }
        
        return false
    }
    
    func getDeviceInfoString() -> String {
        let aDevice = UIDevice.current //UIDevice.currentDevice()
        let deviceInfoString = "\(aDevice.localizedModel) \(aDevice.systemName) \(aDevice.systemVersion)"
        return deviceInfoString
    }
}

fileprivate class ZaloPayHandler: PayHandler, ZaloPaySDKDelegate {
    
    typealias ZaloPayResult = (errorCode: ZPErrorCode, transactionId: String?)
    
    lazy var eResult = PublishSubject<ZaloPayResult>()
    
    override init() {
        super.init()
        setupRX()
    }
    
    override func setupRX() {
        
        NotificationCenter.default.rx.notification(Notification.Name.zpTransactionUpdate).bind { [weak self](notify) in
            guard let url = notify.object as? URL, let component = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return
            }
            let json: [String: String] = component.queryItems?.reduce([:], { (r, q) -> [String: String] in
                var temp = r
                temp[q.name] = q.value
                return temp
            }) ?? [:]
            
            let code = Int(json.value(for: "code", defaultValue: "-5"))
            let transid = json.value(for: "transid", defaultValue: "")
            self?.eResult.onNext((ZPErrorCode(code ?? -5), transid))
            }.disposed(by: disposeBag)
        
        eResult.observeOn(MainScheduler.asyncInstance).bind { [weak self](errorCode: ZPErrorCode, transactionId: String?) in
            switch errorCode {
            case ZPErrorCode_Success:
                defer {
                    self?.delegate?.track(by: "TopupResults", json: ["Status" : "Success"], addAmount: true)
                }
                self?.delegate?.popToRootViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
                })
            case ZPErrorCode_NotInstall:
                self?.delegate?.showError(error: .topupInstallApp)
            default:
                defer {
                    self?.delegate?.track(by: "TopupResults", json: ["Status" : errorCode.rawValue], addAmount: true)
                }
                self?.delegate?.showError(error: .topupFail(message: nil))
            }
            }.disposed(by: disposeBag)
    }
    
    func zalopayCompleteWith(_ errorCode: ZPErrorCode, transactionId: String!) {
        eResult.onNext((errorCode, transactionId))
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    override func requestToken() {
        self.delegate?.track(by: "TopupConfirm", json: [:], addAmount: true)
        self.token().filterNil().flatMap { (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<TopupResponse>)> in
            let router = VatoAPIRouter.topUp(authToken: token, amount: self.amount, appId: self.appId)
            let request: Observable<(HTTPURLResponse, OptionalMessageDTO<TopupResponse>)> = Requester.requestDTO(using: router, method: .post, encoding: JSONEncoding.default)
            return request
//            }.trackActivity(self.indicator)
        }.trackProgressActivity(PayHandler.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self](e) in
                switch e {
                case .next(let response):
                    if let error = response.1.error {
                        self?.delegate?.showError(error: .topupFail(message: error.localizedDescription))
                    } else {
                        let transtoken = response.1.data?.zptranstoken ?? ""
                        ZaloPaySDK.sharedInstance()?.payOrder(transtoken)
                    }
                case .error(let e):
                    self?.delegate?.showError(error: .topupFail(message: e.localizedDescription))
                case .completed:
                    printDebug("Completed")
                }
            }.disposed(by: disposeBag)
    }
}

class TopUpAction: WithdrawActionHandlerProtocol, PayHandlerDelegate {
    var didSelectAdd: (() -> Void)?
    
    private(set) var eAction: PublishSubject<WithdrawConfirmAction> = PublishSubject()
    private(set) var errorMessageSubject: Observable<String> = Observable.empty()
    private let eError = PublishSubject<String>()
    private let indicator: ActivityIndicator = ActivityIndicator()
    
    private let disposeBag = DisposeBag()
    private var amount: Int = 0
    private var method: String = "ZaloPay"
    private weak var navigationController: UINavigationController?
    private var payHandler: PayHandler?
    private var topUpItem: TopupCellModel?

    init(with method: String, amount: Int, controller: UIViewController?, topUpItem: TopupCellModel?) {
        self.amount = amount
        self.method = method
        self.navigationController = controller?.navigationController
        self.topUpItem = topUpItem
        setupRX()
    }
    
    private func setupRX() {
        switch self.method {
        case "Zalopay":
            let zpHandler = ZaloPayHandler()
            zpHandler.delegate = self
            ZaloPaySDK.sharedInstance()?.delegate = zpHandler
            self.payHandler = zpHandler
        case "Momopay":
            let mpHandler = MomoPayHandler()
            mpHandler.delegate = self
            self.payHandler = mpHandler
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NoficationCenterTokenReceived"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NoficationCenterTokenReceivedUri"), object: nil)
        case "Napas":
            let npHandler = NapasHandler()
            npHandler.topUpItem = self.topUpItem
            npHandler.delegate = self
            self.payHandler = npHandler
        default:
            break
        }
        self.payHandler?.initPayment(amount: self.amount)
        
        eAction.bind { [weak self](type) in
            switch type {
            case .cancel:
                self?.track(by: "TopupConfirmGoback", json: [:])
                self?.navigationController?.popViewController(animated: true)
            case .next:
                self?.payHandler?.requestToken()
            }
            }.disposed(by: disposeBag)
        indicator.asObservable().observeOn(MainScheduler.asyncInstance).bind { (f) in
            f ? SVProgressHUD.show(withStatus:"Đang xử lý") : SVProgressHUD.dismiss()
            }.disposed(by: disposeBag)
        
    }
    
    func track(by name: String, json: JSON, addAmount: Bool = false) {
        var json = json
        if addAmount {
            json["Amount"] = self.amount
            json["Channel"] = self.method
        }
        TrackingHelper.trackEvent(name, value: json)
    }
    
    func showAlert(message: String) {
        let alertActionOK = AlertAction.init(style: .cancel, title: "Đóng") {}
        AlertVC.show(on: self.navigationController?.visibleViewController, title: "Giao dịch không thành công", message: message, from: [alertActionOK], orderType: .horizontal)
    }
    
    private func message(from errorMessage: String?) -> String {
        let s = errorMessage?.components(separatedBy: ".").last?.lowercased()
        switch s {
        case "TopupPermissionDeniedException".lowercased():
            return "Bạn chưa thể sử dụng tính năng này. Vui lòng thử lại sau."
        default:
            return "Giao dịch thanh toán không thành công, xin vui lòng kiểm tra và thử lại."
        }
    }
    
    func showError(error: TopUpActionError) {
        switch error {
        case .topupFail(let m):
            let message = self.message(from: m)
            let alertActionOK = AlertAction.init(style: .cancel, title: "Đóng") {}
            AlertVC.show(on: self.navigationController?.visibleViewController, title: "Giao dịch không thành công", message: message, from: [alertActionOK], orderType: .horizontal)
        case .topupInstallApp:
            let url: URL = "https://itunes.apple.com/vn/app/zalopay-thanh-to%C3%A1n-trong-2s/id1112407590?mt=8"
            let alertActionOK = AlertAction.init(style: .default, title: "Tải ZaloPay") { [weak self] in
                defer {
                    self?.track(by: "NotYetInstallZaloPay", json: ["Status" : "Download ZaloPay"])
                }
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil);
                }
                else {
                    UIApplication.shared.openURL(url);
                }
                
            }
            
            let alertCancel = AlertAction.init(style: .cancel, title: "Đóng", handler: { [weak self] in
                self?.track(by: "NotYetInstallZaloPay", json: ["Status" : "Cancel"])
            })
            AlertVC.show(on: self.navigationController?.visibleViewController, title: "Thông báo", message: "Bạn vui lòng cài đặt ZaloPay trước khi thanh toán", from: [alertCancel, alertActionOK], orderType: .horizontal)
        case .topupInstallAppMoMo:
            let alertActionOK = AlertAction.init(style: .default, title: "Tải Momo") {
                var appStoreURL:String = "itms-apps://itunes.apple.com/us/app/momo-chuyen-nhan-tien/id918751511"
                appStoreURL = appStoreURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                if let downloadURL:URL = URL(string:appStoreURL) {
                    if UIApplication.shared.canOpenURL(downloadURL) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(downloadURL, options: [:], completionHandler: nil);
                        }
                        else {
                            UIApplication.shared.openURL(downloadURL);
                        }
                    }
                    
                }
            }
            
            let alertCancel = AlertAction.init(style: .cancel, title: "Đóng", handler: {})
            AlertVC.show(on: self.navigationController?.visibleViewController, title: "Thông báo", message: "Bạn vui lòng cài đặt Momo trước khi thanh toán", from: [alertCancel, alertActionOK], orderType: .horizontal)
            
        case .topupFailMomo(let title, let m):
            let alertActionOK = AlertAction.init(style: .cancel, title: "Đóng") {}
            AlertVC.show(on: self.navigationController?.visibleViewController, title: title, message: m, from: [alertActionOK], orderType: .horizontal)
        }
    }
    
    func popToRootViewController(animated: Bool) {
        self.didSelectAdd?()
    }
    
    func showWebVC(htmlString: String, redirectUrl: String?) -> Observable<Bool> {
        return TopUpNapasWebVC.loadWeb(on: self.navigationController, title: "Xác nhận thanh toán", type: .local(htmlString: htmlString, redirectUrl: redirectUrl))
    }
}


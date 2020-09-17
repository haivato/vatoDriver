//
//  NapasHandler.swift
//  Vato
//
//  Created by khoi tran on 2/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import VatoNetwork
import RxSwift
import FwiCore
import FwiCoreRX
import Alamofire

extension TopUpAtmResponse {
    
    func getHtmlString() -> String {
        let result = """
        <form id="merchant-form" action="\(self.redirectUrl ?? "")" method="POST"><div id="napas-widget-container"></div><script type="text/javascript" id="napas-widget-script"src="https://dps-staging.napas.com.vn/api/restjs/resources/js/napas.hostedform.min.js"merchantId="VATO2"clientIP="\(self.clientIp ?? "")"deviceId="phone"environment="MobileApp"cardScheme="AtmCard"enable3DSecure="false"apiOperation="PURCHASE_OTP"orderReference="Thanh toan hoa don"orderId="\(self.orderId ?? "")"channel="1234"sourceOfFundsType="CARD"dataKey="\(self.dataKey ?? "")"napasKey="\(self.napasKey ?? "")"></script></form>
        """
        
        return result
    }
}

struct TopUpNapasResponse: Codable {
    var apiOperation: String?
    var result: String?
    var dataKey: String?
    var napasKey: String?
    var orderId: String?
    var orderToken: String?
    var orderDetail: String?
    var clientIp: String?
    var transactionId: String?
    var html: String?
    var status: String?
}

final class NapasHandler: PayHandler {
    
    var topUpItem: TopupCellModel?
    
    override init() {
        super.init()
        setupRX()
    }
    
    override func setupRX() {
        super.setupRX()
    }
    
    override func requestToken() {
        self.delegate?.track(by: "TopupConfirm", json: [:], addAmount: true)
        
        guard let card = self.topUpItem?.card, card.type != .none else {
            self.delegate?.showError(error: .topupFail(message: "Invalid payment method"))
            return
        }
        if card.type == .atm {
            self.requestDomesticPayment()
        } else {
            self.requestInternationalPayment()
        }
    }
    
    func requestDomesticPayment() {
        guard let tokenId = Int(self.topUpItem?.card?.id ?? "") else {
            self.delegate?.showError(error: .topupFail(message: "Invalid payment method"))
            
            return
        }
        /*
            "channel": "1234" // Unknown description from BE
         */
        
        self.token().filterNil().flatMap { (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<TopUpAtmResponse>)> in
            let params: [String: Any] = [
                "environment": "MobileApp",
                "cardScheme": "AtmCard",
                "deviceId": "phone",
                "orderAmount": self.amount,
                "tokenId": tokenId,
                "enable3DSecure": false,
                "detail": "test",
                "orderCurrency": "VND",
                "channel": "1234"
            ]
            
            let router = VatoAPIRouter.topUpDomesticAtm(authToken: token, params: params)
            let request: Observable<(HTTPURLResponse, OptionalMessageDTO<TopUpAtmResponse>)> = Requester.requestDTO(using: router, method: .post, encoding: JSONEncoding.default)
            return request
        }
        .trackProgressActivity(NapasHandler.indicator)
        .observeOn(MainScheduler.asyncInstance).flatMap({[weak self] (response) -> Observable<Bool> in
            if let error = response.1.error {
                return Observable.error(error)
            } else {
                
                if let data = response.1.data, let delegate = self?.delegate {
                    return delegate.showWebVC(htmlString: data.getHtmlString(), redirectUrl: data.redirectUrl )
                } else {
                    return Observable.empty()
                }
            }
        })
        .subscribe { [weak self](e) in
            switch e {
            case .next(let isSuccess):
                printDebug(isSuccess)
                if isSuccess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                        NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
                    })
                    self?.delegate?.popToRootViewController(animated: true)
                }
            case .error(let e):
                self?.delegate?.showError(error: .topupFail(message: e.localizedDescription))
            case .completed:
                printDebug("Completed")
            }
        }.disposed(by: disposeBag)
    }
    
    
    func requestInternationalPayment() {
        guard let tokenId = Int(self.topUpItem?.card?.id ?? ""), let scheme = self.topUpItem?.card?.scheme else {
            self.delegate?.showError(error: .topupFail(message: "Invalid payment method"))
            return
        }
        self.token().filterNil().flatMap { (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<TopUpNapasResponse>)> in
            
            let params: [String: Any] = [
                "environment": "MobileApp",
                "cardScheme": "CreditCard",
                "deviceId": "unknown",
                "orderAmount": self.amount,
                "tokenId": tokenId,
                "enable3DSecure": false,
                "detail": "test",
                "orderCurrency": "VND",
                "channel": "1234"
            ]
                        
            
            let router = VatoAPIRouter.topUpNapas(authToken: token, params: params)
            let request: Observable<(HTTPURLResponse, OptionalMessageDTO<TopUpNapasResponse>)> = Requester.requestDTO(using: router, method: .post, encoding: JSONEncoding.default)
            return request
        }
        .trackProgressActivity(NapasHandler.indicator)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe { [weak self](e) in
            switch e {
            case .next(let response):
                if let error = response.1.error {
                    self?.delegate?.showError(error: .topupFail(message: error.localizedDescription))
                } else {
                    if let data = response.1.data, data.result == "SUCCESS" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                            NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
                        })
                        self?.delegate?.popToRootViewController(animated: true)
                    }
                }
            case .error(let e):
                self?.delegate?.showError(error: .topupFail(message: e.localizedDescription))
            case .completed:
                printDebug("Completed")
            }
        }.disposed(by: disposeBag)
        
    }
    
}

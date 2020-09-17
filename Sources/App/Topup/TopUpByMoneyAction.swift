//  File name   : TopUpByMoneyAction.swift
//
//  Author      : Dung Vu
//  Created date: 12/13/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SVProgressHUD
import VatoNetwork
import FwiCore
import FwiCoreRX

extension Notification.Name {
    static let topUpMoneySuccess = Notification.Name(rawValue: "topUpMoneySuccess")
}

struct TopUpByMoneyAction: WithdrawActionHandlerProtocol {
    var didSelectAdd: (() -> Void)?
    var errorMessageSubject: Observable<String> {
        return eError
    }
    
    var eLoading: Observable<Bool> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    private (set)var eAction: PublishSubject<WithdrawConfirmAction> = PublishSubject()
    weak var controller: UIViewController?
    private (set) var indicator: ActivityIndicator = ActivityIndicator()
    private let disposeBag = DisposeBag()
    private let eError = PublishSubject<String>()
    private let passcodeHandler: PassCodeHandler = PassCodeHandler()
    
    let amount: Int
    var name: String?
    let credit: Double
    init(controller: UIViewController?, amount: Int, credit: Double, name: String?) {
        self.controller = controller
        self.name = name
        self.amount = amount
        self.credit = credit
        setupRX()
    }
    
    private func setupRX() {
        self.eAction.bind { (action) in
            switch action {
            case .cancel:
                self.controller?.navigationController?.popViewController(animated: true)
            case .next:
                self.inputPassCode()
            }
            }.disposed(by: disposeBag)
        
        self.passcodeHandler.ePassCode.filterNil().bind { (pass) in
            self.excute(with: pass)
            }.disposed(by: disposeBag)
        
        self.eLoading.bind {
            $0 ? SVProgressHUD.show(withStatus: "Đang xử lý...")  : SVProgressHUD.dismiss()
        }.disposed(by: disposeBag)
        
    }
    
    private func token() -> Observable<String?> {
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
    
    private struct ReponseTopupMoney: Codable {
        var description: String?
    }
    
    private func excute(with code: String) {
        self.token().filterNil()
            .flatMap ({ (token) -> Observable<VatoNetwork.Response<OptionalMessageDTO<[ReponseTopupMoney]>>> in
                let router = VatoAPIRouter.userTransfer(authToken: token, phone: nil, amount: self.amount, pin: code)
                let request = Requester.responseDTO(decodeTo: OptionalMessageDTO<[ReponseTopupMoney]>.self, using: router, method: .post, encoding: JSONEncoding.default)
                return request
            })
            .trackActivity(self.indicator)
            .map { $0.response }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (message) in
                if !message.fail, message.data != nil {
                    self.showResult()
                } else {
                    self.handle(errorCode: message.errorCode)
                }
            }, onError: { (err) in
                self.handle(errorCode: err.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func showResult() {
        let completeAction = TopUpCompleteAction()
        let remain = self.credit + Double(amount)
        let items = [WithdrawConfirmItem(title: "Nạp thành công", message: amount.currency, iconName: "ic_checkmark"),
                     WithdrawConfirmItem(title: "Số tiền", message: "+\(amount.currency)", iconName: nil),
                     WithdrawConfirmItem(title: "Phương thức thanh toán", message: name ?? "", iconName: nil),
                     WithdrawConfirmItem(title: "Số dư tín dụng cuối", message: remain.currency, iconName: nil)]
        let confirmVC = WithdrawConfirmVC({ items }, title: "Hoàn tất", handler: completeAction, titleButton: "Đóng", needShowBack: false)
        self.controller?.navigationController?.pushViewController(confirmVC, animated: true)
    }
    
    private func inputPassCode() {
        guard let currentVC = self.controller?.navigationController?.visibleViewController else {
            return
        }
        
        guard let passcodeView = FCPassCodeView(view: currentVC) else {
            return
        }
        
        self.passcodeHandler.passCodeView = passcodeView
        passcodeView.lblTitle.text = "Nhập mật khẩu thanh toán"
        passcodeView.setupView(PasscodeType(rawValue: 0))
        currentVC.view.addSubview(passcodeView)
    }
    
    
    private func handle(errorCode: String?) {
        let code = errorCode ?? ""
        switch code {
        case "io.vato.apiv3.service.exception.MembershipServiceException":
            eError.onNext("Mật khẩu giao dịch không tồn tại.")
            
        case "io.vato.apiv3.service.exception.CantVerifyPinException":
            eError.onNext("Mật khẩu giao dịch không đúng.")
            
        case "io.vato.apiv3.service.exception.NoSuchBankInfoException":
            eError.onNext("Thông tin ngân hàng không hợp lệ.")
            
        case "io.vato.apiv3.service.exception.ReachMaxWithdrawOrderException":
            eError.onNext("Bạn đã hết lượt yêu cầu rút tiền. Vui lòng chờ giao dịch được xử lý.")
            
        case "io.vato.apiv3.service.exception.InsufficientBalanceException":
            eError.onNext("Số dư không đủ để yêu cầu rút tiền.")
            
        default:
            eError.onNext("Không thể kết nối đến server, vui lòng thử lại sau.")
        }
    }
}


struct TopUpCompleteAction: WithdrawActionHandlerProtocol {
    var didSelectAdd: (() -> Void)?
    private (set) var eAction: PublishSubject<WithdrawConfirmAction> = PublishSubject()
    var errorMessageSubject: Observable<String> {
        return Observable.empty()
    }
    private let disposeBag = DisposeBag()
    
    init() {
        setupRX()
    }
    
    func setupRX() {
        self.eAction.bind { (action) in
            switch action {
            case .cancel:
                break
            case .next:
                NotificationCenter.default.post(name: .topUpMoneySuccess, object: nil)
            }
        }.disposed(by: disposeBag)
    }
    
}

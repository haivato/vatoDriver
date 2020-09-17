//  File name   : WithdrawAction.swift
//
//  Author      : Dung Vu
//  Created date: 11/15/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SVProgressHUD
import VatoNetwork
import FwiCore
import FwiCoreRX

protocol WithdrawActionHandlerProtocol {
    var eAction: PublishSubject<WithdrawConfirmAction> { get }
    var errorMessageSubject: Observable<String> { get }
    var didSelectAdd: (() -> Void)? { get set }
}

class PassCodeHandler: NSObject, FCPassCodeViewDelegate {
    private (set) lazy var ePassCode: PublishSubject<String?> = PublishSubject()
    weak var passCodeView: FCPassCodeView? {
        didSet {
            oldValue?.delegate = nil
            oldValue?.removeFromSuperview()
            if self.passCodeView != nil {
                self.passCodeView?.delegate = self
            }
        }
    }
    
    func onReceivePasscode(_ passcode: String!) {
        self.passCodeView = nil
        ePassCode.onNext(passcode)
    }
    
}

struct WithdrawAction: WithdrawActionHandlerProtocol {
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
    let userBankInfo: BankCellModel
    let authToken: Observable<String>
    
    init(controller: UIViewController?, amount: Int, userBankInfo: BankCellModel, authToken: Observable<String>) {
        self.controller = controller
        self.amount = amount
        self.userBankInfo = userBankInfo
        self.authToken = authToken
        
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
    
    private func excute(with code: String) {
        let bankInfoId = userBankInfo.userBankInfo.id
        authToken.take(1)
            .flatMap {  (token) -> Observable<(HTTPURLResponse, MessageDTO<WithdrawOrder>)> in
                return Requester.requestDTO(using: VatoAPIRouter.orderWithdraw(authToken: token,
                                                                           bankInfoId: bankInfoId,
                                                                           amount: self.amount,
                                                                           pin: code),
                                        method: .post,
                                        encoding: JSONEncoding.default,
                                        block: { $0.dateDecodingStrategy = .customDateFireBase })
            }
            .trackActivity(self.indicator)
            .map { $0.1 }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (message) in
                    if !message.fail, message.data != nil {
                        NotificationCenter.default.post(name: Notification.Name("kTransferMoneySuccess"), object: nil)

                        let alertView = UIAlertController(title: "Thành công", message: "Yêu cầu rút tiền của bạn đã được thực hiện thành công.", preferredStyle: .alert)
                        alertView.addAction(UIAlertAction(title: "Đóng", style: .cancel, handler: { _ in
                            self.controller?.navigationController?.popToRootViewController(animated: true)
                        }))
                        self.controller?.navigationController?.visibleViewController?.present(alertView, animated: true, completion: nil)
                    } else {
                        self.handle(errorCode: message.errorCode, resMessage: message.message)
                    }
                },
                onError: { (err) in
                    self.handle(errorCode: "", resMessage: nil)
        }).disposed(by: disposeBag)
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
    
    
    private func handle(errorCode: String?, resMessage: String?) {
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
            var message = "Thực hiện yêu cầu không thành công"
            if code.contains("AgribankTransactionErrorException") ||
                code.contains("RetrieveTransactionFailedException") ||
                code.contains("RetrieveUserInfoFailedException") {
                if let msgCode = resMessage {
                    message = "Thực hiện yêu cầu không thành công\n (Mã lỗi \(msgCode))"
                }
            }
            eError.onNext(message)
        }
    }
}

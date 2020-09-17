//  File name   : NewBankAccountVM.swift
//
//  Author      : Vato
//  Created date: 11/8/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore
import FwiCoreRX
import RxSwift
import Alamofire
import VatoNetwork

enum PinValidation {
    case none
    case yes
    case error
}

final class NewBankAccountVM: ViewModel {
    /// Class's public properties.
    var errorMessage: Observable<String> {
        return errorMessageSubject.asObservable()
    }

    let authToken: Observable<String>
    let doneSubject: ReplaySubject<Void>
    let newUserBankInfoSubject: PublishSubject<UserBankInfo>
    let bankInfos: [BankInfo]
    let fullname: String

    var hasPIN = PinValidation.none
    var passcode: String = ""

    /// Class's constructor.
    init(authToken: Observable<String>, newUserBankInfoSubject: PublishSubject<UserBankInfo>, bankInfos: [BankInfo], fullname: String) {
        self.authToken = authToken
        self.newUserBankInfoSubject = newUserBankInfoSubject
        self.bankInfos = bankInfos
        self.fullname = fullname
        self.doneSubject = ReplaySubject<Void>.create(bufferSize: 1)
        super.init()
    }
    
    // MARK: Class's public override methods
    override func setupRX() {
        authToken.take(1).flatMap { (token) -> Observable<(HTTPURLResponse, MessageDTO<Bool>)> in
            return Requester.requestDTO(using: VatoAPIRouter.checkPin(authToken: token))
        }
        .map { $0.1.data }
        .filterNil()
        .subscribe(
            onNext: { [weak self] (hasPIN) in
                if hasPIN {
                    self?.hasPIN = .yes
                } else {
                    self?.hasPIN = .none
                }
            },
            onError: { [weak self] (err) in
                self?.hasPIN = .error
                self?.errorMessageSubject.onNext("Không thể kết nối với máy chủ được, vui lòng thử lại sau.")
            }
        )
        .disposed(by: disposeBag)
    }

    func addBankInfo(bank: BankInfo, accountOwner: String, accountNumber: String, identityCard: String, completion: (() -> Void)?) {
        _ = authToken.take(1).flatMap { [weak self] (token) -> Observable<(HTTPURLResponse, MessageDTO<UserBankInfo>)> in
            return Requester.requestDTO(using: VatoAPIRouter.addBankInfo(authToken: token, bankCode: bank.bankId, bankAccount: accountNumber, accountName: accountOwner, identityCard: identityCard, pin: self?.passcode ?? ""),
                                        method: .post,
                                        encoding: JSONEncoding.default,
                                        block: { $0.dateDecodingStrategy = .customDateFireBase })
        }
        .map { $0.1 }
        .subscribe(
            onNext: { [weak self] (message) in
                if !message.fail, let userBankInfo = message.data {
                    self?.newUserBankInfoSubject.onNext(userBankInfo)
                    self?.doneSubject.onNext(())
                } else {
                    self?.handle(errorCode: message.errorCode, resMessage: message.message)
                }
                completion?()
            },
            onError: { [weak self](err) in
                self?.handle(errorCode: "", resMessage: nil)
                completion?()
            }
        )
    }

    /// Class's private properties.
    private let errorMessageSubject = ReplaySubject<String>.create(bufferSize: 1)
}

// MARK: Class's public methods
extension NewBankAccountVM {
}

// MARK: Class's private methods
private extension NewBankAccountVM {
    private func handle(errorCode: String?, resMessage: String?) {
        let code = errorCode ?? ""
        switch code {
        case "io.vato.apiv3.service.exception.ReachMaxBankInfoException":
            errorMessageSubject.onNext("Không thể thêm tài khoản ngân hàng được nữa.")

        case "io.vato.apiv3.service.exception.UserBankInfoAlreadyExistedException":
            errorMessageSubject.onNext("Thông tin ngân hàng đã tồn tại.")

        case "io.vato.apiv3.service.exception.MembershipServiceException":
            errorMessageSubject.onNext("Mật khẩu giao dịch không tồn tại.")

        case "io.vato.apiv3.service.exception.CantVerifyPinException":
            errorMessageSubject.onNext("Mật khẩu giao dịch không đúng.")

        case "io.vato.apiv3.service.exception.IllegalBankCodeException":
            errorMessageSubject.onNext("Thông tin ngân hàng không tồn tại.")
        
        case "io.vato.apiv3.service.exception.IdentityCardIsMissingForUserException":
            errorMessageSubject.onNext("Thiếu thông tin cmnd.")
            
        case "io.vato.apiv3.service.exception.DriverLicenseIsMissingForUserException":
            errorMessageSubject.onNext("Thiếu thông tin bằng lái xe , xe máy hoặc xe hơi.")
            
        case "io.vato.apiv3.service.exception.InvalidBankAccountException":
            errorMessageSubject.onNext("Thông tin số tài khoản ngân hàng chưa đúng. Vui lòng điều chỉnh lại.")
            
        case "io.vato.apiv3.service.exception.InvalidBankNameException":
            errorMessageSubject.onNext("Tên chủ tài khoản chưa đúng. Vui lòng liên hệ 1900 6667 để thay đổi.")
            
        case "io.vato.apiv3.service.exception.AgribankUserInfoErrorException":
            errorMessageSubject.onNext("Thông tin cung cấp chưa đúng. Vui lòng điều chỉnh lại.")

        default:
            var message = "Thực hiện yêu cầu không thành công"
            if code.contains("AgribankTransactionErrorException") ||
               code.contains("RetrieveTransactionFailedException") ||
               code.contains("RetrieveUserInfoFailedException") {
                if let msgCode = resMessage {
                    message = "Thực hiện yêu cầu không thành công\n (Mã lỗi \(msgCode))"
                }
            }
            
            errorMessageSubject.onNext(message)
        }
    }
}

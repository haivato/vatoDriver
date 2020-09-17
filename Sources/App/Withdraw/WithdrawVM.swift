//  File name   : WithdrawVM.swift
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
import Firebase
import VatoNetwork

final class WithdrawVM: ViewModel {
    /// Class's public properties.
    var authToken: Observable<String> {
        return firebaseAuthTokenSubject.asObservable()
    }

    var bankInfos: Observable<[BankInfo]> {
        return bankInfosSubject.asObservable()
    }

    var data: Observable<(String, [BankCellModel])> {
        let o1 = bankInfosSubject.asObservable()
        let o2 = userBankInfosSubject.asObservable()

        return Observable<(String, [BankCellModel])>.combineLatest(o1, o2) { [weak self] (bankInfos, userBankInfos) in
            userBankInfos.forEach { (model) in
                model.bankInfo = bankInfos.first(where: { $0.bankId == model.userBankInfo.bankCode })
            }
            return (self?.cash.currency ?? "", userBankInfos)
        }
    }

    let newUserBankInfoSubject = PublishSubject<UserBankInfo>()
    let selectedUserBankInfoSubject = PublishSubject<BankCellModel>()

    /// Class's constructors.
    init(with cash: Int64) {
        self.cash = cash
        super.init()

        // Register authentication
        Auth.auth().addIDTokenDidChangeListener { [weak self] (auth, user) in
            self?.getFirebaseAuthToken(user: user)
        }
    }

    /// Class's destructor.
    deinit {
        if let handler = handler {
            Auth.auth().removeIDTokenDidChangeListener(handler)
        }
    }

    // MARK: Class's public override methods
    override func setupRX() {
        newUserBankInfoSubject.bind { [weak self] (newUserBankInfo) in
            _ = self?.userBankInfosSubject.take(1).bind(onNext: { (current) in
                current.forEach { $0.isSelected = false }

                let newItem = BankCellModel(userBankInfo: newUserBankInfo)
                newItem.isSelected = true

                var newList = current + [newItem]
                newList.sort(by: <)

                self?.userBankInfosSubject.onNext(newList)
            })
        }
        .disposed(by: disposeBag)

        selectedUserBankInfoSubject.bind { [weak self] (model) in
            _ = self?.userBankInfosSubject.take(1).bind(onNext: { (current) in
                current.forEach { $0.isSelected = false }
                model.isSelected = true
                
                self?.userBankInfosSubject.onNext(current)
            })
        }
        .disposed(by: disposeBag)

        let o: Observable<(HTTPURLResponse, [BankInfo])> = Requester.requestDTO(using: VatoAPIRouter.listBank)
        _ = o.take(1)
            .map { $0.1 }
            .subscribe(
                onNext: { [weak self] (bankInfos) in
                    self?.bankInfosSubject.onNext(bankInfos.sorted(by: <))
                },
                onError: { [weak self] (err) in
                    self?.bankInfosSubject.onNext([])
                    printDebug(err)
                }
            )

        _ = firebaseAuthTokenSubject
            .take(1)
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, MessageDTO<[UserBankInfo]>)> in
                return Requester.requestDTO(using: VatoAPIRouter.listBankInfos(authToken: authToken))
            }
            .map { $0.1.data }
            .filterNil()
            .subscribe(
                onNext: { [weak self] (userBankInfos) in
                    let list = userBankInfos.sorted(by: <).map { BankCellModel(userBankInfo: $0) }
                    list.first?.isSelected = true

                    self?.userBankInfosSubject.onNext(list)
                },
                onError: { [weak self] (err) in
                    self?.userBankInfosSubject.onNext([])
                    printDebug(err)
                }
            )
    }
    
    /// Class's private properties.
    private let cash: Int64
    private let firebaseAuthTokenSubject = ReplaySubject<String>.create(bufferSize: 1)

    private let bankInfosSubject = ReplaySubject<[BankInfo]>.create(bufferSize: 1)
    private let userBankInfosSubject = ReplaySubject<[BankCellModel]>.create(bufferSize: 1)

    private var handler: IDTokenDidChangeListenerHandle?
}

// MARK: Class's public methods
extension WithdrawVM {
}

// MARK: Class's private methods
private extension WithdrawVM {
    private func getFirebaseAuthToken(user: User?) {
        guard let user = user else {
            return
        }

        user.getIDToken { [weak self] (token, err) in
            guard err == nil, let token = token else {
                return
            }
            self?.firebaseAuthTokenSubject.onNext(token)
        }
    }
}

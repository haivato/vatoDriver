//  File name   : WalletAddNewBankVC.swift
//
//  Author      : MacbookPro
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import FwiCoreRX
import AXPhotoViewer

protocol WalletAddNewBankPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBackWalletTrip()
    func moveListBank()
    func showAlert(text: String)
    func userAddBank(pin: String)
    func moveWalletTrip()
    func moveWalletTripAddBankSuccess()
    var listBankObser: Observable<[BankInfoServer]> {get}
    var itemBankObser: Observable<BankInfoServer> {get}
    var displayNameObser: Observable<String> { get }
    var isPin: Observable<Bool> { get }
    var userAddBank: UserAddBank  {get set}
    var isAddSuccess: Observable<(Bool, String)> { get }
    var userBank: Observable<UserBankInfo> { get }
    var eLoadingObser: Observable<(Bool,Double)> { get }
}

final class WalletAddNewBankVC: FormViewController, WalletAddNewBankPresentable, WalletAddNewBankViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: WalletAddNewBankPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        //        controllerDetail?.listener = listener
        
    }
    private let disposeBag = DisposeBag()
    private var submitBtn: UIButton = UIButton(type: .custom)
    private var listBank: [BankInfoServer] = []
    private var itemBank: BankInfoServer?
    private var displayName: String = ""
    private var isPin: Bool = false
    private var passcodeView = VatoVerifyPasscodeObjC()
    private var userBank: UserBankInfo?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        setupRX()
    }
    
    /// Class's private properties.
}

// MARK: View's event handlers
extension WalletAddNewBankVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension WalletAddNewBankVC {
}

// MARK: Class's private methods
private extension WalletAddNewBankVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let buttonLeft = visualizeButtonLeft()
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBackWalletTrip()
        }).disposed(by: disposeBag)
        
        visualizeWhiteNavigationBar(titleStr: "Thêm tài khoản ngân hàng")
        
        UIView.performWithoutAnimation {
            self.form += [gensection()]
        }
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let _viewBgNext = UIView(frame: .zero) >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
                make.height.equalTo(78)
            })
        }
        
        // table view
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalTo(_viewBgNext.snp.top)
                
            })
        }
        
        let button = UIButton(frame: .zero)
        button >>> _viewBgNext >>> {
            $0.setBackground(using: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), state: .normal)
            $0.setBackground(using: .gray, state: .disabled)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setTitle("GỬI YÊU CẦU HỖ TRỢ", for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(10)
                make.height.equalTo(48)
            })
        }
        self.submitBtn = button
        self.submitBtn.isEnabled = false
        self.submitBtn.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        
    }
    
    private func setupRX() {
        listener?.isPin.bind(onNext: weakify { (isPin, wSelf) in
            wSelf.isPin = isPin
        }).disposed(by: disposeBag)
        
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        listener?.userBank.bind(onNext: weakify { (user, wSelf) in
            wSelf.userBank = user
            wSelf.submitBtn.isEnabled = true
            wSelf.submitBtn.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            if user.verified ?? false {
                wSelf.submitBtn.isEnabled = false
                wSelf.submitBtn.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            } else {
                wSelf.submitBtn.setTitle("Cập nhật tài khoản", for: .normal)
            }
            
            wSelf.form.removeAll()
            wSelf.tableView.reloadData()
            UIView.performWithoutAnimation {
                wSelf.form += [wSelf.gensection()]
            }
        
            self.title = user.bankInfo?.bankShortName
        }).disposed(by: disposeBag)
        
        listener?.isAddSuccess.bind(onNext: weakify { (addSuccess, wSelf) in
            (addSuccess.0) ? wSelf.showAlerSuccess(text: addSuccess.1) : self.listener?.showAlert(text: addSuccess.1)
        }).disposed(by: disposeBag)
        
        listener?.listBankObser.bind(onNext: weakify { (listBankUser, wSelf) in
            wSelf.listBank = listBankUser
            wSelf.form.removeAll()
            wSelf.tableView.reloadData()
            UIView.performWithoutAnimation {
                wSelf.form += [wSelf.gensection()]
            }
        }).disposed(by: disposeBag)
        
        listener?.displayNameObser.bind(onNext: weakify { (name, wSelf) in
            wSelf.displayName = name
            wSelf.form.removeAll()
            wSelf.tableView.reloadData()
            UIView.performWithoutAnimation {
                wSelf.form += [wSelf.gensection()]
            }
        }).disposed(by: disposeBag)
        
        listener?.itemBankObser.bind(onNext: weakify { (item, wSelf) in
            wSelf.itemBank = item
            wSelf.form.removeAll()
            wSelf.tableView.reloadData()
            UIView.performWithoutAnimation {
                wSelf.form += [wSelf.gensection()]
            }
        }).disposed(by: disposeBag)
        
        self.submitBtn.rx.tap.bind { _ in
            if self.isPin {
                self.getPin()
            } else {
                self.listener?.showAlert(text: Text.needToCreatePw.localizedText)
            }
        }.disposed(by: disposeBag)
        
    }
    private func showAlerSuccess(text: String) {
        let alert: UIAlertController = UIAlertController(title: "Thông báo",
                                                         message: text,
                                                         preferredStyle: .alert)
        let btConfirm: UIAlertAction = UIAlertAction(title: "Đóng", style: .default) { _ in
            self.listener?.moveWalletTripAddBankSuccess()
        }
        alert.addAction(btConfirm)
        self.present(alert, animated: true, completion: nil)
    }
    private func getPin() {
        passcodeView.passcode(on: self, type: .notVerify, forgot: { (value) in
            if let url = URL(string: "tel://\(1900667)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }) { (pin, isVerify) in
            guard let pin = pin else  { return }
            self.listener?.userAddBank(pin: pin)
        }
    }
    
    
    private func gensection() -> Section   {
        
        self.tableView.separatorStyle = .none
        
        let section = Section("") { (s) in
            s.tag = "InputInfor"
            // header
            s.header?.height = { 0.1 }
            if let user = self.userBank{
                var header = HeaderFooterView<UIView>(.callback {
                    let v = UIView()
                    
                    let imgValid: UIImageView = UIImageView(frame: .zero)
                    
                    v.addSubview(imgValid)
                    imgValid.snp.makeConstraints { (make) in
                        //                        make.top.equalToSuperview().inset(12)
                        make.left.equalToSuperview().inset(16)
                        make.width.height.equalTo(24)
                    }
                    
                    let label = UILabel()
                    label >>> v >>> {
                        $0.numberOfLines = 0
                        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                        $0.snp.makeConstraints {
                            $0.right.equalToSuperview().inset(10)
                            //                            $0.top.equalToSuperview().inset(12)
                            $0.left.equalTo(imgValid.snp.right).inset(-10)
                        }
                    }
                    
                    if user.verified ?? false {
                        v.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 0.1)
                        label.textColor = #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 1)
                        label.text = "Tài khoản đã được xác thực. Không nên thay đổi thông tin ảnh hưởng tới việc rút doanh thu"
                        imgValid.image = UIImage(named: "ic_bank_valid")
                        label.snp.makeConstraints { (make) in
                            make.top.equalToSuperview().inset(12)
                        }
                        imgValid.snp.makeConstraints { (make) in
                            make.top.equalToSuperview().inset(12)
                        }
                    } else {
                        imgValid.image = UIImage(named: "ic_bank_invalid")
                        v.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.1)
                        label.textColor =  #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
                        label.text = "Tài khoản chưa xác thực"
                        label.snp.makeConstraints { (make) in
                            make.centerY.equalToSuperview()
                        }
                        imgValid.snp.makeConstraints { (make) in
                            make.centerY.equalToSuperview()
                        }
                    }
                    
                    
                    return v
                    })
                header.height = { 56 }
                s.header = header
            } else {
                let footer = HeaderFooterView<UIView>(.callback {
                    let v = UIView()
                    let label = UILabel()
                    label >>> v >>> {
                        $0.numberOfLines = 0
                        $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
                        $0.text = "Lưu ý:\n- Tài khoản ngân hàng chỉ được thêm một lần duy nhất\n- Nếu có thay đổi thông tin, vui lòng gọi tổng đài 19006667 để được hướng dẫn"
                        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                        $0.snp.makeConstraints {
                            $0.left.right.equalTo(10)
                            $0.top.equalTo(16)
                        }
                    }
                    return v
                    })
                
                s.footer = footer
            }
            
        }
        
        section <<< RowDetailGeneric<WalletTripBankCell>.init(QSFillInformationCellType.title.rawValue, { (row) in
            row.cell.update(title: "Ngân hàng", placeHolder: self.itemBank?.bankShortName ?? "")
            row.cell.textField.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            if self.userBank != nil {
                row.cell.textField.isEnabled =  false
                row.cell.textField.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
                row.cell.imgDropdown.isHidden = true
                row.cell.btPress.isEnabled = false
            }
            row.cell.didSelectAdd = {
                self.listener?.moveListBank()
            }
            row.onRowValidationChanged { [weak self] _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = "Ngân hàng không được bỏ trống."
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self?.validate(row: row)
            }
        })
        
        // title
        section <<< RowDetailGeneric<RequestQuickSupportInputCell>.init("accountNumber", { (row) in
            row.cell.update(title: "Số tài khoản", placeHolder: self.userBank?.bankAccount ?? "Số tài khoản")
            if let user = self.userBank {
                row.value = user.bankAccount
                row.cell.textField.text = user.bankAccount
                row.cell.textField.isEnabled = (user.verified ?? false) ? false : true
                row.cell.textField.textColor = (user.verified ?? false) ? #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1) : .black
            } else {
                row.value = ""
            }
            row.add(rule: RuleMinLength(minLength: 4, msg: "Thông tin tối thiểu 4 ký tự.", id: "min required"))
            row.add(rule: RuleRegExp(regExpr: "^[0-9A-Za-z]+$", allowsEmpty: false, msg: "Số tài khoản không được chứa kí tự đặc biệt.", id: "invalidAccountNumber"))
            row.cell.textField.rx.text.bind { [weak self] (_) in
                guard let wSelf = self else { return }
                wSelf.listener?.userAddBank.bankAccount = row.value ?? ""
            }.disposed(by: disposeBag)
            row.cell.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
                .asObservable()
                .subscribe(onNext: { _ in
                    row.cell.textField.placeholder = ""
                }).disposed(by: disposeBag)
            row.onRowValidationChanged { [weak self] _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = "Thông tin tối thiểu 4 ký tự."
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self?.validate(row: row)
            }
        })
        section <<< RowDetailGeneric<RequestQuickSupportInputCell>.init(QSFillInformationCellType.title.rawValue, { (row) in
            row.cell.update(title: "Số CMND", placeHolder: self.userBank?.idCard ?? "Nhập số chứng minh thư")
            if let user = self.userBank {
                row.value = user.idCard
                row.cell.textField.text = user.idCard
                row.cell.textField.isEnabled = (user.verified ?? false) ? false : true
                row.cell.textField.textColor = (user.verified ?? false) ? #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1) : .black
            } else {
                row.value = ""
            }
            row.add(ruleSet: NewBankAccountRules.rules())
            row.add(rule: RuleRegExp(regExpr: "^[0-9A-Za-z]+$", allowsEmpty: false, msg: "Chứng minh thư không được chứa kí tự đặc biệt.", id: "invalidIdentityCard"))
            row.cell.textField.rx.text.bind { [weak self] (_) in
                guard let wSelf = self else { return }
                wSelf.listener?.userAddBank.identityCard = row.value ?? ""
            }.disposed(by: disposeBag)
            row.cell.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
                .asObservable()
                .subscribe(onNext: { _ in
                    row.cell.textField.placeholder = ""
                })
                .disposed(by: disposeBag)
            row.onRowValidationChanged { [weak self] _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = "Chứng minh thư không được không hợp lệ."
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self?.validate(row: row)
            }
        })
        
        section <<< RowDetailGeneric<WalletAccountNameCell>.init(QSFillInformationCellType.title.rawValue, { (row) in
            row.cell.update(title: "Tên chủ tài khoản", placeHolder: self.userBank?.accountName ?? self.displayName)
            row.add(ruleSet: NewBankAccountRules.rules())
            row.add(rule: RuleMinLength(minLength: 5, msg: "Thông tin tối thiểu 5 ký tự.", id: "min required"))
            if let user = self.userBank {
                row.value = user.accountName
                row.cell.textField.text = user.accountName
                row.cell.textField.isEnabled = (user.verified ?? false) ? false : true
                row.cell.textField.textColor = (user.verified ?? false) ? #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1) : .black
            } else {
                row.value = self.displayName
            }
            row.cell.textField.isUserInteractionEnabled = false
            row.cell.textField.rx.text.bind { [weak self] (_) in
                guard let wSelf = self else { return }
                wSelf.listener?.userAddBank.accountName = row.value ?? ""
            }.disposed(by: disposeBag)
            row.cell.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
                .asObservable()
                .subscribe(onNext: { _ in
                    row.cell.textField.placeholder = ""
                })
                .disposed(by: disposeBag)
            row.onRowValidationChanged { [weak self] _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = "Thông tin tối thiểu 5 ký tự."
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self?.validate(row: row)
            }
        })
        
        return section
    }
    func validate(row: BaseRow?) {
        let errors = form.validate()
        self.submitBtn.isEnabled = errors.isEmpty
    }
}

//  File name   : NewBankAccountVC.swift
//
//  Author      : Vato
//  Created date: 11/8/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SVProgressHUD
import FirebaseAuth
import RxSwift

final class NewBankAccountVC: FormViewController {
    @IBOutlet weak var doneButton: UIButton!

    /// Class's public properties.

    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(authToken: Observable<String>, newUserBankInfoSubject: PublishSubject<UserBankInfo>, bankInfos: [BankInfo], fullname: String) {
        self.viewModel = NewBankAccountVM(authToken: authToken, newUserBankInfoSubject: newUserBankInfoSubject, bankInfos: bankInfos, fullname: fullname)
        super.init(nibName: "\(NewBankAccountVC.self)", bundle: nil)
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()

        form +++ Section()
            <<< BankPushRow("bank") { [weak self] in
                $0.options = self?.viewModel.bankInfos ?? []
                $0.value = self?.viewModel.bankInfos.first
                $0.add(rule: RuleRequired(msg: "Ngân hàng không được bỏ trống."))

                $0.onChange { [weak self] _ in
                    self?.validateForm()
                }
            }
            <<< MasterTextFieldRow("accountNumber") {
                $0.title = "Số tài khoản"
                $0.placeholder = "Số tài khoản"
                $0.value = ""
                $0.add(rule: RuleRequired(msg: "Số tài khoản không được bỏ trống."))
                $0.add(rule: RuleMinLength(minLength: 4, msg: "Thông tin tối thiểu 4 ký tự.", id: "min required"))
                $0.add(rule: RuleRegExp(regExpr: "^[0-9A-Za-z]+$", allowsEmpty: false, msg: "Số tài khoản không được chứa kí tự đặc biệt.", id: "invalidAccountNumber"))
                $0.onChange { [weak self] _ in
                    self?.validateForm()
                }
            }
            <<< MasterTextFieldRow("identityCard") {
                $0.title = "Số CMND"
                $0.placeholder = "Nhập số chứng minh thư"
                $0.value = ""
                $0.add(ruleSet: NewBankAccountRules.rules())
                $0.add(rule: RuleRegExp(regExpr: "^[0-9A-Za-z]+$", allowsEmpty: false, msg: "Chứng minh thư không được chứa kí tự đặc biệt.", id: "invalidIdentityCard"))
                $0.onChange { [weak self] _ in
                    self?.validateForm()
                }
            }
            <<< MasterNameFieldRow("accountOwner") { [weak self] in
                $0.disabled = true
                $0.title = "Tên chủ tài khoản"
                $0.placeholder = "Tên chủ tài khoản"
                $0.value = self?.viewModel.fullname.uppercased()
            }
            <<< LabelRow() {
                $0.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = EurekaConfig.titleFont
                    cell.textLabel?.textColor = EurekaConfig.titleColor
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.lineBreakMode = .byWordWrapping
                })
                $0.title = "Tên chủ tài khoản phải trùng với tên của tài khoản VATO\nLưu ý:\n- Tài khoản ngân hàng chỉ được thêm một lần duy nhất.\n- Nếu có thay đổi thông tin, vui lòng gọi tổng đài 1900 6667 để được hướng dẫn."
            }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private var viewModel: NewBankAccountVM
    private var passcodeView: FCPassCodeView?

    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(NewBankAccountVC.handleBackItemOnPressed(_:)))
        return item
    }()
}

// MARK: View's event handlers
extension NewBankAccountVC {
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return .all
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // todo: Transfer data between views during presentation here.
    }

//    @IBAction func unwindTo(NewBankAccountVC segue: UIStoryboardSegue) {
//    }
}

// MARK: View's key pressed event handlers
extension NewBankAccountVC {
    @IBAction func handleBackItemOnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func handleDoneButtonOnPressed(_ sender: Any) {
        guard form.validate().count <= 0 else {
            return
        }

        if viewModel.hasPIN == .none {
            let alertView = UIAlertController(title: "Thông báo",
                                              message: "Bạn cần tạo mật khẩu thanh toán để sử dụng chức năng này. Tạo mật khẩu?",
                                              preferredStyle: .alert)

            alertView.addAction(UIAlertAction(title: "Bỏ qua", style: .destructive, handler: nil))
            alertView.addAction(UIAlertAction(title: "Đồng ý", style: .default, handler: { [weak self] _ in
                let controller = FCPasscodeViewController(nibName: "\(FCPasscodeViewController.self)", bundle: nil)
                controller.hasPIN = false
                controller.delegate = self
                self?.navigationController?.pushViewController(controller, animated: true)
            }))
            present(alertView, animated: true, completion: nil)
        } else if viewModel.hasPIN == .error {
            let alertView = UIAlertController(title: "Thông báo", message: "Không thể kết nối với máy chủ được, vui lòng thử lại sau.", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Đóng", style: .destructive, handler: nil))
            present(alertView, animated: true, completion: nil)
        } else {
            if passcodeView != nil {
                passcodeView?.removeFromSuperview()
                passcodeView = nil
            }

            passcodeView = FCPassCodeView(view: self)
            passcodeView?.lblTitle.text = "Nhập mật khẩu thanh toán"
            passcodeView?.setupView(PasscodeType(rawValue: 0))
            passcodeView?.delegate = self

            guard let v = passcodeView else {
                return
            }
            view.addSubview(v)
        }
    }
}

// MARK: Class's public methods
extension NewBankAccountVC: FormHandlerProtocol, FCPasscodeViewControllerDelegate, FCPassCodeViewDelegate {
    func cancelForm() {
    }

    func execute(input: [String : Any?], completion: (() -> Void)?) {
        guard
            let bank = input["bank"] as? BankInfo,
            let accountOwner = input["accountOwner"] as? String,
            let accountNumber = input["accountNumber"] as? String,
            let identityCard = input["identityCard"] as? String
        else {
            completion?()
            return
        }
        viewModel.addBankInfo(bank: bank,
                              accountOwner: accountOwner.trim(),
                              accountNumber: accountNumber.trim(),
                              identityCard: identityCard.trim(),
                              completion: completion)
    }

    func passcodeViewController(_ controller: FCPasscodeViewController!, passcode: String?) {
        navigationController?.popToViewController(self, animated: true)
        viewModel.passcode = passcode ?? ""
        viewModel.hasPIN = .yes

        execute(form: form, prefixAction: {
            SVProgressHUD.show(withStatus: "Đang cập nhật thông tin...")
        }) { [weak self] in
            self?.validateFinish()
        }
    }

    @objc func onReceivePasscode(_ passcode: String!) {
        passcodeView?.removeFromSuperview()
        viewModel.passcode = passcode ?? ""
        viewModel.hasPIN = .yes

        execute(form: form, prefixAction: {
            SVProgressHUD.show(withStatus: "Đang cập nhật thông tin...")
        }) { [weak self] in
            self?.validateFinish()
        }
    }
}

// MARK: Class's private methods
private extension NewBankAccountVC {
    private func localize() {
        title = "Thêm tài khoản"
    }
    private func visualize() {
        navigationItem.leftBarButtonItems = [backItem]

        var frame = tableView.frame
        frame.size.height = 1.0
        tableView.tableHeaderView = UIView(frame: frame)

        // Disable button
        let background = #imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate)
        doneButton.setBackgroundImage(background, for: .normal)
        doneButton.isEnabled = false
        doneButton.tintColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
    }
    private func setupRX() {
        viewModel.errorMessage
            .delay(0.3, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (message) in
                let alertView = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Đóng", style: .destructive, handler: nil))
                self?.present(alertView, animated: true, completion: nil)
            }
            .disposed(by: viewModel.disposeBag)

        // Setup view model
        viewModel.setupRX()
    }

    private func validateFinish() {
        SVProgressHUD.dismiss(completion: { [weak self] in
            _ = self?.viewModel.doneSubject
                .take(1)
                .timeout(5.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(
                    onNext: { (_) in
                        let alertView = UIAlertController(title: "Thông báo", message: "Bạn đã tạo liên kết ngân hàng thành công.", preferredStyle: .alert)
                        alertView.addAction(UIAlertAction(title: "Đóng", style: .destructive, handler: { _ in
                                self?.navigationController?.popViewController(animated: true)
                        }))
                        self?.present(alertView, animated: true, completion: nil)
                },
                    onDisposed: {
                        debugPrint("Disposed.")
                }
            )
        })
    }

    private func validateForm() {
        guard form.validate().count <= 0 else {
            // Disable button
            let background = #imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate)
            doneButton.setBackgroundImage(background, for: .normal)
            doneButton.isEnabled = false
            doneButton.tintColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            return
        }

        // Enable button
        let background = #imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate)
        doneButton.setBackgroundImage(background, for: .normal)
        doneButton.isEnabled = true
        doneButton.tintColor = EurekaConfig.originNewColor
    }
}

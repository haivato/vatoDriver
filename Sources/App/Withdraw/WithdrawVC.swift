//  File name   : WithdrawVC.swift
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
import RxSwift

final class WithdrawVC: FormViewController {
    @IBOutlet weak var continueButton: UIButton!

    /// Class's public properties.
    @objc var fullname: String = ""
    @objc var cash: Int64 = 0

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()

        validateForm()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    override func insertAnimation(forRows rows: [BaseRow]) -> UITableView.RowAnimation {
        return .none
    }
    override func insertAnimation(forSections sections: [Section]) -> UITableView.RowAnimation {
        return .none
    }
    /// Class's private properties.
    private lazy var viewModel = WithdrawVM(with: cash)

    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(WithdrawVC.handleBackItemOnPressed(_:)))
        return item
    }()
}

// MARK: View's event handlers
extension WithdrawVC {
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

//    @IBAction func unwindTo(WithdrawVC segue: UIStoryboardSegue) {
//    }
}

// MARK: View's key pressed event handlers
extension WithdrawVC {
    @IBAction func handleBackItemOnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func handleLinkBankAccountButtonOnPressed(_ sender: Any) {
        _ = viewModel.bankInfos.take(1).observeOn(MainScheduler.instance)
            .bind { [weak self] (bankInfos) in
                guard
                    let authToken = self?.viewModel.authToken,
                    let subject = self?.viewModel.newUserBankInfoSubject
                else {
                    return
                }

                let controller = NewBankAccountVC(authToken: authToken, newUserBankInfoSubject: subject, bankInfos: bankInfos, fullname: self?.fullname ?? "")
                self?.navigationController?.pushViewController(controller, animated: true)
            }
    }

    @IBAction func handleContinueButtonOnPressed(_ sender: Any) {
        execute(form: form, prefixAction: {
//            SVProgressHUD.show(withStatus: "Đang xử lý...")
        }) {
//            SVProgressHUD.dismiss()
        }
    }
}

// MARK: Class's public methods
extension WithdrawVC: FormHandlerProtocol {
    func cancelForm() {
    }

    func execute(input: [String : Any?], completion: (() -> Void)?) {
        let userBankInfos: [BankCellModel] = input.compactMap { item -> BankCellModel? in
            return (item.key.hasPrefix("user_bank_info") ? (item.value as? BankCellModel) : nil)
        }

        guard
            let userBankInfo = userBankInfos.first(where: { $0.isSelected }),
            let bankName = userBankInfo.bankInfo?.bankShortName,
            let amount = input["amount"] as? Int
        else {
            completion?()
            return
        }

        let items = [WithdrawConfirmItem(title: "Rút tiền", message: amount.currency, iconName: nil),
                     WithdrawConfirmItem(title: "Số dư khả dụng", message: cash.currency, iconName: nil),
                     WithdrawConfirmItem(title: "Ngân hàng", message: bankName, iconName: nil),
                     WithdrawConfirmItem(title: "Tổng tiền rút", message: amount.currency, iconName: nil)]
        let action = WithdrawAction(controller: self, amount: amount, userBankInfo: userBankInfo, authToken: viewModel.authToken)
        let vc = WithdrawConfirmVC({ return items }, title: "Rút tiền", handler: action)
//        vc.action.bind { [weak self] (type) in
//            self?.navigationController?.popViewController(animated: true)
//        }
//        .disposed(by: viewModel.disposeBag)

        self.navigationController?.pushViewController(vc, animated: true)
        completion?()
    }
}

// MARK: Class's private methods
private extension WithdrawVC {
    private func localize() {
        title = "Rút tiền"
    }
    private func visualize() {
        navigationItem.leftBarButtonItems = [backItem]
        
        var frame = tableView.frame
        frame.size.height = 1.0
        tableView.tableHeaderView = UIView(frame: frame)

        let indicatorView = UIActivityIndicatorView(style: .gray)
        tableView.backgroundView = indicatorView
        indicatorView.startAnimating()
    }
    private func setupRX() {
        viewModel.data.observeOn(MainScheduler.instance)
            .bind { [weak self] (currentCash, userBankInfos) in
                guard let form = self?.form else {
                    return
                }
                UIView.performWithoutAnimation {
                    self?.tableView.backgroundView = nil
                    form.removeAll()
                    
                    form
                        +++ Section()
                        <<< MasterTextFieldRow() {
                            $0.disabled = true
                            $0.title = "Số dư khả dụng"
                            $0.value = currentCash
                            
                            $0.cellUpdate({ (cell, _) in
                                cell.titleLabel.textColor = EurekaConfig.titleColor
                                cell.textField.textColor = EurekaConfig.primaryColor
                            })
                    }
                    
                    let section = Section() { section in
                        var header = HeaderFooterView<UIView>(.callback { UIView() })
                        header.onSetupView = { (view, _) in
                            let label = UILabel()
                            label >>> view >>> {
                                $0.textColor = EurekaConfig.titleColor
                                $0.font = EurekaConfig.titleFont
                                $0.text = "Ngân hàng liên kết"
                                $0.snp.makeConstraints {
                                    $0.edges.equalTo(UIEdgeInsets(top: 0.0, left: EurekaConfig.paddingLeft, bottom: 0.0, right: 0.0))
                                }
                            }
                        }
                        section.header = header

                        if userBankInfos.count < 2 {
                            var footer = HeaderFooterView<UIView>(.callback { UIView() })
                            footer.onSetupView = { (view, _) in
                                let button = UIButton(type: .system)
                                button >>> view >>> {
                                    $0.tintColor = EurekaConfig.primaryColor
                                    $0.backgroundColor = .white
                                    $0.setImage(#imageLiteral(resourceName: "ic_plus"), for: .normal)
                                    $0.setTitle("  Thêm tài khoản", for: .normal)
                                    $0.borderColor = EurekaConfig.primaryColor
                                    $0.borderWidth = 1.0
                                    $0.cornerRadius = 8.0

                                    $0.snp.makeConstraints {
                                        $0.leading.equalToSuperview().inset(EurekaConfig.paddingLeft)
                                        $0.bottom.equalToSuperview().inset(30.0)
                                        $0.width.greaterThanOrEqualTo(150.0)
                                        $0.height.equalTo(32.0)
                                    }
                                }
                                button.addTarget(self, action: #selector(WithdrawVC.handleLinkBankAccountButtonOnPressed(_:)), for: .touchUpInside)
                            }
                            footer.height = { 80.0 }
                            section.footer = footer
                        }
                    }
                    form +++ section
                    
                    for (idx, userBankInfo) in userBankInfos.enumerated() {
                        section <<< BankRow("user_bank_info_\(idx)") {
                            $0.value = userBankInfo
                            $0.onCellSelection({ (cell, row) in
                                guard let model = row.value, let subject = self?.viewModel.selectedUserBankInfoSubject else {
                                    return
                                }
                                
                                let controller = BankInfoVC(with: model, selectedUserBankInfoSubject: subject)
                                self?.navigationController?.pushViewController(controller, animated: true)
                            })
                        }
                    }

                    let withdrawSection = Section() { section in
                        var header = HeaderFooterView<UIView>(.callback { UIView() })
                        header.onSetupView = { (view, _) in
                            let label = UILabel()
                            label >>> view >>> {
                                $0.textColor = EurekaConfig.titleColor
                                $0.font = EurekaConfig.titleFont
                                $0.text = "Số tiền cần rút"
                                $0.snp.makeConstraints {
                                    $0.edges.equalTo(UIEdgeInsets(top: 0.0, left: EurekaConfig.paddingLeft, bottom: 0.0, right: 0.0))
                                }
                            }
                        }
                        section.header = header

                        var footer = HeaderFooterView<UIView>(.callback { UIView() })
                        var h: CGFloat = 0
                        footer.onSetupView = { (view, _) in
                            let label = UILabel()
                            label >>> view >>> {
                                $0.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
                                $0.font = UIFont.systemFont(ofSize: 14.0)
                                $0.text = "Yêu cầu RÚT TIỀN sẽ được gửi VATO xử lý. Sau khi giao dịch thành công, bạn sẽ nhận được thông báo thông qua ứng dụng."
                                $0.numberOfLines = 0
                                $0.snp.makeConstraints {
                                    $0.edges.equalTo(UIEdgeInsets(top: 12.0, left: EurekaConfig.paddingLeft, bottom: 0.0, right: 12))
                                }
                            }
                            h = view.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: CGFloat.infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
                        }
                        section.footer = footer
                        section.footer?.height = { h }
                        
                    }
                    defer { form +++ withdrawSection }
                    
                    let finalMax = Double(self?.cash ?? 0)
                    if let selectedCell = userBankInfos.first(where: { $0.isSelected }), let bankInfo = selectedCell.bankInfo {
                        let minValue = bankInfo.min
                        
                        withdrawSection <<< WithdrawRow("amount") {
                            $0.cash = self?.cash ?? 0
                            $0.placeholder = "Số tiền khác"
                            $0.add(ruleSet: RulesWidthdraw.rules(minValue: RulesWidthdraw.Value(minValue), maxValue: RulesWidthdraw.Value(finalMax), maxOption: RulesWidthdraw.Value(bankInfo.max)))
                            $0.onChange { _ in
                                self?.validateForm()
                            }
                            $0.update(by: bankInfo.options)
                        }
                    } else {
                        withdrawSection <<< WithdrawRow("amount") {
                            $0.cash = self?.cash ?? 0
                            $0.placeholder = "Số tiền khác"
                            $0.add(ruleSet: RulesWidthdraw.rules(minValue: 100000, maxValue: RulesWidthdraw.Value(finalMax), maxOption: RulesWidthdraw.Value(finalMax)))
                            $0.onChange { _ in
                                self?.validateForm()
                            }
                        }
                    }
                }

                self?.validateForm()
            }
            .disposed(by: viewModel.disposeBag)

        // Setup view model
        viewModel.setupRX()
    }


    private func validateForm() {
        let input = form.values()
        let userBankInfos: [BankCellModel] = input.compactMap { item -> BankCellModel? in
            return (item.key.hasPrefix("user_bank_info") ? (item.value as? BankCellModel) : nil)
        }

        guard
            let userBankInfo = userBankInfos.first(where: { $0.isSelected }),
            let bankName = userBankInfo.bankInfo?.bankShortName, bankName.count > 0,
            let amount = input["amount"] as? Int, amount > 0,
            form.validate().count <= 0
        else {
            // Disable button
            let background = #imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate)
            continueButton.setBackgroundImage(background, for: .normal)
            continueButton.isEnabled = false
            continueButton.tintColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
            return
        }

        // Disable button
        let background = #imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate)
        continueButton.setBackgroundImage(background, for: .normal)
        continueButton.isEnabled = true
        continueButton.tintColor = EurekaConfig.originNewColor
    }
}


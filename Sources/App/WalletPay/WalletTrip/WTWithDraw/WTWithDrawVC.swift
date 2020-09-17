//  File name   : WTWithDrawVC.swift
//
//  Author      : admin
//  Created date: 6/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCoreRX
import FwiCore
import RxSwift
import RxCocoa

import Eureka
import SVProgressHUD

protocol WTWithDrawPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var listUserBankObs: Observable<[UserBankInfo]>  { get }
    var balanceObs: Observable<DriverBalance> { get }
    func moveBack()
    func moveToWithDrawCF(item: UserBankInfo)
}

final class WTWithDrawVC: FormViewController, WTWithDrawPresentable, WTWithDrawViewControllable {
//    var uiviewController: UIViewController
    
    private struct Config {
        static let paddingLeft: CGFloat = 16
        static let paddingRight: CGFloat = 16

        static let AmountSection: String = "AmountSection"
        
        static let defaultMinTopUp = 100000
        static let defaultMaxTopUp = 5000000
    }
    
    /// Class's public properties.
    weak var listener: WTWithDrawPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setUpRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private let disposeBag = DisposeBag()
    private var listUserBank: [UserBankInfo]?
    private var lbAmount: UILabel = UILabel(frame: .zero)
    private var viewListBank: WTViewBank = WTViewBank.loadXib()
    private var currentUser: UserBankInfo?
    private var balance: DriverBalance?
    private weak var continueBtn: UIButton?

}

// MARK: View's event handlers
extension WTWithDrawVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension WTWithDrawVC {
}

// MARK: Class's private methods
private extension WTWithDrawVC {
    private func localize() {
    }
    
    private func setUpRX() {
        listener?.balanceObs.bind(onNext: weakify { (balance, wSelf) in
            wSelf.balance = balance
            wSelf.lbAmount.text = balance.hardCash.currency
//            wSelf.updateTopUpRow()
        }).disposed(by: disposeBag)
        
        listener?.listUserBankObs.bind(onNext: weakify { (listUserBank, wSelf) in
            wSelf.listUserBank = listUserBank
            wSelf.form.removeAll()
            UIView.performWithoutAnimation {
                wSelf.form += [wSelf.genSection()]
            }
            wSelf.tableView.reloadData()
            guard let defaultCurrent = listUserBank.first else  { return }
            wSelf.currentUser = defaultCurrent
        }).disposed(by: disposeBag)
        
        continueBtn?.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            
            if let row = wSelf.form.rowBy(tag: "amount") as? WithdrawRow  {
                wSelf.currentUser?.amountNeedWithDraw = row.value
                if let user = wSelf.currentUser {
                    wSelf.listener?.moveToWithDrawCF(item: user)
                }
            }
        }.disposed(by: disposeBag)
    }
    private func layoutHeader(s: Section) {
            var header = HeaderFooterView<UIView>(.callback {
                let v = UIView()
                let label = UILabel()
                label >>> v >>> {
                    $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
                    $0.font =  UIFont.systemFont(ofSize: 14, weight: .medium)
                    $0.text = "Doanh thu chuyến đi"
                    $0.snp.makeConstraints {
                        $0.centerX.equalToSuperview()
                        $0.top.equalToSuperview().inset(24)
                    }
                }
                
                self.lbAmount >>> v >>> {
                    $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
                    $0.font =  UIFont.systemFont(ofSize: 32, weight: .medium)
                    $0.snp.makeConstraints {
                        $0.centerX.equalToSuperview()
                        $0.top.equalTo(label.snp.bottom).inset(-8)
                    }
                }
                
                let vLine: UIView = UIView(frame: .zero)
                vLine >>> v >>> {
                    $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                    $0.snp.makeConstraints { (make) in
                        make.left.right.equalToSuperview()
                        make.height.equalTo(10)
                        make.top.equalTo(self.lbAmount.snp.bottom)
                    }
                }
                
                let lbAmountNeedWithDraw: UILabel = UILabel(frame: .zero)
                lbAmountNeedWithDraw >>> v >>> {
                    $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                    $0.font =  UIFont.systemFont(ofSize: 14, weight: .medium)
                    $0.text = "Số tiền muốn rút"
                    $0.snp.makeConstraints {
                        $0.left.equalTo(Config.paddingLeft)
                        $0.right.equalToSuperview()
                        $0.bottom.equalToSuperview().inset(4)
                    }
                }
                v.backgroundColor = .white
                
                return v
                })
            header.height = { 132 }
            s.header = header
    }
        
    private func validateForm() {
        let errors = self.form.validate()
        continueBtn?.isEnabled = errors.count == 0
    }

    private func layoutFooter(s: Section) {
        if let listUser = self.listUserBank {

        var footer = HeaderFooterView<UIView>(.callback {
            let v = UIView()
            let label = UILabel()
            label >>> v >>> {
                $0.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                $0.text = "Tối thiểu là 100,000đ và là bội số của 10,000đ"
                $0.snp.makeConstraints {
                    $0.top.equalTo(15)
                    $0.left.equalTo(Config.paddingLeft)
                }
            }
            
            let vHeader: UIView = UIView(frame: .zero)
            vHeader.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            
            v.addSubview(vHeader)
            vHeader.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(label.snp.bottom).inset(-16)
                make.height.equalTo(40)
            }
            
            let labelHeader = UILabel()
            labelHeader >>> vHeader >>> {
                $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                $0.text = "Rút về tài khoản"
                $0.snp.makeConstraints {
                    $0.left.equalTo(Config.paddingLeft)
                    $0.right.equalToSuperview()
                    $0.centerY.equalToSuperview()
                }
            }
            
            v.addSubview(self.viewListBank)
            self.viewListBank.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(vHeader.snp.bottom)
                make.bottom.equalToSuperview()
            }
            self.viewListBank.listBankUser = listUser
            self.viewListBank.didSelect = { index in
                if let row = self.form.rowBy(tag: "amount") as? WithdrawRow  {
                    guard let itemBank = listUser[index.row].bankInfo else { return }
                    self.currentUser = listUser[index.row]
                    row.update(by: itemBank.options)
                    let min = itemBank.min
                    let finalMax = Double(self.balance?.hardCash ?? 0)
                    row.add(ruleSet: RulesWidthdraw.rules(minValue: RulesWidthdraw.Value(min),
                                                          maxValue: RulesWidthdraw.Value(finalMax),
                                                          maxOption: RulesWidthdraw.Value(finalMax)))
                    row.onChange { [weak self]_ in
                        guard let wSelf = self else { return  }
                        wSelf.validateForm()
                    }
                }
            }
            
            v.backgroundColor = .white
            
            return v
            })
            let heightFooter = (listUser.count * 72) + 80
            footer.height = { CGFloat(heightFooter) }
            s.footer = footer
        }
    }
    
    private func genSection() -> Section {
        let section = Section("") { (s) in
            s.tag = "AmountSection"
            
            self.layoutHeader(s: s)
            self.layoutFooter(s: s)
            }
            <<< WithdrawRow("amount") {
                guard let itemFirst = self.listUserBank?.last, let bankInfo = itemFirst.bankInfo else {
                    return
                }
                $0.cash = 2000000
                $0.placeholder = "Nhập số tiền muốn rút"
                $0.update(by: bankInfo.options)
                $0.cell.backgroundColor = .white
                let min = itemFirst.bankInfo?.min ?? Double(Config.defaultMinTopUp)
                let finalMax = Double(self.balance?.hardCash ?? 0)
                $0.add(ruleSet: RulesWidthdraw.rules(minValue: RulesWidthdraw.Value(min),
                                                     maxValue: RulesWidthdraw.Value(finalMax),
                                                     maxOption: RulesWidthdraw.Value(finalMax)))
                $0.onChange { [weak self]_ in
                    guard let wSelf = self else { return}
                    wSelf.validateForm()
                }
            }
        return section
    }

    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = visualizeButtonLeft()
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
        
        visualizeNavigationBar(titleStr: "Rút tiền")
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let _viewBgNext = UIView(frame: .zero) >>> view >>> {
                   $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                   $0.snp.makeConstraints({ (make) in
                       make.left.equalTo(0)
                       make.right.equalTo(0)
                       make.bottom.equalTo(0)
                       make.height.equalTo(78)
                   })
               }
               
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
                $0.cornerRadius = 24
                          $0.setBackground(using: #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1), state: .disabled)
                          $0.setBackground(using: Color.orange, state: .normal)
                          $0.isEnabled = false
                          $0.setTitle("Tiếp tục", for: .normal)
                          $0.setTitleColor(.white, for: .normal)
                          $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                   $0.snp.makeConstraints({ (make) in
                        make.left.equalTo(Config.paddingLeft)
                        make.right.equalTo(-Config.paddingRight)
                        make.top.equalTo(10)
                        make.height.equalTo(48)
                   })
               }
        self.continueBtn = button
        
        UIView.performWithoutAnimation {
            self.form += [genSection()]
        }
    }
}

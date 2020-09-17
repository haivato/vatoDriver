//  File name   : BuyPointVC.swift
//
//  Author      : admin
//  Created date: 5/20/20
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

protocol BuyPointPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func moveBack()
    func moveToWithDrawCF(item: TopupCellModel, point: Int)
    
    var lastSelectedCard: Card? { get }
    func selectCard(card: Card?)
    
    var listMethodObser: Observable<[Any]> {get}
    var balanceObs: Observable<DriverBalance> {get}
    var indexObs: Observable<IndexPath> { get }
}

final class BuyPointVC: FormViewController, BuyPointPresentable, BuyPointViewControllable {
    /// Class's public properties.
    weak var listener: BuyPointPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    private let disposeBag = DisposeBag()
    private var currentSelectedRow: TopupRow?
    private var model : TopupCellModel?
    private var balance: DriverBalance?
    private var indexSelect: Int = 0

    private weak var continueBtn: UIButton?
    private var lbAmount: UILabel = UILabel(frame: .zero)
        
    private struct Config {
        static let paddingLeft: CGFloat = 16
        static let paddingRight: CGFloat = 16
        
        static let AmountSection: String = "AmountSection"
        
        static let defaultMinTopUp = 100000
        static let defaultMaxTopUp = 5000000
    }
}

// MARK: View's event handlers
extension BuyPointVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension BuyPointVC {
}

// MARK: Class's private methods
private extension BuyPointVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = visualizeButtonLeft()
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
                        
        visualizeNavigationBar(titleStr: "Mua điểm nhận chuyến")
        
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
            self.form += [gensection()]
        }
    }
    
    private func validateForm() {
        let errors = self.form.validate()
        continueBtn?.isEnabled = errors.count == 0
    }
    
    private func setupRX() {
        listener?.indexObs.bind(onNext: weakify { (index, wSelf) in
            wSelf.indexSelect = index.row
            wSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        continueBtn?.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            
            if let row = wSelf.form.rowBy(tag: "amount") as? WithdrawRow  {
                if let model = wSelf.model {
                    let p = row.value ?? 0
                    wSelf.listener?.moveToWithDrawCF(item: model, point: p)
                }
            }
        }.disposed(by: disposeBag)
        
        listener?.listMethodObser.bind(onNext: weakify { (list, wSelf) in
            wSelf.config(list: list)
        }).disposed(by: disposeBag)
        
        listener?.balanceObs.bind(onNext: weakify { (balance, wSelf) in
            wSelf.balance = balance
            wSelf.lbAmount.text = balance.hardCash.currency
            wSelf.updateTopUpRow()
        }).disposed(by: disposeBag)
    }
    
    func updateTopUpRow() {
        if let row = form.rowBy(tag: "row at 0") as? TopupRow  {
            row.cell.updateSubTitle(sTitle: "Số dư khả dụng: " +  (balance?.hardCash ?? 0).currency)
        }
    }
    
    func updateWithdrawRow() {
        if let row = form.rowBy(tag: "amount") as? WithdrawRow  {
            row.update(by: self.model?.item.options, isPrice: false)
            let min = self.model?.item.min ?? Config.defaultMinTopUp
            let max = self.model?.item.max ?? Config.defaultMaxTopUp
            row.remove(ruleWithIdentifier: "check_max")
            row.remove(ruleWithIdentifier: "check_min")
            row.add(rule: RulesTopUp.checkMaxRulePoint(maxValue: max))
            row.add(rule: RulesTopUp.checkMinRulePoint(minValue: min))
            if row.value != nil {
                self.validateForm()
            }
        }
    }
    
    private func handler(select: TopupCellModel?) {
        if let _ = select {
            self.model = select!
            self.updateWithdrawRow()
            self.listener?.selectCard(card: self.model?.card)
        }
    }
    
    private func config(list: [Any]) {
        func createSection() -> Section {
            let new = Section() { (s) in
                s.tag = "BuyPoint"
                
                var header = HeaderFooterView<UIView>(.callback {
                    let v = UIView()
                    v.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                    let label = UILabel()
                    label >>> v >>> {
                        $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                        $0.text = "Mua điểm từ"
                        $0.snp.makeConstraints {
                            $0.left.equalTo(Config.paddingLeft)
                            $0.right.equalToSuperview()
                            $0.bottom.equalTo(-8)
                        }
                    }
                    return v
                    })
                header.height = { 50 }
                s.header = header
            }
            
            defer { form.append(new) }
            return new
        }
        
        let section = form.sectionBy(tag: "BuyPoint") ?? createSection()
        if section.allRows.count > 0 { section.removeAll() }
        
        func convertTopUpMethodToDummy(_ method: TopUpMethod) -> DummyTopupMethod {
            let dMethod = DummyTopupMethod()
            dMethod.type = method.type
            dMethod.name = method.name
            dMethod.iconURL = method.iconURL
            dMethod.url = method.url
            dMethod.min = method.min
            dMethod.max = method.max
            dMethod.active = method.active
            dMethod.auth = method.auth
            dMethod.options = method.options
            return dMethod
        }
        func convertTopUpMethodToModel(method: TopUpMethod) -> TopupCellModel {
            let dMethod = convertTopUpMethodToDummy(method)
            let card = PaymentCardDetail(id: "", iconUrl: dMethod.iconURL)
            let tuModel = TopupCellModel(item: dMethod, card: card)
            return tuModel
        }
        
        //        func convertCardToModel(card: Card, napas: TopUpMethod) -> TopupCellModel {
        //            let dMethod = convertTopUpMethodToDummy(napas)
        //            dMethod.name = card.brand
        //            dMethod.iconURL = card.iconUrl
        //            let tuModel = TopupCellModel(item: dMethod, card: card)
        //            return tuModel
        //        }
        
        func convertCardToModel(card: Card) -> TopupCellModel {
            let dMethod = DummyTopupMethod()
            dMethod.min = 50000
            dMethod.max = 5000000
            dMethod.options = [50000.0, 2000000.0, 1000000.0]
            dMethod.name = card.brand
            dMethod.iconURL = card.iconUrl
            let tuModel = TopupCellModel(item: dMethod, card: card)
            return tuModel
        }
        
        func row(idx: Int, model: Any) -> TopupRow {
            let tag = "row at \(idx)"
            print("row %d",  idx)
            let new = TopupRow(tag, {
                var tumethod: TopupCellModel?
                if let tu_model = model as? TopUpMethod{
                    tumethod = convertTopUpMethodToModel(method: tu_model)
//                    if idx == 0 {
//                        tumethod?.card?.number = "Số dư khả dụng: " +  (balance?.hardCash ?? 0).currency
//                    }
                }
                if let ca_model = model as? Card  {
                    tumethod = convertCardToModel(card: ca_model)
                }
                $0.value = tumethod
                $0.onCellSelection({ [weak self](cell, row) in
                    guard let wSelf = self else { return}
                    wSelf.currentSelectedRow?.cell.bankSelectView.backgroundColor = .white
                    defer {
                        wSelf.handler(select: row.value)
                    }
                    guard row.cell.bankSelectView.isSelected == false else { return }
                    
                    row.cell.bankSelectView.isSelected = true
                    row.cell.bankSelectView.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
                    wSelf.currentSelectedRow?.cell.bankSelectView.isSelected = false
                    wSelf.currentSelectedRow = row
                })
                
                Process: if let lastSelectedCard = self.listener?.lastSelectedCard {
                    guard tumethod?.card == lastSelectedCard else {
                        break Process
                    }
                    $0.select()
                    $0.didSelect()
                }
                else {
                    guard idx == self.indexSelect else {
                        break Process
                    }
                    $0.select()
                    $0.didSelect()
                }
            })
            return new
        }
        
        let allRows = list.enumerated().map(row)
        section.append(contentsOf: allRows)
    }
        
    private func genHeaderFooter(s: Section) {
        var header = HeaderFooterView<UIView>(.callback {
            let v = UIView()
            let label = UILabel()
            label >>> v >>> {
                $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                $0.font =  UIFont.systemFont(ofSize: 14, weight: .medium)
                $0.text = "Số điểm muốn nạp (1,000 điểm = 1,000 đồng)"
                $0.snp.makeConstraints {
                    $0.left.equalTo(Config.paddingLeft)
                    $0.right.equalToSuperview()
                    $0.bottom.equalTo(-8)
                }
            }
            return v
            })
        header.height = { 50 }
        s.header = header
        
        var footer = HeaderFooterView<UIView>(.callback {
            let v = UIView()
            let label = UILabel()
            label >>> v >>> {
                $0.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                $0.text = "Tối thiểu là 100,000 điểm là bội số của 10,000"
                $0.snp.makeConstraints {
                    $0.top.equalTo(15)
                    $0.left.equalTo(Config.paddingLeft)
                }
            }
            return v
            })
        
        footer.height = { 40 }
        s.footer = footer
    }
    
    private func gensection() -> Section {
        let section = Section("") { (s) in
            s.tag = Config.AmountSection
                
            self.genHeaderFooter(s: s)
            
            }
            <<< WithdrawRow("amount") {
                $0.cash = 2000000
                $0.formatPointCell()
                $0.placeholder = "Nhập số điểm muốn nạp"
                $0.update(by: self.model?.item.options, isPrice: false)
                let min = self.model?.item.min ?? Config.defaultMinTopUp
                let max = self.model?.item.max ?? Config.defaultMaxTopUp
                $0.add(ruleSet: RulesTopUp.rulesOfPoint(minValue: min, maxValue: max))
                $0.onChange { [weak self]_ in
                    guard let wSelf = self else { return}
                    wSelf.validateForm()
                }
        }
        return section
    }
    
    private func setAmountSelect() {
        if let row = form.rowBy(tag: "amount") as? WithdrawRow  {
            row.cell.setPriceViewSelected(indexPath: IndexPath(row: 0, section: 0))
        }
    }
}

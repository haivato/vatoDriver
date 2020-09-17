//  File name   : WTWithDrawConfirmVC.swift
//
//  Author      : MacbookPro
//  Created date: 5/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift

protocol WTWithDrawConfirmPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBack()
    func submitWithDraw(pin: String)
    func showAlert(text: String)
    var isPin: Observable<Bool> { get }
    var isSubmitSuccess: Observable<(Bool, String)> { get }
    var topUpObser: Observable<TopupCellModel?> {get}
    var pointObser: Observable<Int?> {get}
    var userBank: Observable<UserBankInfo?>  { get }
    var balanceObs: Observable<DriverBalance> { get }
    var itemTopUpCellModel: Observable<TopupCellModel> { get }
    func goToTransferPoint(pin: String, amount: Int)
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var napasLoadingObser: Observable<(Bool, Double)> { get }
    
    func goToSuccess()
    func goToWDSuccess()
}

enum ConfirmType: Int {
    case TopUp
    case WithDraw
}

final class WTWithDrawConfirmVC: UIViewController, WTWithDrawConfirmPresentable, WTWithDrawConfirmViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: WTWithDrawConfirmPresentableListener?
    private var currentItem: TopupCellModel?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visualize()
        setupRX()
    }
    
    private func setupView(mss: [String]) {
        var colorPrice : UIColor
        var titles: [String] = []
        if let _ = topUpItem {
            titles = ["Mua điểm", "Số điểm", "Kênh nạp tiền", "Tổng điểm nạp"]
            colorPrice = EurekaConfig.primaryColor
        } else {
            titles = ["Rút tiền", "Số dư khả dụng", "Ngân hàng", "Tổng tiền rút"]
            colorPrice = #colorLiteral(red: 1, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        }
        for (t,m) in zip(titles,mss) {
            let item = WithdrawConfirmItem(title: t, message: m, iconName: nil)
            items.append(item)
        }
        
        title = items[0].title
        
        WTWithdrawContentView(with: items, colorPrice: colorPrice, parentView: view)
        
    }
    
    var items: [WithdrawConfirmItem] = []
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    deinit {
        _action.onCompleted()
    }

    /// Class's private properties.
    private var isPin: Bool = false
    private var passcodeView = VatoVerifyPasscodeObjC()
    
    private var topUpItem: TopupCellModel?
    private var userBank: UserBankInfo?
    private var balance: DriverBalance?
    private var point: Int?
    private let disposeBag = DisposeBag()
    private var handler: WithdrawActionHandlerProtocol?
    private lazy var _action = PublishSubject<WithdrawConfirmAction>()
    var action: Observable<WithdrawConfirmAction> {
        return _action
    }
    private var confirmBtn = UIButton()
    private var buttonLeft = UIButton()
    
    private var confirmType: ConfirmType = .WithDraw
}

// MARK: View's event handlers
extension WTWithDrawConfirmVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension WTWithDrawConfirmVC {
}

// MARK: Class's private methods
private extension WTWithDrawConfirmVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        buttonLeft = visualizeButtonLeft()
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .medium) ]
        UIApplication.setStatusBar(using: .lightContent)
    }
    
    private func setupRX() {
        listener?.itemTopUpCellModel.bind(onNext: weakify({ (item, wSelf) in
            wSelf.currentItem = item
            })).disposed(by: disposeBag)
        
        listener?.napasLoadingObser.bind(onNext: { (item) in
            if item.0 {
                LoadingManager.instance.show()
                self.confirmBtn.isUserInteractionEnabled = false
                self.buttonLeft.isUserInteractionEnabled = false
            } else {
                LoadingManager.instance.dismiss()
                self.confirmBtn.isUserInteractionEnabled = true
                self.buttonLeft.isUserInteractionEnabled = true
            }
        }).disposed(by: disposeBag)

        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)

        listener?.isPin.bind(onNext: weakify { (isPin, wSelf) in
            wSelf.isPin = isPin
        }).disposed(by: disposeBag)
        
        listener?.isSubmitSuccess.bind(onNext: weakify { (submit, wSelf) in
            if submit.0 == true {
                switch wSelf.confirmType {
                case .WithDraw:
                    wSelf.listener?.goToWDSuccess()
                case .TopUp:
                    wSelf.listener?.goToSuccess()
                }
            }
        }).disposed(by: disposeBag)
        
        listener?.balanceObs.bind(onNext: weakify { (balance, wSelf) in
            self.balance = balance
        }).disposed(by: disposeBag)
        
        listener?.userBank.bind(onNext: weakify { (user, wSelf) in
            if let user = user {
                wSelf.userBank = user
                let textAmount = "-" + "\(user.amountNeedWithDraw?.currency ?? "")"
                let hardCash = wSelf.balance?.hardCash.currency ?? ""
                let bankName = user.bankInfo?.bankShortName ?? ""
                let amount = user.amountNeedWithDraw?.currency ?? ""
                let arMss = [textAmount, hardCash , bankName, amount]
                wSelf.setupView(mss: arMss)
                
                wSelf.confirmType = .WithDraw
            }
        }).disposed(by: disposeBag)
        
        listener?.pointObser.bind(onNext: weakify { (p, wSelf) in
            wSelf.point = p
        }).disposed(by: disposeBag)

        listener?.topUpObser.bind(onNext: weakify { (topUp, wSelf) in
            if topUp != nil {
                wSelf.topUpItem = topUp
                if let p = wSelf.point, let n = wSelf.topUpItem?.item.name {
                    let pStr = p.point
                    let textAmount = "+" + pStr
                    wSelf.setupView(mss: [textAmount, pStr, n, pStr])
                }
                wSelf.setupAction()
                wSelf.confirmType = .TopUp
            }
        }).disposed(by: disposeBag)

        confirmBtn = UIButton.create {
            $0.setBackgroundImage(#imageLiteral(resourceName: "bg_button01"), for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle("Xác nhận", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(54)
                    make.bottom.equalTo(-16)
                })
            }
        confirmBtn.rx.tap.bind { [weak self] in
            self?.handleConfirm()
        }
        .disposed(by: disposeBag)
    }
    
    private func handleConfirm() {
        func typePinAndConfirm() {
            switch self.confirmType{
                case .TopUp:
                    guard let item = self.currentItem, let p = self.point else {
                        return
                    }
                    
                    if item.card?.type == PaymentCardType.none {
                        self.isPin ? self.getPin() : self.listener?.showAlert(text: Text.needToCreatePw.localizedText)
                    } else {
                        self.listener?.goToTransferPoint(pin: "pin", amount: p)
                    }
                case .WithDraw:
                    self.isPin ? self.getPin() : self.listener?.showAlert(text: Text.needToCreatePw.localizedText)
            }
        }
        
        switch confirmType {
        case .WithDraw:
            typePinAndConfirm()
        case .TopUp:
            let type = self.topUpItem?.item.topUpType
            if type == .momoPay || type == .zaloPay || type == .napas {
                self._action.onNext(.next)
            }
            else {
                typePinAndConfirm()
            }
        }
    }
    
    private func getPin() {
        passcodeView.passcode(on: self, type: .notVerify, forgot: { (value) in
            if let url = URL(string: "tel://\(1900667)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }) { (pin, isVerify) in
            guard let pin = pin else  { return }
            switch self.confirmType{
                case .TopUp:
                    if let p = self.point {
                         self.listener?.goToTransferPoint(pin: pin, amount: p)
                    }
                case .WithDraw:
                    self.listener?.submitWithDraw(pin: pin)
            }
        }
    }
    
    private func setupAction() {
        if let name = topUpItem?.item.topUpType?.name, let amount = point {
            handler = TopUpAction(with: name, amount: amount, controller: self, topUpItem: topUpItem)
            handler?.didSelectAdd = {
                self.listener?.goToSuccess()
            }
        }
        
        if let actionHandler = self.handler {
            self.action.bind(to: actionHandler.eAction).disposed(by: disposeBag)
            actionHandler.errorMessageSubject
                .delay(0.3, scheduler: SerialDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.asyncInstance)
                .bind { [weak self] (message) in
                    let alertView = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "Đóng", style: .destructive, handler: nil))
                    self?.present(alertView, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        }
    }
}

final class WTWithdrawConfirmTitleView: UIView {
    convenience init(with item: WithdrawConfirmItem, colorPrice: UIColor = EurekaConfig.primaryColor) {
        self.init(frame: .zero)
        layoutDisplay(item: item, colorPrice: colorPrice)
    }
    
    private func layoutDisplay(item: WithdrawConfirmItem, colorPrice: UIColor) {
        let delta: CGFloat
        if let iconName = item.iconName {
            let v = UIView.create {
//                $0.backgroundColor = EurekaConfig.originNewColor
                $0.backgroundColor = EurekaConfig.primaryColor
                $0.cornerRadius = 36
                } >>> self >>> {
                    $0.snp.makeConstraints({ (make) in
                        make.top.equalToSuperview()
                        make.centerX.equalToSuperview()
                        make.size.equalTo(CGSize(width: 72, height: 72))
                    })
            }
            
            UIImageView(image: UIImage(named: iconName)) >>> v >>> {
                $0.snp.makeConstraints({ (make) in
                    make.size.equalTo(CGSize(width: 24, height: 18))
                    make.center.equalToSuperview()
                })
            }
            
            delta = 88
        } else {
            delta = 0
        }
        
        let lblTile = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(delta)
                    make.centerX.equalToSuperview()
                })
        }
        
        lblTile.text = item.title
        
        let lblPrice = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
            $0.textColor = colorPrice //EurekaConfig.primaryColor
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblTile.snp.bottom).offset(8)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalToSuperview().priority(.high)
                })
        }
        
        lblPrice.text = item.message
    }
}

final class WTWithdrawConfirmItemView: UIView {
    enum TypeView {
        case normal
        case total
    }
    
    convenience init(with item: WithdrawConfirmItem, type: TypeView) {
        self.init(frame: .zero)
        layoutDisplay(item: item, type: type)
    }
    
    private func layoutDisplay(item: WithdrawConfirmItem, type: TypeView) {
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        switch type {
        case .normal:
            break
        case .total:
            top = 18
            bottom = -16
           UIView.create {
            $0.backgroundColor = EurekaConfig.separatorColor
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(top)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-28).priority(.low)
                    make.height.equalTo(1)
                })
            }
        }
        
        top += 14
        let lblTile = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(top)
                    make.left.equalTo(14)
                    make.bottom.equalToSuperview().offset(bottom)
                })
        }
        
        lblTile.text = item.title
        
        let lblMessage = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.textAlignment = .right
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(top)
                    make.right.equalTo(-14)
                })
        }
        
        lblMessage.text = item.message
    }
}

final class WTWithdrawContentView: UIView {
    @discardableResult convenience init(with items: [WithdrawConfirmItem], colorPrice: UIColor, parentView: UIView) {
        self.init(frame: .zero)
        layoutDisplay(items: items, colorPrice: colorPrice, parentView: parentView)
    }

    private func layoutDisplay(items: [WithdrawConfirmItem], colorPrice: UIColor, parentView: UIView) {
        let containerView = UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9176470588, blue: 0.9450980392, alpha: 1)
            $0.borderColor = #colorLiteral(red: 0.9215686275, green: 0.9294117647, blue: 0.9333333333, alpha: 1)
            $0.borderWidth = 1.0
            $0.cornerRadius = 8.0
            } >>> parentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-32)
                })
        }
        
        let stackView = UIStackView.create {
            $0 >>> containerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
            $0.axis = .vertical
            $0.distribution = .fillProportionally
        }
        
        let number = items.count
        
        guard number > 0 else {
            return
        }
        
        items.enumerated().forEach { (i) in
            switch i.offset {
            case 0:
                // Title
                let titleView = WTWithdrawConfirmTitleView(with: i.element, colorPrice: colorPrice)
                titleView >>> parentView >>> {
                    $0.snp.makeConstraints({ (make) in
                        make.top.equalTo(32)
                        make.centerX.equalToSuperview()
                    })
                }
                
                let s = titleView.systemLayoutSizeFitting(CGSize(width: CGFloat.infinity, height: CGFloat.infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                let t = 60 + s.height
                
                containerView.snp.updateConstraints({ (make) in
                    make.top.equalTo(t)
                })
            default:
                let type: WTWithdrawConfirmItemView.TypeView = i.offset == number - 1 ? .total : .normal
                let itemView = WTWithdrawConfirmItemView(with: i.element, type: type)
                stackView.addArrangedSubview(itemView)
            }
        }
    }
}

//  File name   : AlertVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/2/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCoreRX
import RxCocoa
import RxSwift
import SnapKit
import UIKit

struct ButtonConfig {
    static let height: CGFloat = 48
    static let spaceButton: CGFloat = 8
}

 let battleshipGrey = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
 let black40 = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4)
struct StyleView {
    let tint: UIColor
    let background: UIColor
    
    static let `default` = StyleView(tint: .white, background: orangeColor)
    static let cancel = StyleView(tint: .white, background: .white)
    static let disable = StyleView(tint: .white, background: battleshipGrey)
    
    static let newDefault = StyleView(tint: .white, background: .white)
}


typealias AlertBlock = () -> Void
struct AlertAction: AlertActionProtocol {
    let style: StyleButton
    let title: String
    let handler: AlertBlock
    var invokedDismissMethod: Observable<Void> { return Observable.empty() }
    
    func apply(button: UIButton) {
        button.applyButton(style: style)
        button.setTitle(title, for: .normal)
    }
}

@objcMembers
final class AlertActionObjC: NSObject {
    private var block: AlertBlock?
    private(set) var action: AlertAction?
    fileprivate lazy var invokeMethod: PublishSubject<Void?> = PublishSubject()

    override init() { super.init() }
    convenience init(from title: String, style: UIAlertAction.Style, handler: AlertBlock?) {
        self.init()
        self.block = handler
        self.action = self.createAction(style: style, title: title)
    }

    private func createAction(style: UIAlertAction.Style, title: String) -> AlertAction {
        let s: StyleButton = style == .default ? .default : .cancel
        let mAction = AlertAction(style: s, title: title) {
            self.invokeMethod.onNext(self.block?())
        }
        return mAction
    }

    fileprivate func reset() {
        self.action = nil
        self.block = nil
    }

    deinit {
        printDebug("\(#function)")
    }
}

@objcMembers
final class AlertVC: UIViewController {
    /// Class's public properties.
    private var buttons: [AlertAction]
    private let mTitle: String?
    private let mMessage: String?
    private let orderType: NSLayoutConstraint.Axis
    private lazy var disposeBag = DisposeBag()
    private var containerView: UIView?

    init(title: String?, message: String?, from buttons: [AlertAction], orderType: NSLayoutConstraint.Axis) {
        precondition(buttons.count > 0, "Number Buttons > 0")
        self.buttons = buttons
        self.mTitle = title
        self.mMessage = message
        self.orderType = orderType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()

        UIView.animate(withDuration: 0.3) {
            self.containerView?.transform = CGAffineTransform.identity
        }
    }

    deinit {
        buttons.removeAll()
    }
    
    func hideAlert(animation: Bool, complete: (() -> Void)?) {
        self.dismiss(animated: animation, completion: complete)
    }
}

extension AlertVC {
    @discardableResult
    static func show(on vc: UIViewController?,
                     title: String?, message: String?,
                     from buttons: [AlertAction],
                     orderType: NSLayoutConstraint.Axis,
                     transitionType: TransitonType = TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext)) -> AlertVC? {
        guard let vc = vc else {
            #if DEBUG
                precondition(false, "Please input controller")
            #endif
            return nil
        }

        let alertVC = AlertVC(title: title, message: message, from: buttons, orderType: orderType)
        switch transitionType {
        case .modal(let type, let presentStyle):
            alertVC.modalTransitionStyle = type
            alertVC.modalPresentationStyle = presentStyle
            vc.present(alertVC, animated: true, completion: nil)

        case .segue(let factory):
            let segue = factory(vc, alertVC)
            segue.perform()
        case .push:
            break
        case .addChild:
            break
        default:
            break
        }
        
        return alertVC
    }

    @discardableResult
    static func showObjc(on vc: UIViewController?, title: String?, message: String?, callback: @escaping AlertBlock)  -> AlertVC? {
        let alertOK = AlertAction(style: .default, title: "Quay lại màn hình đặt xe", handler: callback)
        return self.show(on: vc, title: title, message: message, from: [alertOK], orderType: .vertical)
    }

    @discardableResult
    static func showObjc(on vc: UIViewController?, title: String?, message: String?, orderType: NSLayoutConstraint.Axis, from actions: [AlertActionObjC]?) -> AlertVC? {
        guard let actions = actions else {
            precondition(false, "Please input action")
            return nil
        }

        let mActions = actions.compactMap(~\.action)
        guard !mActions.isEmpty else {
            precondition(false, "Please input action")
            return nil
        }

        let alertVC = self.show(on: vc, title: title, message: message, from: mActions, orderType: orderType)

        _ = Observable.merge(actions.map(~\.invokeMethod)).take(1).subscribe(onNext: { _ in
            actions.forEach({ $0.reset() })
        }) {
            printDebug("DISPOSE!!!!!")
        }
        return alertVC
    }

    @discardableResult
    static func showAlertObjc(on vc: UIViewController?, title: String?, message: String?, actionOk: String?, actionCancel: String?, callbackOK: @escaping AlertBlock, callbackCancel: @escaping AlertBlock) -> AlertVC?  {
        var alerts = [AlertAction]()
        if let cancel = actionCancel {
            let alertCancel = AlertAction(style: .cancel, title: cancel, handler: callbackCancel)
            alerts.append(alertCancel)
        }
        if let ok = actionOk {
            let alertOK = AlertAction(style: .default, title: ok, handler: callbackOK)
            alerts.append(alertOK)
        }

        if alerts.count > 0 {
            return self.show(on: vc, title: title, message: message, from: alerts, orderType: .horizontal)
        }
        return nil
    }
}

// MARK: Class's private methods
private extension AlertVC {
    private func localize() {
        // todo: Localize view's here.
    }

    private func visualize() {
        self.view.backgroundColor = black40
        // container
        let container = UIView(frame: .zero) >>> view >>> {
            $0.snp.makeConstraints({ make in
                make.center.equalToSuperview()
                make.width.equalToSuperview().offset(-32)
            })
        } >>> {
            $0.backgroundColor = .white
            $0.cornerRadius = 6
        }

        // label
        let lblTitle = UILabel(frame: .zero) >>> container >>> {
            $0.snp.makeConstraints({ make in
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.top.equalTo(23)
            })
        } >>> {
            $0.numberOfLines = 0
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        } >>> {
            $0.text = self.mTitle
        }

        let lblMessage = UILabel(frame: .zero) >>> container >>> {
            $0.snp.makeConstraints({ make in
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.top.equalTo(lblTitle.snp.bottom).offset(13)
            })
        } >>> {
            $0.numberOfLines = 0
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        } >>> {
            $0.text = self.mMessage
        }

        // stack view
        let height: CGFloat
        switch self.orderType {
        case .horizontal:
            height = 48
        case .vertical:
            let number = CGFloat(self.buttons.count)
            height = ButtonConfig.height * number + (number - 1) * ButtonConfig.spaceButton
        }

        let buttons = self.buttons.map { (action) -> UIButton in
            let b = UIButton(frame: .zero)
            b.applyButton(style: action.style)
            b.setTitle(action.title, for: .normal)
            b.rx.tap.bind { [weak self] in
                self?.dismiss(animated: true, completion: action.handler)
            }.disposed(by: self.disposeBag)
            return b
        }

        UIStackView(arrangedSubviews: buttons) >>> {
            $0.axis = self.orderType
            $0.distribution = .fillEqually
            $0.spacing = ButtonConfig.spaceButton
        } >>> container >>> {
            $0.snp.makeConstraints({ make in
                make.top.equalTo(lblMessage.snp.bottom).offset(30)
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.height.equalTo(height)
                make.bottom.equalTo(-16)
            })
        }

        container.transform = CGAffineTransform(translationX: 0, y: 1000)
        self.containerView = container
    }
}

extension UIButton {
    func applyButton(style: StyleButton) {
        self.apply(style: style.view)
        self.setTitleColor(style.textColor, for: .normal)
        self.titleLabel?.font = style.font
        self.layer.cornerRadius = style.cornerRadius
        self.layer.borderWidth = style.borderWidth
        self.layer.borderColor = style.borderColor.cgColor
    }
    
    func applyButtonWithoutBackground(style: StyleButton) {
        self.setTitleColor(style.textColor, for: .normal)
        self.titleLabel?.font = style.font
        self.layer.cornerRadius = style.cornerRadius
        self.layer.borderWidth = style.borderWidth
        self.layer.borderColor = style.borderColor.cgColor
    }
    
//    func setBackground(using color: UIColor, state: UIControl.State) {
//        let img = UIImage.image(from: color, with: self.frame.size)
//        self.setBackgroundImage(img, for: state)
//    }
    
    func circle() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    func shadow() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
    }
}


extension UIView {
    func apply(style: StyleView) {
        self.tintColor = style.tint
        self.backgroundColor = style.background
    }
    
    func applyCustom(block: () -> StyleView) {
        let style = block()
        self.apply(style: style)
    }
}

//  File name   : AlertCustomVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import FwiCore

// MARK: - Options
struct AlertCustomOption: OptionSet, Hashable  {
    let rawValue: Int
    
    static let title: AlertCustomOption = AlertCustomOption(rawValue: 1 << 0)// Option AlertStyleText
    static let message: AlertCustomOption = AlertCustomOption(rawValue: 1 << 1) // Option AlertStyleText
    static let image: AlertCustomOption = AlertCustomOption(rawValue: 1 << 2) // Option image_name
    static let customView: AlertCustomOption = AlertCustomOption(rawValue: 1 << 3)
    
    static let all: AlertCustomOption = [.title, .message, .image]
}

// MARK: - Styles
protocol AlertApplyStyleProtocol {
    func apply(view: UIView)
}
// MARK: -- Label
struct AlertStyleText: AlertApplyStyleProtocol {
    let color: UIColor
    let font: UIFont
    let numberLines: Int
    let textAlignment: NSTextAlignment
    
    static let titleDefault = AlertStyleText(color: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), font: .systemFont(ofSize: 18, weight: .medium), numberLines: 0, textAlignment: .center)
    static let messageDefault = AlertStyleText(color: #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), font: .systemFont(ofSize: 15, weight: .regular), numberLines: 0, textAlignment: .center)
    func apply(view: UIView) {
        guard let label = view as? UILabel else {
            assert(false, "Check!!!!")
            return
        }
        label.textColor = color
        label.font = font
        label.numberOfLines = numberLines
        label.textAlignment = textAlignment
    }
}

struct AlertLabelValue: AlertApplyStyleProtocol {
    let text: String?
    let style: AlertStyleText
    func apply(view: UIView) {
        guard let label = view as? UILabel else {
            assert(false, "Check!!!!")
            return
        }
        style.apply(view: label)
        label.text = text
    }
}

// MARK: -- Image
struct AlertImageStyle: AlertApplyStyleProtocol {
    let contentMode: UIView.ContentMode
    let size: CGSize
    
    func apply(view: UIView) {
        guard let imgView = view as? UIImageView else {
            assert(false, "Check!!!!")
            return
        }
        imgView.contentMode = contentMode
        imgView.snp.makeConstraints { (make) in
            make.size.equalTo(size)
        }
    }
}

struct AlertImageValue: AlertApplyStyleProtocol {
    let imageName: String?
    let style: AlertImageStyle
    
    func apply(view: UIView) {
        guard let imgView = view as? UIImageView else {
            assert(false, "Check!!!!")
            return
        }
        style.apply(view: imgView)
        imgView.image = UIImage(named: imageName ?? "")
    }
}

// MARK: - Alert
typealias AlertArguments = [AlertCustomOption: AlertApplyStyleProtocol]

final class AlertCustomVC: UIViewController {
    /// Class's public properties.
    struct Configs {
        static let paddingX: CGFloat = 48
        static let spacing: CGFloat = 20
        static let hButton: CGFloat = 48
        static let spaceButton: CGFloat = 0
    }
    
    private var buttons: [AlertActionProtocol]
    private let option: AlertCustomOption
    private let orderType: NSLayoutConstraint.Axis
    private var containerView: UIView?
    private lazy var disposeBag = DisposeBag()
    private let arguments: AlertArguments
    
    init(with option: AlertCustomOption,
         arguments: [AlertCustomOption: AlertApplyStyleProtocol],
         buttons: [AlertActionProtocol],
         orderType: NSLayoutConstraint.Axis)
    {
        self.arguments = arguments
        self.orderType = orderType
        self.buttons = buttons
        self.option = option
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
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
        UIView.animate(withDuration: 0.5) {
            self.containerView?.transform = .identity
        }
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension AlertCustomVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension AlertCustomVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        
        // MARK: - Container
        let containerView = UIView(frame: .zero)
        containerView >>> view >>> {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.width.equalTo(UIScreen.main.bounds.width - Configs.paddingX)
                make.center.equalToSuperview()
            }
        }
        self.containerView = containerView
        
        // MARK: - Check
        var childViews: [UIView] = []
        
        // Custom View
        if option.contains(.customView) {
            guard let customView = arguments[.customView] as? UIView else {
                assert(false, "Check !!!")
                return
            }
            childViews.append(customView)
        } else {
            if option.contains(.image) {
                guard let style = arguments[.image] else {
                    assert(false, "Check !!!")
                    return
                }
                let imageView = UIImageView(frame: .zero)
                style.apply(view: imageView)
                childViews.append(imageView)
            }
            
            if option.contains(.title) {
                guard let style = arguments[.title]  else {
                    assert(false, "Check !!!")
                    return
                }
                let label = UILabel(frame: .zero)
                label.setContentHuggingPriority(.defaultLow, for: .horizontal)
                style.apply(view: label)
                childViews.append(label)
            }
            
            if option.contains(.message) {
                guard let style = arguments[.message] else {
                    assert(false, "Check !!!")
                    return
                }
                let label = UILabel(frame: .zero)
                style.apply(view: label)
                label.setContentHuggingPriority(.defaultLow, for: .horizontal)
                childViews.append(label)
            }
        }
        
        // MARK: - Content
        assert(!childViews.isEmpty, "Check !!!")
        
        let stackView = UIStackView(arrangedSubviews: childViews)
        stackView >>> containerView >>> {
            $0.spacing = 20
            $0.distribution = .fill
            $0.alignment = .center
            $0.axis = .vertical
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(20)
                make.left.equalTo(20)
                make.right.equalTo(-20)
            }
        }
        
        let bottomView = UIView(frame: .zero)
        
        let height: CGFloat
        switch self.orderType {
        case .horizontal:
            height = Configs.hButton
        case .vertical:
            let number = CGFloat(self.buttons.count)
            height = Configs.hButton * number + (number - 1) * Configs.spaceButton
        }
        
        bottomView >>> containerView >>> {
            $0.backgroundColor = .white
            $0.addSeperator(with: .zero, position: .top)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(stackView.snp.bottom).offset(20)
                make.left.right.equalToSuperview()
                make.height.equalTo(height)
                make.bottom.equalToSuperview().priority(.high)
            }
        }
        
        let style: SeperatorPositon = orderType == .horizontal ? .right : .bottom
        let count = self.buttons.count
        
        let buttons = self.buttons.enumerated().map { (idx, action) -> UIButton in
            let b = UIButton(frame: .zero)
            action.apply(button: b)
            
            action.invokedDismissMethod.bind(onNext: weakify({ (wSelf) in
                wSelf.dismiss(animated: true, completion: nil)
            })).disposed(by: self.disposeBag)
            
            b.rx.tap.bind { [weak self] in
                self?.dismiss(animated: true, completion: action.handler)
            }.disposed(by: self.disposeBag)
            if idx < count - 1 {
                b.addSeperator(with: .zero, position: style)
            }
            return b
        }

        
        UIStackView(arrangedSubviews: buttons) >>> {
            $0.axis = self.orderType
            $0.distribution = .fillEqually
            $0.spacing = Configs.spaceButton
        } >>> bottomView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                
            }
        }
        bottomView.addSeperator(with: .zero, position: .top)
        containerView.transform = CGAffineTransform(translationX: 0, y: 1000)
        self.containerView = containerView
    }
}

// MARK: -- Protocol Action
protocol AlertActionProtocol {
    var handler: AlertBlock { get }
    var invokedDismissMethod: Observable<Void> { get }
    func apply(button: UIButton)
}

// MARK: -- AlertAction Timer
typealias AlertActionTimerHandlerUI = (_ seconds: TimeInterval, _ button: UIButton?) -> ()
final class AlertActionTimer: AlertActionProtocol, Weakifiable {
    let handler: AlertBlock
    let style: StyleButton
    let delegateUI: AlertActionTimerHandlerUI
    let timeInterval: TimeInterval
    var invokedDismissMethod: Observable<Void> {
        guard let e = invokedMethod else {
            return event.take(1).observeOn(MainScheduler.asyncInstance)
        }
        let e2 = event.take(1).observeOn(MainScheduler.asyncInstance)
        return Observable.merge(e, e2).take(1)
    }
    private var invokedMethod: Observable<Void>?
    private lazy var event: PublishSubject<Void> = PublishSubject()
    private weak var button: UIButton?
    private var dateExpire: Date!
    private lazy var disposeBag = DisposeBag()
    
    init(style: StyleButton,
         timeInterval: TimeInterval,
         invokedMethod: Observable<Void>?,
         delegateUI: @escaping AlertActionTimerHandlerUI,
         handler: @escaping AlertBlock)
    {
        self.style = style
        self.invokedMethod = invokedMethod
        self.delegateUI = delegateUI
        self.handler = handler
        self.timeInterval = timeInterval
    }
    
    func apply(button: UIButton) {
        self.button = button
        button.applyButton(style: style)
        setupRX()
    }
    
    private func setupRX() {
        guard let button = button else {
            return precondition(false, "Need exist button!!!!")
        }
        self.dateExpire = Date().addingTimeInterval(timeInterval)
        let completed = Observable
            .merge([button.rx.methodInvoked(#selector(UIButton.removeFromSuperview)).map { _ in }, invokedDismissMethod])
        Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .takeUntil(completed)
            .startWith(-1)
            .bind(onNext: weakify({ (_, wSelf) in
                let remain = wSelf.dateExpire.timeIntervalSinceNow
                guard remain > 0 else {
                    return wSelf.event.onNext(())
                }
                wSelf.delegateUI(remain, wSelf.button)
        })).disposed(by: disposeBag)
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
}

@objcMembers
final class AlertActionTimerDemo: NSObject {
    static func demo(on controller: UIViewController?) {
        let actionCancel = AlertAction(style: .newCancel, title: "Huỷ bỏ") {}
        let style = StyleButton(view: .newDefault, textColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 0, borderWidth: 0, borderColor: .clear)
        let actionOK = AlertActionTimer(style: style, timeInterval: 10, invokedMethod: nil, delegateUI: { (seconds, button) in
            button?.setTitle("Đồng ý(\(Int(seconds))s)", for: .normal)
        }) {
            print("abc")
        }
        let v = ConfirmChangeAddressView.loadXib()
        AlertCustomVC.show(on: controller, option: .customView, arguments: [AlertCustomOption.customView: v], buttons: [actionCancel, actionOK], orderType: .horizontal)
    }
}

// MARK: -- Show
extension AlertCustomVC {
    static func show(on vc: UIViewController?,
                     option: AlertCustomOption,
                     arguments: AlertArguments,
                     buttons: [AlertActionProtocol],
                     orderType: NSLayoutConstraint.Axis)
    {
        guard let vc = vc else {
            assert(false, "Check")
            return
        }
        let alertVC = AlertCustomVC(with: option, arguments: arguments, buttons: buttons, orderType: orderType)
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overCurrentContext
        vc.present(alertVC, animated: true, completion: nil)
    }
}


//  File name   : WithdrawConfirmVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD
import Alamofire

struct WithdrawConfirmItem {
    let title: String
    let message: String
    let iconName: String?
}

fileprivate final class WithdrawConfirmTitleView: UIView {
    convenience init(with item: WithdrawConfirmItem) {
        self.init(frame: .zero)
        layoutDisplay(item: item)
    }
    
    private func layoutDisplay(item: WithdrawConfirmItem) {
        let delta: CGFloat
        if let iconName = item.iconName {
            let v = UIView.create {
                $0.backgroundColor = EurekaConfig.originNewColor
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
            $0.font = UIFont.systemFont(ofSize: 24, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(delta)
                    make.centerX.equalToSuperview()
                })
        }
        
        lblTile.text = item.title
        
        let lblPrice = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 48, weight: .semibold)
            $0.textColor = EurekaConfig.primaryColor
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblTile.snp.bottom).offset(10)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalToSuperview().priority(.high)
                })
        }
        
        lblPrice.text = item.message
    }
}

fileprivate final class WithdrawConfirmItemView: UIView {
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

enum WithdrawConfirmAction {
    case cancel
    case next
}

final class WithdrawConfirmVC: UIViewController {
    /// Class's public properties.
    let items: [WithdrawConfirmItem]
    private lazy var disposeBag = DisposeBag()
    private lazy var _action = PublishSubject<WithdrawConfirmAction>()
    
    var action: Observable<WithdrawConfirmAction> {
        return _action
    }
    let handler: WithdrawActionHandlerProtocol
    
    struct Config {
        static let defaultTitleNext = "XÁC NHẬN"
    }
    
    private let titleButton: String?
    private let needShowBack: Bool
    
    init(_ block: () -> [WithdrawConfirmItem], title: String?,
         handler: WithdrawActionHandlerProtocol,
         titleButton: String? = nil,
         needShowBack: Bool = true) {
        self.items = block()
        self.titleButton = titleButton
        self.needShowBack = needShowBack
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    deinit {
        _action.onCompleted()
    }
}

// MARK: Class's private methods
private extension WithdrawConfirmVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let containerView = UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9176470588, blue: 0.9450980392, alpha: 1)
            } >>> view >>> {
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
        }
        
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        let number = items.count
        
        guard number > 0 else {
            return
        }
        
        items.enumerated().forEach { (i) in
            switch i.offset {
            case 0:
                // Title
                let titleView = WithdrawConfirmTitleView(with: i.element)
                titleView >>> view >>> {
                    $0.snp.makeConstraints({ (make) in
                        make.top.equalTo(36)
                        make.centerX.equalToSuperview()
                    })
                }
                
                let s = titleView.systemLayoutSizeFitting(CGSize(width: CGFloat.infinity, height: CGFloat.infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                let t = 60 + s.height
                
                containerView.snp.updateConstraints({ (make) in
                    make.top.equalTo(t)
                })
            default:
                let type: WithdrawConfirmItemView.TypeView = i.offset == number - 1 ? .total : .normal
                let itemView = WithdrawConfirmItemView(with: i.element, type: type)
                stackView.addArrangedSubview(itemView)
            }
        }
        
        let button = UIButton.create {
            $0.setBackgroundImage(#imageLiteral(resourceName: "bg_button01"), for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle(self.titleButton ?? Config.defaultTitleNext, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        } >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(54)
                make.bottom.equalTo(-16)
            })
        }
        
        button.rx.tap.bind { [weak self] in
            self?._action.onNext(.next)
        }
        .disposed(by: disposeBag)

        let item: UIBarButtonItem
        if needShowBack {
            item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), landscapeImagePhone: #imageLiteral(resourceName: "ic_back"), style: .plain, target: nil, action: nil)
            item.rx.tap.bind { [weak self] in
                self?._action.onNext(.cancel)
                }
            .disposed(by: disposeBag)
        } else {
            item = UIBarButtonItem(image: nil, landscapeImagePhone: nil, style: .plain, target: nil, action: nil)
        }
        
        self.navigationItem.leftBarButtonItems = [item]
    }
    
    private func setupRX() {
        self.action.bind(to: self.handler.eAction).disposed(by: disposeBag)
        self.handler.errorMessageSubject
            .delay(0.3, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (message) in
                let alertView = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Đóng", style: .destructive, handler: nil))
                self?.present(alertView, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)

        // Setup view model
    }

    
}

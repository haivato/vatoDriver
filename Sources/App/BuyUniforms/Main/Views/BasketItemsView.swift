//  File name   : BasketItemsView.swift
//
//  Author      : Dung Vu
//  Created date: 12/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

enum BasketItemActionType {
    case checkout
}

enum BasketItemsState: Int, Equatable {
    case compact = 1
    case full = 2
    case none = 0
    
    var showing: Bool {
        switch self {
        case .full:
            return true
        default:
            return false
        }
    }
    
    var height: CGFloat {
        switch self {
        case .compact, .full:
            return BasketItemsView.Configs.hMainView
        case .none:
            return 0
        }
    }
    
    var next: BasketItemsState {
        switch self {
        case .none:
            return .compact
        case .compact:
            return .full
        case .full:
            return .compact
        }
    }
}

typealias BasketItemType = (product: DisplayProduct, value: BasketStoreValueProtocol)
final class BasketItemsTVC: UITableViewCell, UpdateDisplayProtocol {
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private lazy var lblDescription: UILabel = UILabel(frame: .zero)
    private lazy var lblPrice: UILabel = UILabel(frame: .zero)
    private lazy var lblNumber: UILabel = UILabel(frame: .zero)
    private (set) lazy var editView = StoreEditControl(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        lblTitle >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        lblDescription >>> {
            $0.numberOfLines = 2
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        let priceView = UIView(frame: .zero)
        priceView >>> {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        lblPrice >>> priceView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.left.top.bottom.equalToSuperview()
            })
        }
        
        lblNumber >>> priceView >>> {
            $0.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(lblPrice.snp.right).offset(12)
                make.bottom.equalToSuperview()
            })
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblTitle, lblDescription, priceView])
        
        stackView >>> contentView >>> {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 8
            
            $0.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            })
        }
        
        editView.isSelected = true
        editView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(-16)
                make.bottom.equalTo(stackView).priority(.high)
                make.height.equalTo(24)
            })
        }
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0.5, right: 0), position: .bottom)
    }
    
    func setupDisplay(item: BasketItemType?) {
        guard let product = item?.product,
            let value = item?.value else {
                return
        }
        
        lblTitle.text = product.name
        lblDescription.text = value.note
        let p = product.price ?? 0
        lblPrice.text = p.currency
        lblNumber.text = "x\(value.quantity)"
    }
    
}

// MARK: - Main Basket
final class BasketItemsView: UIView, Weakifiable, DraggableViewProtocol {
    /// Class's public properties.\
    struct Configs {
        static let hMainView: CGFloat = 80 + (UIApplication.shared.keyWindow?.edgeSafe ?? .zero).bottom
        static let hContainer: CGFloat = 270
        static let payment = "Tiếp tục"
        static let title = "Giỏ hàng"
    }
    
    var state: Observable<BasketItemsState> {
        return mState.distinctUntilChanged().observeOn(MainScheduler.asyncInstance)
    }
    
    private lazy var mState = BehaviorRelay<BasketItemsState>(value: .none)
    private(set) lazy var action: PublishSubject<BasketItemActionType> = PublishSubject()

    /// Class's private properties.
    private lazy var mainView: UIView = UIView(frame: .zero)
    private (set) lazy var listView: HeaderCornerView = HeaderCornerView(with: 7)
    private var btnShowing: UIButton!
    private lazy var lblNumberItems: UILabel = UILabel(frame: .zero)
    private lazy var lblPrice: UILabel = UILabel(frame: .zero)
    private lazy var btnConfirm: UIButton = UIButton(frame: .zero)
    private lazy var bgView: UIView = UIView(frame: .zero)
    private lazy var tableView: UITableView = {
       let t = UITableView(frame: .zero, style: .grouped)
       t.backgroundColor = .white
       t.separatorStyle = .none
       return t
    }()
    private var minimum: CGFloat = 0
    private var maximum: CGFloat = 0
    private let value: Observable<BasketModel>?
    internal lazy var disposeBag = DisposeBag()
    private var source = [BasketItemType]()
    private var mSelect = PublishSubject<DisplayProduct>()
    
    var select: Observable<DisplayProduct> {
        return mSelect
    }
    
    lazy var panGesture: UIPanGestureRecognizer? = {
        let p = UIPanGestureRecognizer(target: nil, action: nil)
        containerView?.addGestureRecognizer(p)
        p.delegate = self
        return p
    }()
    
    var containerView: UIView? {
        return listView
    }
    
    init(frame: CGRect, value: Observable<BasketModel>?) {
        self.value = value
        super.init(frame: .zero)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let v = super.hitTest(point, with: event) else { return nil }
        if v == listView || v == mainView || v is UIControl {
            return v
        }
        
        let state = mState.value
        if state.showing {
            let f = listView.frame
            if !f.contains(point) {
                dismiss()
            }
            return v
        } else {
            return nil
        }
    }
    
}

extension BasketItemsView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ p: UIGestureRecognizer) -> Bool {
        guard panGesture == p else {
            return super.gestureRecognizerShouldBegin(p)
        }
        let t = tableView
        let shouldBegin = t.contentOffset.y <= -t.contentInset.top
        if shouldBegin {
            let velocity = panGesture?.velocity(in: self) ?? .zero
            return velocity.y > 0
        }
        return shouldBegin
    }
}

extension BasketItemsView {
    func update(state: BasketItemsState) {
        mState.accept(state)
    }
    
     func dismiss() {
        mState.accept(.compact)
    }
}

// MARK: Class's private methods
private extension BasketItemsView {
    private func visualize() {
        // todo: Visualize view's here.
        self.isHidden = true
        backgroundColor = .clear
        if let p = self.panGesture {
            tableView.panGestureRecognizer.require(toFail: p)
        }
        
        bgView >>> self >>> {
            $0.alpha = 0
            $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        //====== Main =====
        mainView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        mainView.addSeperator(with: .zero, position: .top)
        let hCompact: CGFloat = Configs.hMainView
        minimum = hCompact
        maximum = Configs.hContainer
        
        mainView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
               make.left.right.bottom.equalToSuperview()
               make.height.equalTo(minimum)
            })
        }
        let button = UIButton(frame: .zero)
        button >>> mainView >>> {
            $0.setImage(UIImage(named: "ic_basket"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(24)
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
        lblNumberItems >>> mainView >>> {
            $0.layer.cornerRadius = 7
            $0.clipsToBounds = true
            $0.textAlignment = .center
            $0.textColor = .white
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(button.snp.left).offset(7)
                make.bottom.equalTo(button.snp.top).offset(4)
                make.width.equalTo(0)
                make.height.equalTo(14)
            })
        }
        
        btnShowing = UIButton(frame: .zero)
        btnShowing >>> mainView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview().priority(.high)
            })
        }
        
        btnConfirm >>> mainView >>> {
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.backgroundColor = #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle(Configs.payment, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(16)
                make.size.equalTo(CGSize(width: 140, height: 48))
                make.right.equalTo(-16)
            })
        }
        
        lblPrice >>> mainView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(button.snp.right).offset(10).priority(.high)
                make.centerY.equalTo(button.snp.centerY)
                make.right.equalTo(btnConfirm.snp.left).offset(-5).priority(.high)
            })
        }
        
        //====== Container =====
        listView.containerColor = .white
        self.insertSubview(listView, belowSubview: mainView)
        listView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(mainView.snp.top)
                make.height.equalTo(maximum)
            })
        }
        
        let lblTitle = UILabel(frame: .zero)
        lblTitle >>> listView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.text = Configs.title
            $0.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(20)
            })
        }
        
        tableView >>> listView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(6).priority(.high)
                make.left.right.bottom.equalToSuperview()
            })
        }
        
        let btnClose = UIButton(frame: .zero)
        btnClose >>> listView >>> {
            $0.setImage(UIImage(named: "ic_close"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.top.right.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 44))
            })
        }
        
        btnClose.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.dismiss()
        })).disposed(by: disposeBag)
        
        var edge: UIEdgeInsets = .zero
        if #available(iOS 11, *) {
            edge = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        tableView.contentInset = UIEdgeInsets(top: -edge.top + 18, left: edge.left, bottom: edge.bottom, right: edge.right)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(BasketItemsTVC.self, forCellReuseIdentifier: BasketItemsTVC.identifier)
    }
    
    func setupRX() {
        setupDraggable()
        value?.map { (v) -> [BasketItemType] in
            let result = v.reduce(into: [BasketItemType](), { (r, item) in
                let n = BasketItemType(item.key, item.value)
                r.append(n)
            })
            return result
            }.do(onNext: { [weak self](items) in
                self?.source = items
            }).bind(to: tableView.rx.items(cellIdentifier: BasketItemsTVC.identifier, cellType: BasketItemsTVC.self)) { [unowned self] idx, element, cell in
                cell.setupDisplay(item: element)
                self.handler(cell: cell, idx: idx)
        }.disposed(by: disposeBag)
        
        value?.bind(onNext: weakify({ (products, wSelf) in
            var numberItems = 0
            let totalPrice = products.reduce(0, { (old, item) -> Double in
                let p = item.key.price ?? 0
                numberItems += item.value.quantity
                let next = p * Double(item.value.quantity)
                return old + next
            })
            
            wSelf.lblNumberItems.text = "\(numberItems)"
            wSelf.lblPrice.text = totalPrice.currency
            let s = wSelf.lblNumberItems.sizeThatFits(CGSize(width: CGFloat.infinity, height: 12))
            wSelf.lblNumberItems.snp.updateConstraints({ (make) in
                make.width.equalTo(s.width + 10)
            })
        })).disposed(by: disposeBag)
        
        state.skip(1).filter { $0 != .full } .bind(onNext: weakify({ (state, wSelf) in
            switch state {
            case .none:
                UIView.animate(withDuration: 0.3, animations: {
                    wSelf.bgView.alpha = 0
                    wSelf.mainView.transform = CGAffineTransform(translationX: 0, y: 1000)
                    wSelf.listView.transform = CGAffineTransform(translationX: 0, y: 1000)
                }, completion: { (completed) in
                    guard completed else { return }
                    wSelf.isHidden = true
                })
            case .compact:
                wSelf.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    wSelf.bgView.alpha = 0
                    wSelf.mainView.transform = .identity
                    wSelf.listView.transform = CGAffineTransform(translationX: 0, y: 1000)
                }, completion: { (completed) in })
                
            case .full:
                wSelf.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    wSelf.bgView.alpha = 1
                    wSelf.mainView.transform = .identity
                    wSelf.listView.transform = .identity
                }, completion: { (completed) in })
            }
        })).disposed(by: disposeBag)
        
        btnShowing.rx.tap.bind(onNext: weakify({ (wSelf) in
            let next = wSelf.mState.value.next
            wSelf.mState.accept(next)
        })).disposed(by: disposeBag)
        
        let checkoutAction = btnConfirm.rx.tap.map({ BasketItemActionType.checkout })
        checkoutAction.subscribe(self.action).disposed(by: disposeBag)
    }
    
    func handler(cell: BasketItemsTVC, idx: Int) {
        let e = cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse))
        cell.editView.rx.controlEvent(.touchUpInside).takeUntil(e).map { [weak self] in
            self?.source[safe: idx]?.product
        }.filterNil()
        .bind(onNext: weakify({ (item, wSelf) in
            wSelf.mSelect.onNext(item)
        })).disposed(by: disposeBag)
    }
}

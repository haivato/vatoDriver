//  File name   : WithdrawByPriceControl.swift
//
//  Author      : Dung Vu
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
import FwiCoreRX
import SnapKit

protocol WithdrawPriceDisplayProtocol {
    var price: Double { get }
    var isPrice: Bool { get }
}

protocol WithdrawCanSelectProtocol {
    var canSelect: Bool { get }
}

protocol PointProtocol {
    var isPoint: Bool { get }
}

fileprivate final class WithdrawByPriceCell: UICollectionViewCell, WithdrawCanSelectProtocol {
    var canSelect: Bool = true {
        didSet {
            self.contentView.alpha = canSelect ? 1 : 0.5
        }
    }
    
    struct Display {
        let colorBG: UIColor
        let colorText: UIColor
        let border: UIColor
        
        static let normal = Display(colorBG: .white, colorText: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), border: #colorLiteral(red: 0.8745098039, green: 0.8823529412, blue: 0.9019607843, alpha: 1))
        static let select = Display(colorBG: EurekaConfig.originNewColor, colorText: .white, border: .clear)
    }
    
    private lazy var lblDescription: UILabel = UILabel.create({
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .center
        $0.cornerRadius = 23
        $0.borderWidth = 1
        $0 >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        update(style: .normal)
    }
    
    func display(item: WithdrawElement) {
        self.canSelect = item.canSelect
        lblDescription.text = item.isPrice ? item.price.currency : item.price.point
//        lblDescription.text = item.price.currency
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            guard canSelect else {
                return
            }
            let style: Display = isSelected ? .select : .normal
            update(style: style)
        }
    }
    
    private func update(style: Display) {
        lblDescription.textColor = style.colorText
        lblDescription.backgroundColor = style.colorBG
        lblDescription.borderColor = style.border
    }
}

typealias WithdrawElement = WithdrawPriceDisplayProtocol & WithdrawCanSelectProtocol
protocol WithdrawHandleItemProtocol {
    var select: Observable<IndexPath?> { get }
}

final class WithdrawByPriceControl<T: WithdrawElement>: UIControl, WithdrawHandleItemProtocol {
    
    // MARK: Public
    var select: Observable<IndexPath?> {
        return _select.asObserver()
    }

    var currentIndex: IndexPath? {
        didSet {
            let next = currentIndex
            _select.onNext(next)

            if next == nil {
                collectionView.reloadData()
            }
        }
    }
    
    
    // MARK: Implement
    class WithDrawItem {
        var items: [T] = []
    }
    private let dataSource: BehaviorRelay<WithDrawItem> = BehaviorRelay(value: WithDrawItem())
    private let _lock: NSLock = NSLock()
    private lazy var disposeBag = DisposeBag()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 104, height: 48)
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .horizontal
        let v = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    private lazy var _select: ReplaySubject<IndexPath?> = ReplaySubject.create(bufferSize: 1)
    var isPrice = false
    /// Class's private properties.
    convenience init(by source: [T], currentSelect: IndexPath?) {
        self.init(frame: .zero)
        self.currentIndex = currentSelect
        self.update(by: source)
        common()
    }
    
    private func common() {
        collectionView >>> self >>> {
            $0.backgroundColor = .clear
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        registerCell()
        setupRX()
        setSelect()
    }
    
    private func registerCell() {
        self.collectionView.register(WithdrawByPriceCell.self, forCellWithReuseIdentifier: WithdrawByPriceCell.identifier)
    }
    
    private func setSelect(animated: Bool = false) {
        _select
            .filterNil()
            .take(1)
            .observeOn(MainScheduler.asyncInstance).subscribe { [weak self](e) in
                switch e {
                case .next(let idx):
                    self?.collectionView.selectItem(at: idx, animated: animated, scrollPosition: .centeredHorizontally)
                case .error(let e):
                    printDebug(e.localizedDescription)
                case .completed:
                    printDebug(#function)
                }
                
        }.disposed(by: disposeBag)
    }
    
    private func setupRX() {
        dataSource.observeOn(MainScheduler.instance)
            .map({ $0.items })
            .bind(to: collectionView.rx.items(cellIdentifier: WithdrawByPriceCell.identifier, cellType: WithdrawByPriceCell.self)) { (row, element, cell) in
                cell.display(item: element)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.bind { [unowned self ]idx in
            guard let cell = self.collectionView.cellForItem(at: idx),
                (cell as? WithdrawCanSelectProtocol)?.canSelect == true
            else {
//                self.setSelect()
                return
            }
            
            self.currentIndex = idx
        }.disposed(by: disposeBag)
    }
    
    // MARK: Update Source
    func update(by source: [T]) {
        _lock.lock()
        defer { _lock.unlock() }
        dataSource.value.items = source
        dataSource.accept(dataSource.value)
    }
}


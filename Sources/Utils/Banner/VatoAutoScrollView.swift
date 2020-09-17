//  File name   : VatoAutoScrollView.swift
//
//  Author      : Dung Vu
//  Created date: 5/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

enum VatoScrollViewType: Int {
    case carousel
    case scrollHorizontal
    case banner
    
    var autoScroll: Bool {
        switch self {
        case .scrollHorizontal:
            return false
        default:
            return true
        }
    }
    
    var isPagingEnabled: Bool {
        switch self {
        case .scrollHorizontal:
            return false
        default:
            return true
        }
    }
}

final class VatoGenericCVC<T: UIView>: UICollectionViewCell {
    private (set) lazy var view = T(frame: .zero)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else {
            return
        }
        visualize()
    }
    
    private func visualize() {
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

protocol HandlerEventReuseProtocol: AnyObject {
    var reuseEvent: Observable<Void>? { get set }
}

final class VatoScrollView<T>: UIView, Weakifiable, UpdateDisplayProtocol where T: UIView, T: HandlerEventReuseProtocol, T: UpdateDisplayProtocol, T.Value: Equatable {
    /// Class's public properties.
    typealias Element = T.Value
    @Published private var mSelected: Element?
    var selected: Observable<Element> {
        return $mSelected.filterNil()
    }
    
    private let edge: UIEdgeInsets
    private let sizeItem: CGSize
    private let spacing: CGFloat
    private let type: VatoScrollViewType
    private (set) var collectionView: UICollectionView!
    private var pageControl: UIPageControl?
    private var disposeScroll: Disposable?
    @VariableReplay private var source: [Element] = []
    private let bottomPageIndicator: CGFloat
    private var currentIdx: Int = 0 {
        didSet {
            self.pageControl?.currentPage = currentIdx
        }
    }
    private lazy var disposeBag = DisposeBag()
    
    init(edge: UIEdgeInsets, sizeItem: CGSize, spacing: CGFloat, type: VatoScrollViewType, bottomPageIndicator: CGFloat = -16) {
        self.edge = edge
        self.sizeItem = sizeItem
        self.spacing = spacing
        self.type = type
        self.bottomPageIndicator = bottomPageIndicator
        super.init(frame: .zero)
        visualize()
        setupRX()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDisplay(item: [Element]?) {
        guard let i = item else { return }
        source = i
        pageControl?.numberOfPages = i.count
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        disposeScroll?.dispose()
    }
    
    private func visualize() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = sizeItem
        layout.sectionInset = edge
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(VatoGenericCVC<T>.self, forCellWithReuseIdentifier: VatoGenericCVC<T>.identifier)
        collectionView >>> self >>> {
            $0.backgroundColor = .clear
            $0.isPagingEnabled = type.isPagingEnabled
            $0.showsHorizontalScrollIndicator =  false
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        self.collectionView = collectionView
        
        guard type.autoScroll else { return }
        
        let pageControl = UIPageControl(frame: .zero)
        pageControl.hidesForSinglePage = true
        pageControl >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(bottomPageIndicator)
            }
        }
        
        self.pageControl = pageControl
    }
    
    private func setupAutoScroll() {
        disposeScroll?.dispose()
        guard source.count > 1 else {
            return
        }
        disposeScroll = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (_, wSelf) in
            var next = wSelf.currentIdx + 1
            let count = wSelf.source.count
            next = next <= count - 1 ? next : 0
            wSelf.currentIdx = next
            wSelf.collectionView?.scrollToItem(at: IndexPath(item: next, section: 0), at: .centeredHorizontally, animated: true)
        }))
    }
    
    private func setupRX() {
        collectionView?.rx.willBeginDragging.bind(onNext: weakify({ (wSelf) in
            wSelf.disposeScroll?.dispose()
        })).disposed(by: disposeBag)
        
        collectionView?.rx.itemSelected.map { [weak self] in  self?.source[safe: $0.item] }.filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.mSelected = item
        })).disposed(by: disposeBag)
        
        $source.bind(to: collectionView.rx.items(cellIdentifier: VatoGenericCVC<T>.identifier, cellType: VatoGenericCVC<T>.self)) { idx, element, cell in
            let e = cell.rx.methodInvoked(#selector(UICollectionViewCell.prepareForReuse)).map { _ in }
            cell.view.reuseEvent = e
            cell.view.setupDisplay(item: element)
        }.disposed(by: disposeBag)
        
        $source.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (element, wSelf) in
            guard wSelf.type.autoScroll else { return }
            wSelf.setupAutoScroll()
        })).disposed(by: disposeBag)
        
        guard type.autoScroll else { return }
        
        collectionView?.rx.didEndDecelerating.bind(onNext: weakify({ (wSelf) in
            let offset = wSelf.collectionView.contentOffset
            let w = wSelf.collectionView.bounds.width
            let p = (offset.x / w).rounded(.toNearestOrAwayFromZero)
            wSelf.currentIdx = Int(p)
            wSelf.setupAutoScroll()
        })).disposed(by: disposeBag)
    }
    
}


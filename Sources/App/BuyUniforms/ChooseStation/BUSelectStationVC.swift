//  File name   : BUSelectStationVC.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import RIBs
import RxSwift
import UIKit
import FwiCoreRX
import VatoNetwork

protocol BUSelectStationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var selectedEvent: Observable<FoodExploreItem?>? { get }
    func didSelect(item: FoodExploreItem)
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Codable
    var categoryId: Int { get }
    var coordinate: CLLocationCoordinate2D { get }
    func selectStationMoveBack()
}

final class BUSelectStationVC: UIViewController, BUSelectStationPresentable, BUSelectStationViewControllable, PagingListRequestDataProtocol {
    
    
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        let coordinate = listener?.coordinate
        let make: (Int?) -> JSON = { id -> JSON in
            var params: [String: Any] = ["indexPage": max(paging.page, 0),
            "sizePage": Config.pageSize,
            "status": 4,
            "sortParam": "ASC"]
            params["lat"] = coordinate?.latitude
            params["lon"] = coordinate?.longitude
            params["rootCategoryId"] = id
            return params
        }
        let params = make(listener?.categoryId)
        return self.request(map: { return Observable.just(VatoFoodApi.nearly(authenToken: $0, params: params)) })
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : Codable {
        guard let listener = listener  else {
            return Observable.empty()
        }
        
        return listener.request(router: router, decodeTo: decodeTo, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        })
    }
    
    typealias Data = FoodStoreResponse
    typealias P = Paging
    
    private struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }

    /// Class's public properties.
    weak var listener: BUSelectStationPresentableListener?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var panGesture: UIPanGestureRecognizer?
    @IBOutlet weak var topContainer: NSLayoutConstraint?
    @IBOutlet weak var headerView: UIView!
    private var dataSource = [FoodExploreItem]() {
        didSet {
            loadContainer.onNext(())
        }
    }
    private(set) lazy var disposeBag = DisposeBag()
    private var currentTransform: CGAffineTransform?
    private lazy var loadContainer: ReplaySubject<Void> = ReplaySubject.create(bufferSize: 1)
    private var listView: PagingListView<ChooseStationTVC, BUSelectStationVC, P>?
    private var selecteditem: FoodExploreItem?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        self.loadContainerView()
    }
    
    private func loadContainerView() {
        let hContainer = UIScreen.main.bounds.height * 0.6
        let delta = max((UIScreen.main.bounds.height - hContainer), 80)
        let top = delta
        self.topContainer?.constant = top
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.containerView?.transform = CGAffineTransform(translationX: 0, y: 20)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }

        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.listener?.selectStationMoveBack()
    }
    
    /// Class's private properties.
}

// MARK: Table View DataSource

extension BUSelectStationVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard let tableView = self.listView?.tableView  else {
            return true
        }
        let shouldBegin = tableView.contentOffset.y <= -tableView.contentInset.top
        return shouldBegin
    }
}

extension BUSelectStationVC: RequestInteractorProtocol {
    var token: Observable<String> {
        return Observable.just("")
    }
    
    
}

// MARK: Class's private methods
private extension BUSelectStationVC {
    private func localize() {
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        self.containerView?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
    }

    private func setupRX() {
        // todo: Bind data to UI here.
        let pagingView = PagingListView<ChooseStationTVC, BUSelectStationVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportMainVC.P in
            return Config.pagingDefaut
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "ic_quick_support_empty",
                              message: "Không có dữ liệu.",
                              subMessage: "",
                              on: tableView,
                              customLayout: nil)
        }
        
        pagingView >>> containerView >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(headerView.snp_bottomMargin)
                make.left.right.bottom.equalToSuperview()
            }
        }
        
        pagingView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        pagingView.clipsToBounds = true
        
        self.listView = pagingView
        
        selectItem()
        
        self.listView?.configureCell = { [weak self] (cell, item) in
            mainAsync { (_) in
                if item.id == self?.selecteditem?.id {
                    cell.isSelected = true
                } else {
                    cell.isSelected = false
                }
                }(())
        }
        
        self.listView?.selected.bind(onNext: { [weak self] (m) in
            self?.listener?.didSelect(item: m)
        }).disposed(by: disposeBag)
    }

    private func selectItem() {        self.listener?.selectedEvent?.observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] s in
        self?.selecteditem = s
    }).disposed(by: disposeBag)
    }
}

extension BUSelectStationVC: DraggableViewProtocol {
    func dismiss() {
        self.listener?.selectStationMoveBack()
    }
}

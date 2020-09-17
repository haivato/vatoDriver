//  File name   : CarContractVC.swift
//
//  Author      : Phan Hai
//  Created date: 28/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import VatoNetwork

struct OrderContractResponse: Codable, ResponsePagingProtocol {
    var orderOfflineList: [OrderContract]?
    
    var items: [OrderContract]? {
        return orderOfflineList
    }
    
    var next: Bool {
        return (indexPage ?? 0 < totalPage ?? 0)
    }
    
    var indexPage: Int?
    var sizePage: Int?
    var totalRows: Int?
    var totalPage: Int?
}

enum ContractCarOrderType: Int, CaseIterable {
    //    case none = -1
    case listRequest = 0
    case history = 1
    case seeMore = 2
    case explain = 3
    case CREATED = 4
    case DRIVER_ACCEPTED = 5
    case DRIVER_STARTED = 6
    case DRIVER_FINISHED = 7
    
    static var allCases: [ContractCarOrderType] {
        return [.listRequest, .history, .seeMore, .explain, .CREATED, .DRIVER_ACCEPTED, .DRIVER_STARTED, .DRIVER_FINISHED]
    }
    var color: UIColor {
        switch self {
        case .listRequest:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        case .history:
            return #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4)
        default:
            fatalError("Please Implement")
        }
    }
    var textValue: String {
        switch self {
        case .listRequest:
            return "ACTIVE"
        case .history:
            return "PAST"
        default:
            fatalError("Please Implement")
        }
    }
}

protocol CarContractPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var eLoading: Observable<ActivityProgressIndicator.Element> { get }
    var listOrderActive: Observable<[OrderContract]> { get }
    var listOrderPast: Observable<[OrderContract]> { get }
    func moveBackHome()
    func routeToContractDetail(item: OrderContract)
    func routeToChatWithVato()
    func cancelOrderContract(orderID: Int)
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Codable
    func refreshListActive()
    func refreshListPast()
}

final class CarContractVC: UIViewController, CarContractPresentable, CarContractViewControllable, PagingListRequestDataProtocol {
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        var param: [String : Any] = [
            "page": max(paging.page, 0),
            "size": Config.pageSize
        ]
         param["filter"] = "ACTIVE"
        let url = TOManageCommunication.path("/rental-car/driver/orders?\(param.queryString)")
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true))
        }
        
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : Codable {
        guard let listener = listener  else {
            return Observable.empty()
        }
        
        return listener.request(router: router, decodeTo: decodeTo, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        })
    }
    
    typealias Data = OrderContractData
    typealias P = Paging
    private struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }
    
    /// Class's public properties.
    weak var listener: CarContractPresentableListener?
    
    // MARK: View's lifecycle
    @IBOutlet weak var vHeader: UIView!
    @IBOutlet weak var btListRequest: UIButton!
    @IBOutlet weak var btContract: UIButton!
    @IBOutlet weak var vLine: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var listView: PagingListView<CarContractCell, CarContractVC, P>?
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 0.1
        tableView.register(CarContractCell.nib, forCellReuseIdentifier: CarContractCell.identifier)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    private var dataSource: [Int] = [1,2,3,4,5,6]
    private var typeCarContract: ContractCarOrderType = .listRequest
    private var controlRefresh: UIRefreshControl = UIRefreshControl()
    private var listOrderActive: [OrderContract] = []
    private var listOrderPast: [OrderContract] = []
    private var data: Variable<[OrderContract]> = Variable.init([])
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    private let disposeBag = DisposeBag()
    /// Class's private properties.
}
extension CarContractVC: RequestInteractorProtocol {
    var token: Observable<String> {
        return Observable.just("")
    }
}

// MARK: View's event handlers
extension CarContractVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension CarContractVC {
}

// MARK: Class's private methods
private extension CarContractVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind { _ in
            self.listener?.moveBackHome()
        }.disposed(by: disposeBag)
        title = "Xe chạy hợp đồng"
        
        tableView.refreshControl = controlRefresh
    }
    private func setupRX() {
//                let pagingView = PagingListView<CarContractCell, CarContractVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportMainVC.P in
//                    return Config.pagingDefaut
//                }) { (tableView) -> NoItemView? in
//                    return NoItemView(imageName: "ic_quick_support_empty",
//                                      message: "Không có dữ liệu.",
//                                      subMessage: "",
//                                      on: tableView,
//                                      customLayout: nil)
//                }
//        
//                pagingView >>> self.view >>> {
//                    $0.snp.makeConstraints { (make) in
//                        make.left.right.bottom.equalToSuperview()
//                        make.top.equalTo(self.vHeader.snp.bottom).inset(-8)
//                    }
//                }
//        
//                pagingView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
//                pagingView.clipsToBounds = true
//        
//                self.listView = pagingView
//        
//        self.listView?.configureCell = { [weak self] (cell, item) in
//            guard let wSelf = self else {
//                return
//            }
//            cell.viewCarContract.updateUI(type: wSelf.typeCarContract)
//            cell.setupDisplay(item: item)
//        }
//        
//        self.listView?.selected.bind(onNext: { [weak self] (m) in
////            self?.listener?.didSelect(item: m)
//            self?.listener?.routeToContractDetail(item: m)
//        }).disposed(by: disposeBag)
        
        listener?.eLoading.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        listener?.listOrderActive.bind(onNext: weakify({ (data, wSelf) in
            wSelf.listOrderActive = data
            wSelf.data.value = wSelf.listOrderActive
            wSelf.controlRefresh.endRefreshing()
        })).disposed(by: disposeBag)
        
        listener?.listOrderPast.bind(onNext: weakify({ (data, wSelf) in
            wSelf.listOrderPast = data
            wSelf.controlRefresh.endRefreshing()
        })).disposed(by: disposeBag)
        
        let listRequestType = self.btListRequest.rx.tap.map { _ in ContractCarOrderType.listRequest }
        let contract = self.btContract.rx.tap.map { _ in ContractCarOrderType.history }
        
        Observable.merge([listRequestType, contract]).bind(onNext: weakify({ (type, wSelf) in
            wSelf.typeCarContract = type
            wSelf.handle(type: type)
            wSelf.data.value = (type == .listRequest) ? wSelf.listOrderActive : wSelf.listOrderPast
            wSelf.tableView.reloadData()
            wSelf.tableView.allowsSelection = (type == .listRequest) ? true : false
        })).disposed(by: disposeBag)
        
        self.data.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: CarContractCell.identifier, cellType: CarContractCell.self)) {[weak self] (row, element, cell) in
                guard let wSelf = self else { return }
                cell.viewCarContract.updateUI(type: wSelf.typeCarContract)
                cell.setupDisplay(item: element)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind(onNext: weakify({ (idx, wSelf) in
            let item = self.data.value[idx.row]
            wSelf.listener?.routeToContractDetail(item: item)
        })).disposed(by: disposeBag)
        
        self.controlRefresh.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.controlRefresh.beginRefreshing()
            switch wSelf.typeCarContract {
            case .history:
                wSelf.listener?.refreshListPast()
            case .listRequest:
                wSelf.listener?.refreshListActive()
            default:
                break
            }
            
        })).disposed(by: disposeBag)
    }
    private func handle(type: ContractCarOrderType) {
        switch type {
        case .history:
            self.btContract.isSelected = true
            self.btListRequest.isSelected = false
        case .listRequest:
            self.btListRequest.isSelected = true
            self.btContract.isSelected = false
        default:
            break
        }
        self.tableView.reloadData()
        let positionX = self.view.bounds.width / 2
        UIView.animate(withDuration: 0.5) {
            self.vLine.transform = CGAffineTransform(translationX: CGFloat(type.rawValue) * positionX, y: 0)
        }
    }
}
extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "&\(key)=\(value)"
        }
        return output
    }
}

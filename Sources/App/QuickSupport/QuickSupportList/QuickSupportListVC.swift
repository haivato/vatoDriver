//  File name   : QuickSupportListVC.swift
//
//  Author      : khoi tran
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX
import VatoNetwork
import SnapKit
import FirebaseFirestore

protocol QuickSupportListPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable
    func detail(model: QuickSupportModel)
    func quickSupportListMoveBack()
    var lastSnapshot: DocumentSnapshot? { get set }
    var eLoadingObser: Observable<(Bool, Double)> { get }
}

final class QuickSupportListVC: UIViewController, QuickSupportListPresentable, QuickSupportListViewControllable, DisposableProtocol, PagingListRequestDataProtocol {
    
    
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        if paging.page == Config.pagingDefaut.page + 1 {
            listener?.lastSnapshot = nil
        }
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoFoodApi.getListSaleOrder(authenToken: key, params: nil))
        }
        
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : Decodable {
        guard let listener = listener  else {
            return Observable.empty()
        }
        
        return listener.request(router: router, decodeTo: decodeTo, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        })
        
    }
    
    struct Config {
        static let pageSize = 20
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 20)
    }
    
    /// Class's public properties.
    weak var listener: QuickSupportListPresentableListener?

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
    private var listView: PagingListView<QSRequestTVC, QuickSupportListVC, P>?
    typealias Data = QuickSupportListResponse
    typealias P = Paging
    internal lazy var disposeBag: DisposeBag = DisposeBag()
    private var requestSupportButton: UIButton?
    private var currentpaging: Paging?
}

struct QuickSupportListResponse: Codable, ResponsePagingProtocol {
    var values: [QuickSupportModel]?
    
    var items: [QuickSupportModel]? {
        let newValues = values?.map({ (item) -> QuickSupportModel in
            var newItem = item
            newItem.type = .home
            return newItem
        })
        return newValues
    }
    var next: Bool
        
}
// MARK: View's event handlers
extension QuickSupportListVC: RequestInteractorProtocol {
    var token: Observable<String> {
        return Observable.just("")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension QuickSupportListVC {
}

// MARK: Class's private methods
private extension QuickSupportListVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.title = "Danh sách yêu cầu hỗ trợ"
        self.view.backgroundColor = #colorLiteral(red: 0.9750739932, green: 0.9750967622, blue: 0.9750844836, alpha: 1)
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = #colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
         let image = UIImage(named: "ic_back")?.withRenderingMode(.alwaysOriginal)
         let leftBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
         self.navigationItem.leftBarButtonItem = leftBarItem
         leftBarItem.rx.tap.bind { [weak self] in
             guard let wSelf = self else {
                 return
             }
             wSelf.listener?.quickSupportListMoveBack()
         }.disposed(by: disposeBag)
         
        
         let pagingView = PagingListView<QSRequestTVC, QuickSupportListVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportListVC.P in
             return Config.pagingDefaut
         }) { (tableView) -> NoItemView? in
             return NoItemView(imageName: "ic_quick_support_empty",
                             message: "Danh sách trống",
                             subMessage: "Hiện tại, quý đối tác chưa có yêu cầu hỗ trợ nào đã được gửi",
                             on: tableView,
                             customLayout: nil)
         }
        
        view.addSubview(pagingView)
     
        pagingView.clipsToBounds = false
        pagingView.tableView.clipsToBounds = false
        self.listView = pagingView
        
        let requestSupportButton = UIButton.create { (button) in
            button.cornerRadius = 20
            button.setTitle("Gửi hỗ trợ", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            button.setImage(UIImage(named: "1"), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
        requestSupportButton >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(40)
                make.bottom.equalTo(view.snp.bottom).offset(-26)
                make.centerX.equalToSuperview()
            }
        }
        self.requestSupportButton = requestSupportButton
        
        pagingView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(requestSupportButton.snp.top)
        }
        
        self.listView?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    private func setupRX() {
         self.listView?.selected.bind(onNext: weakify({ (model, wSelf) in
            wSelf.listener?.detail(model: model)
         })).disposed(by: disposeBag)
        
        requestSupportButton?.rx.tap.bind { [weak self] (_) in
            guard let wSelf = self else { return }
            wSelf.listener?.quickSupportListMoveBack()
        }.disposed(by: disposeBag)
        
        listener?.eLoadingObser.bind(onNext: { (value) in
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
    }
    
}



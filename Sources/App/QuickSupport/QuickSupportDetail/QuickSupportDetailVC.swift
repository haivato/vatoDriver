//  File name   : QuickSupportDetailVC.swift
//
//  Author      : khoi tran
//  Created date: 1/16/20
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

protocol QuickSupportDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable
    func quickSupportDetailMoveBack()
    var quickSupportRequest: Observable<QuickSupportModel> { get }
    func showImages(currentIndex: Int, stackView: UIStackView)
    func sendMessage(message: String)
    var eLoadingObser: Observable<(Bool, Double)> { get }
}

final class QuickSupportDetailVC: UIViewController, QuickSupportDetailPresentable, QuickSupportDetailViewControllable, DisposableProtocol, PagingListRequestDataProtocol {

    private struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }
    
    /// Class's public properties.
    weak var listener: QuickSupportDetailPresentableListener?
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: nil, action: nil)
        return tap
    }()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        requestView.listener = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        let param: [String : Any] = [
            "indexPage": max(paging.page, 0),
            "sizePage": Config.pageSize
        ]
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoFoodApi.getListSaleOrder(authenToken: key, params: param))
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
    
    /// Class's private properties.
    private var listView: PagingListView<QSResponseTVC, QuickSupportDetailVC, P>?
    typealias Data = QuickSupportDetailResponse
    typealias P = Paging
    internal lazy var disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var _inputView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomTextView: NSLayoutConstraint?
    @IBOutlet weak var sendButton: UIButton!
    private lazy var requestView = QSRequestView.loadXib()
    private var isLoading = false
    @objc var qsItemId: String?
}

struct QuickSupportDetailResponse: Codable, ResponsePagingProtocol {
    var values: [QuickSupportItemResponse]?
    
    var items: [QuickSupportItemResponse]? {
        return values
    }
    
    var next: Bool {
        return false
    }
        
}
extension QuickSupportDetailVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        defer {
            textView?.resignFirstResponder()
        }
        return false
    }
}

// MARK: View's event handlers
extension QuickSupportDetailVC: RequestInteractorProtocol {
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
extension QuickSupportDetailVC {
    func insert(items: [QuickSupportItemResponse]) {
        guard items.isEmpty == false else { return }
        self.listView?.insert(items: items)
        mainAsync { () in
            let numberRow = self.listView?.tableView.numberOfRows(inSection: 0) ?? 0
            let indexPath = IndexPath(row: numberRow - 1, section: 0)
            self.listView?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }(())
    }
    
    func resetTextFieldChat() {
        self.textView.text = ""
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: nil)
    }
    
    func showError(eror: Error) {
        AlertVC.showError(for: self, error: eror as NSError)
    }
}

// MARK: Class's private methods
private extension QuickSupportDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let image = UIImage(named: "ic_back")?.withRenderingMode(.alwaysOriginal)
        let leftBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = leftBarItem
        leftBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.quickSupportDetailMoveBack()
        }.disposed(by: disposeBag)
        
        
        let pagingView = PagingListView<QSResponseTVC, QuickSupportDetailVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportDetailVC.P in
            return Config.pagingDefaut
        })
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.right.equalToSuperview()
                make.left.equalToSuperview()
                make.bottom.equalTo(_inputView.snp.top)
            }
        }
        
        self.listView = pagingView
        _inputView.addSeperator(with: .zero, position: .top)
        self.title = "Chi tiết yêu cầu hỗ trợ"
        tap.delegate = self
        pagingView.tableView.addGestureRecognizer(tap)
        pagingView.tableView.keyboardDismissMode = .onDrag
        textView.tintColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
    func setupRX() {
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        let safe = UIApplication.shared.keyWindow?.edgeSafe.bottom ?? 0
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] info in
            let h = info.height == 0 ? 0 : info.height - safe
            
            UIView.animate(withDuration: info.duration, animations: {
                self?.bottomTextView?.constant = -h
                self?.view.layoutIfNeeded()
            }, completion: { c in
                let numberRow = self?.listView?.tableView.numberOfRows(inSection: 0) ?? 0
                guard info.height > 0,
                    numberRow > 0 else {
                        return
                }
                
                let idx = IndexPath(item: numberRow - 1, section: 0)
                self?.listView?.tableView.scrollToRow(at: idx, at: .bottom, animated: true)
            })
        }.disposed(by: disposeBag)
        
        sendButton.rx.tap.bind { [weak self] in
            guard self?.isLoading == false,
                let me = self,
                let text = me.textView.text,
                text.trim().isEmpty == false else { return }
            me.listener?.sendMessage(message: me.textView.text)
            me.view.endEditing(true)
        }.disposed(by: disposeBag)
        
        self.listener?.quickSupportRequest.bind(onNext: { [weak self](item) in
            guard let me = self else { return }
            me.qsItemId = item.id
            let v = UIView(frame: .zero)
            me.requestView.setupDisplay(item: item)
            me.requestView.requestMessageLabel.numberOfLines = 0
            me.requestView >>> v >>> {
                $0.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            
            let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            v.frame = CGRect(origin: .zero, size: s)
            
            me.listView?.tableView.tableHeaderView = v
            me._inputView.isHidden = (item.status?.isFinishStatus() == true)
            if (item.status?.isFinishStatus() == true) {
                me.resetTextFieldChat()
                me.bottomTextView?.constant = 40
            } else {
                me.bottomTextView?.constant = 0
            }
            
        }).disposed(by: disposeBag)
        
        listener?.eLoadingObser.bind(onNext: { [weak self] (value) in
            self?.isLoading = value.0
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
    }
}


extension QuickSupportDetailVC: QSRequestViewHandlerProtocol {
    func selectImage(index: Int) {
        self.listener?.showImages(currentIndex: index, stackView: self.requestView.imageStackView)
    }
}


//  File name   : StatusRequestVC.swift
//
//  Author      : MacbookPro
//  Created date: 4/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import FwiCore
import FwiCoreRX

protocol StatusRequestPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func statusRequesttMoveBack()
    func moveToWeb()
    func updateStatus(item: RequestResponseDetail?)
    func createRequestFood(content: String)
    var titleNameObs: Observable<String> {get}
    var itemRequestObsr: Observable<RequestResponseDetail> {get}
    var itemFoodVC: UserRequestTypeFireStore? {get}
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var itemRequest: RequestResponseDetail? {get}
    var keyFoodVC: String? {get}
}

final class StatusRequestVC: UIViewController, StatusRequestPresentable, StatusRequestViewControllable {
    private struct Config {
        static let url = "https://vato.vn/tai-xe-huong-dan-va-dieu-khoan-su-dung-dich-vu-vato-food/"
    }
    
    /// Class's public properties.
    weak var listener: StatusRequestPresentableListener?

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
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private var headerView: PRHeaderView = PRHeaderView.loadXib()
    internal let disposeBag = DisposeBag()
    private var actionView: PRActionButtonRequest = PRActionButtonRequest.loadXib()
    private let typdeDefault: ProcessRequestType = .REGISTER_FOOD
    private var itemRequest: RequestResponseDetail?
    private var content: String?
    private var isEdit: Bool = false
    private var hButtonRequest: Constraint?
    private var bButtonRequest: Constraint?
    let btRequest: UIButton = UIButton(type: .system)
    var tapGesture: UITapGestureRecognizer!
    /// Class's private properties.
}

// MARK: View's event handlers
extension StatusRequestVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension StatusRequestVC {
}

// MARK: Class's private methods
private extension StatusRequestVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.statusRequesttMoveBack()
        }).disposed(by: disposeBag)
        title = "Đăng kí dịch vụ Food"
        
        actionView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.bottom.right.equalToSuperview()
            }
        }
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(actionView.snp.top).offset(0)
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(StatusRequestCell.nib, forCellReuseIdentifier: StatusRequestCell.identifier)
        
        self.actionView.updateUI(typeRequest: self.itemRequest?.status ?? typdeDefault )
        self.headerView.updadteUI(item: self.listener?.itemRequest, keyFood: self.listener?.keyFoodVC)
        
        tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        
        self.tapGesture.rx.event.bind { _ in
            self.view.endEditing(true)
        }.disposed(by: disposeBag)
        
        self.btRequest.setTitle("Xác nhận gửi yêu cầu", for: .normal)
        self.btRequest.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        self.btRequest.setTitleColor(.white, for: .normal)
        self.btRequest.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.btRequest.layer.cornerRadius = 24
        self.view.addSubview(btRequest)
        btRequest.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            bButtonRequest = make.bottom.equalToSuperview().constraint
            hButtonRequest = make.height.equalTo(0).constraint
        }
    }
    private func setupRX() {
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
        
        self.listener?.titleNameObs.bind(onNext: weakify { (name, wSelf) in
            wSelf.headerView.lbHello.text = String(format: "Chào %@", name)
        }).disposed(by: disposeBag)
        
        self.listener?.itemRequestObsr.bind(onNext: weakify { (item, wSelf) in
            wSelf.itemRequest = item
            wSelf.tableView.reloadData()
            wSelf.actionView.updateUI(typeRequest: item.status )
            wSelf.headerView.updadteUI(item: item, keyFood: self.listener?.keyFoodVC)
            wSelf.title = (self.listener?.keyFoodVC == item.requestTypeId) ? "Đăng kí dịch vụ Food" : "Yêu cầu xử lý"
            switch item.status {
            case .CANCEL_AFTER_FEEDBACK, .CANCEL_BEFORE_FEEDBACK:
                wSelf.itemRequest?.status = .CLOSE
                self.listener?.updateStatus(item: wSelf.itemRequest)
            default:
                break
            }
        }).disposed(by: disposeBag)
        
        self.actionView.btCancel.rx.tap.bind(onNext: weakify { (wSelf) in
            if let item = wSelf.itemRequest {
                switch wSelf.itemRequest?.status {
                case .COMPLETED, .REJECT:
                    wSelf.itemRequest?.status = .CLOSE
                    self.listener?.updateStatus(item: wSelf.itemRequest)
                default:
                    wSelf.showAlert(isAgree: false, item: item)
                }
            } else {
                if wSelf.isEdit == false {
                    wSelf.content = ""
                }
                wSelf.listener?.createRequestFood(content: self.content ?? "")
            }
        }).disposed(by: disposeBag)
        
        
        self.headerView.btLink?.rx.tap.bind { _ in
            WebVC.loadWeb(on: self, url: URL(string: Config.url), title: "")
        }.disposed(by: disposeBag)
        
        self.btRequest.rx.tap.bind(onNext: weakify { (wSelf) in
            if wSelf.isEdit == false {
                wSelf.content = ""
            }
            wSelf.listener?.createRequestFood(content: self.content ?? "")
        }).disposed(by: disposeBag)
        
        self.actionView.btAgree?.rx.tap.bind(onNext: weakify { (wSelf) in
            guard let item = wSelf.itemRequest else { return }
            wSelf.showAlert(isAgree: true, item: item)
        }).disposed(by: disposeBag)
        
        setupKeyboardAnimation()
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { (keyboard) in
            let h = keyboard.height
            
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: h, right: 0)
                self.bButtonRequest?.update(inset: h + 10)
                self.btRequest.snp.updateConstraints { (make) in
                    make.height.equalTo( (h > 0) ? 48 : 0 )
                }
                self.view.layoutIfNeeded()
            }
        }.disposed(by: disposeBag)
        
    }
    private func showAlert(isAgree: Bool, item: RequestResponseDetail) {
        let alert: UIAlertController = UIAlertController(title: (isAgree) ? "Xác nhận" : "Huỷ yêu cầu",
                                                         message: (isAgree) ?  "Bạn có đồng ý \(item.requestTypeName ?? "") không?" :"Bạn có muốn huỷ yêu cầu \(item.requestTypeName ?? "")  không?",
                                                          preferredStyle: .alert)
        if isAgree {
            let btNo: UIAlertAction = UIAlertAction(title: "Không", style: .destructive, handler: nil)
            let btConfirm: UIAlertAction = UIAlertAction(title: "Xác nhận", style: .default) { _ in
                self.updateStatus(isAgree: true, item: item)
            }
            alert.addAction(btNo)
            alert.addAction(btConfirm)
        } else {
            let btNo: UIAlertAction = UIAlertAction(title: "Không", style: .cancel, handler: nil)
            let btYes: UIAlertAction = UIAlertAction(title: "Có", style: .default) { _ in
                self.updateStatus(isAgree: false, item: item)
            }
            alert.view.tintColor = #colorLiteral(red: 0, green: 0.4392156863, blue: 0.8823529412, alpha: 1)
            alert.addAction(btNo)
            alert.addAction(btYes)
        }
        self.present(alert, animated: true, completion: nil)
    }
    private func updateStatus(isAgree: Bool, item: RequestResponseDetail) {
        var  itemAgree = item
        if isAgree {
            itemAgree.status = .AGREE_AND_ACCEPT_TERMS
            self.listener?.updateStatus(item: itemAgree)
        } else {
            switch itemAgree.status {
            case .INIT, .AGREE:
                itemAgree.status = .CANCEL
            case .COMPLETED:
                itemAgree.status = .CLOSE
            default:
                break
            }
            self.listener?.updateStatus(item: itemAgree)
        }
    }
}
extension StatusRequestVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
        
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension StatusRequestVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusRequestCell.identifier) as! StatusRequestCell
        if let item = self.itemRequest {
            cell.updateUI(type: item.status, item: item)
        } else {
            cell.updateUIFood(type: .REGISTER_FOOD, item: self.listener?.itemFoodVC)
        }
        cell.tvNote.rx.text.bind(onNext: weakify { (text, wSelf) in
            wSelf.content = text
        }).disposed(by: disposeBag)
        
        cell.tvNote.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        cell.tvNote.rx.didBeginEditing.bind(onNext: weakify { (wSelf) in
            wSelf.isEdit = true
            cell.tvNote.text = nil
            cell.tvNote.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }).disposed(by: disposeBag)
        
        cell.buttonActionCall  = {
            if let url = URL(string: "tel://\(1900667)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        return cell
    }
}
extension StatusRequestVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return actionView
    }
}

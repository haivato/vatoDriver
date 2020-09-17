//  File name   : RSPolicyVC.swift
//
//  Author      : MacbookPro
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import WebKit

protocol RSPolicyPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBackListService()
    func submitbRegisterService()
    func moveToShorcut()
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var isSuccess: Observable<(Bool, String)> { get }
    var urlObs: Observable<String> { get }
}

final class RSPolicyVC: UIViewController, RSPolicyPresentable, RSPolicyViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: RSPolicyPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        loadHTML()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    @IBOutlet weak var btConfirm: UIButton!
    @IBOutlet weak var containerView: UIView?
    private lazy var webView: WKWebView = WKWebView(frame: .zero)
    @IBOutlet weak var btCheck: UIButton!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var lbPolicy: UILabel!
    private let btSubmit: UIButton = UIButton(type: .custom)
    private let disposebag = DisposeBag()
    private var links = [String]()
    /// Class's private properties.
}

// MARK: View's event handlers
extension RSPolicyVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension RSPolicyVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        UpdateList: if let url = navigationAction.request.url?.absoluteString {
            if links.contains(url) {
                links.removeLast()
            } else {
                guard !url.contains("about:blank") else { break UpdateList }
                links.append(url)
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, shrink-to-fit=YES'); document.getElementsByTagName('head')[0].appendChild(meta);"
        webView.evaluateJavaScript(jscript)
    }
}

// MARK: Class's private methods
private extension RSPolicyVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        webView >>> containerView >>> {
            $0.navigationDelegate = self
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_navi_left"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            if !wSelf.links.isEmpty {
                if wSelf.webView.canGoBack {
                    wSelf.webView.goBack()
                } else {
                    wSelf.links = []
                    wSelf.loadHTML()
                }
            } else {
                wSelf.listener?.moveBackListService()
            }
        }).disposed(by: disposebag)
        title = Text.addService.localizedText
        
        self.btConfirm.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.831372549, blue: 0.8470588235, alpha: 1)
        self.btConfirm.isEnabled = false
        
        
        self.vBottom.addSubview(self.btSubmit)
        self.btSubmit.backgroundColor = .clear
        self.btSubmit.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(22)
        }
        
        self.lbPolicy.text = Text.confirmWithPolicy.localizedText
    }
    
    private func loadHTML() {
        listener?.urlObs.take(1).bind(onNext: weakify { (url, wSelf) in
            wSelf.webView.loadHTMLString(url, baseURL: nil)
        }).disposed(by: disposebag)
    }
    
    private func setupRX() {
        listener?.eLoadingObser.bind(onNext: { (item) in
            item.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposebag)
        
        listener?.isSuccess.bind(onNext: weakify { (item, wSelf) in
            wSelf.showAlert(text: item.1)
        }).disposed(by: disposebag)
        
        self.btSubmit.rx.tap.bind { _ in
            if self.btSubmit.isSelected {
                self.btConfirm.isEnabled = false
                self.btConfirm.backgroundColor =   #colorLiteral(red: 0.8156862745, green: 0.831372549, blue: 0.8470588235, alpha: 1)
                self.btCheck.setImage(UIImage(named: "ic_form_checkbox_uncheck"), for: .normal)
                self.btSubmit.isSelected = false
            } else {
                self.btConfirm.isEnabled = true
                self.btConfirm.backgroundColor =   #colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
                self.btCheck.setImage(UIImage(named: "ic_form_checkbox_checked_rs"), for: .normal)
                self.btSubmit.isSelected = true
            }
        }.disposed(by: disposebag)
        
        self.btConfirm.rx.tap.bind { _ in
            self.listener?.submitbRegisterService()
        }.disposed(by: disposebag)

    }
    private func showAlert(text: String) {
        let alert: UIAlertController = UIAlertController(title: "Thông báo",
                                                         message: text,
                                                          preferredStyle: .alert)
            let btConfirm: UIAlertAction = UIAlertAction(title: "Đóng", style: .default) { _ in
                self.listener?.moveToShorcut()
            }
            alert.addAction(btConfirm)
        self.present(alert, animated: true, completion: nil)
    }
}

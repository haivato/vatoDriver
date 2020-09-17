//
//  TopUpNapasWebVC.swift
//  Vato
//
//  Created by khoi tran on 2/7/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import WebKit
import SafariServices
import GCDWebServer

enum TopUpNapasWebType {
    case server(url: URL)
    case local(htmlString: String, redirectUrl: String?)
    case localWithoutServer(htmlString: String)
    
    var redirectUrl: String? {
        switch self {
        case .local(_, let redirectUrl):
            return redirectUrl
        default:
            return nil
        }
    }
    
    var needCheckURL: Bool {
        switch self {
        case .local:
            return true
        default:
            return false
        }
    }
    
}

final class TopUpNapasWebVC: UIViewController {
    struct Config {
        static let headerH: CGFloat = 44
        static let edge = UIApplication.shared.keyWindow?.edgeSafe ?? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        static let messageError = Text.thereWasAnError.localizedText
    }
    
    private lazy var containerHeader: UIView = {
        return createView {
            $0 >>> view >>> {
                $0.snp.makeConstraints { (make) in
                    make.height.equalTo(Config.headerH + (Config.edge.top > 0 ? Config.edge.top : 20))
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.top.equalToSuperview()
                }
            }
        }
    }()
    
    private lazy var containerView: UIView = {
        return createView({ (v) in
            v >>> view >>> {
                $0.snp.makeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.top.equalTo(self.containerHeader.snp.bottom)
                    make.bottom.equalToSuperview()
                }
            }
        })
    }()
    
    private lazy var progressView: UIProgressView = {
        return createView {
            $0.progressTintColor = Color.orange
            $0.trackTintColor = .clear
            $0.progressViewStyle = .default
            $0.progress = 0
            $0.isHidden = true
            $0 >>> self.containerView >>> {
                $0.snp.makeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.height.equalTo(3)
                    make.right.equalToSuperview()
                    make.top.equalToSuperview()
                }
            }
        }
    }()
    
    private lazy var webView: WKWebView = {
        return createView {
            $0.navigationDelegate = self
            $0 >>> self.containerView >>> {
                $0.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
        }
    }()
    
    private lazy var lblTitle: UILabel = {
        return createView {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .white
            $0 >>> self.containerHeader >>> {
                $0.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.bottom.equalTo(-14)
                    make.width.lessThanOrEqualTo(250)
                }
            }
        }
    }()
    
    private lazy var btnClose: UIButton = {
        return createView {
            $0.tintColor = .white
            $0 >>> self.containerHeader >>> {
                $0.snp.makeConstraints { (make) in
                    make.centerY.equalTo(lblTitle.snp.centerY)
                    make.left.equalTo(16)
                    make.size.equalTo(CGSize(width: 44, height: 44))
                }
            }
        }
    }()
    
    private lazy var noItemView = NoItemView(imageName: WebVCErrorCustom.default.iconError, message: WebVCErrorCustom.default.messageError, on: self.webView.scrollView) { [weak self](v) in
        v.frame = self?.webView.bounds ?? .zero
    }
    
    private var mTitle: String?
    private lazy var disposeBag = DisposeBag()
    private var status: [URLQueryItem]?
    private let type: TopUpNapasWebType
    @Published private var result: Bool

    private var mResult = false
    private lazy var server = Middleware(handler: self)
    private var serverURL: URL?
    private var finishLoad: Bool = false
    private var currentURL: URL?
    init(title: String?, type: TopUpNapasWebType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        self.mTitle = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.setStatusBar(using: .lightContent)
        visualize()
        setupRX()
        serverURL = server.start()
        loadURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        defer {
            clearCache()
            server.stop()
        }
        guard self.webView.isLoading else {
            return
        }
        self.webView.stopLoading()
    }
    
    /// Class's private properties.
    private func createView<T: UIView>(_ block: (T) -> ()) -> T {
        let v = T.init(frame: .zero)
        block(v)
        return v
    }
    
    deinit {
        printDebug("\(#function)")
    }
}


extension TopUpNapasWebVC: MiddlewareHandlerDelegate {
    func process(url: URL, block: @escaping GCDWebServerBodyReaderCompletionBlock) {
        print("!!!!URL load: \(url.absoluteString)")
        if url.absoluteString.contains("fileLocal.html") {
            guard !finishLoad else {
                block(Data(), nil)
                return
            }
            
            switch type {
            case .local(let htmlString, _):
                let data = htmlString.data(using: .utf8)
                finishLoad = true
                block(data, nil)
            default:
                fatalError("Please Implement")
            }
        } else {
            guard currentURL != url else {
                block(Data(), nil)
                return
            }
            currentURL = url
            URLSession.shared.dataTask(with: url) { (data, response, e) in
                block(data, e)
            }
        }
    }
}


extension TopUpNapasWebVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = .white
        lblTitle.textAlignment = .center
        btnClose.setImage(#imageLiteral(resourceName: "close-g").withRenderingMode(.alwaysTemplate) ,for: .normal)
        btnClose.contentHorizontalAlignment = .left
        self.webView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        self.lblTitle.text = self.mTitle
        self.containerHeader.backgroundColor = Color.orange
        self.noItemView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        self.webView.scrollView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
    }
    
    private func loadURL() {
        switch type {
        case .local://(let htmlString, _):
            guard let serverURL = serverURL else {
                return
            }
            
            let request = URLRequest(url: serverURL.appendingPathComponent("fileLocal.html"))
            self.webView.load(request)
        case .server(let url):
            let request = URLRequest(url: url)
            self.webView.load(request)
        case .localWithoutServer(let htmlString):
            self.webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    private func clearCache() {
        let dataTypes = Set([WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.webView.rx.observeWeakly(Bool.self, #keyPath(WKWebView.isLoading)).bind { [weak self] in
            let isLoading = ($0 ?? false)
            self?.progressView.isHidden = !isLoading
            guard !isLoading else {
                return
            }
        }.disposed(by: disposeBag)
        
        self.webView.rx.observeWeakly(Double.self, #keyPath(WKWebView.estimatedProgress)).bind { [weak self] in
            self?.progressView.progress = Float($0 ?? 0)
        }.disposed(by: disposeBag)
        
        btnClose.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.result = wSelf.mResult
        })).disposed(by: disposeBag)
        
        if self.mTitle == nil || self.mTitle?.isEmpty == true {
            self.webView.rx.observeWeakly(String.self, #keyPath(WKWebView.title)).bind { [weak self] in
                self?.lblTitle.text = $0
            }.disposed(by: disposeBag)
        }
    }
}
// MARK: Class's public methods
extension TopUpNapasWebVC {
    static func loadWeb(on controller: UIViewController?, title: String?, type: TopUpNapasWebType) -> Observable<Bool> {
        guard let controller = controller else {
            return Observable.empty()
        }
        
        let webVC = TopUpNapasWebVC(title: title, type: type)
        webVC.modalTransitionStyle = .coverVertical
        webVC.modalPresentationStyle = .fullScreen
        controller.present(webVC, animated: true, completion: nil)
        
        return Observable.create { (s) -> Disposable in
            let dispose = webVC.$result.take(1).subscribe(s)
            return Disposables.create {
                webVC.dismiss(animated: true, completion: dispose.dispose)
            }
        }
    }
}

extension TopUpNapasWebVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        noItemView.attach()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        noItemView.attach()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard let status = self.status else { return }
        let result = status.reduce([String: String]()) { (temp, query) -> [String: String] in
            var next = temp
            next[query.name] = query.value
            return next
        }

        guard result.value(for: "status", defaultValue: "") == "SUCCESS" else {
            return
        }
        
        self.mResult = true
        
        if type.needCheckURL,
            type.redirectUrl != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                guard let me = self else { return }
                me.result = true
            }
        } else {
            self.result = true
        }
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check
        if let url = navigationAction.request.url {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            self.status = components?.queryItems
        }
        decisionHandler(.allow)
    }
}


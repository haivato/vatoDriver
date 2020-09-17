//  File name   : BUMainVC.swift
//
//  Author      : vato.
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import VatoNetwork

protocol BUMainProtocol: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Codable
    func requestHistory<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Codable
    var basket: Observable<BasketModel> { get }
    func update(item: DisplayProduct, value: BasketStoreValueProtocol?)
    var selectedEvent: Observable<FoodExploreItem?> { get }
    var source: Observable<[FoodExploreItem]> { get }
    func didSelect(item: FoodExploreItem)
    func didContinue()
    func didConfirmSelect(item: FoodExploreItem)
    func updateState(state: StoreOrderState, idOrderOffline: String)
    var eLoadingObser: Observable<(Bool, Double)> { get }
    func buyUniformsMoveBackRoot()
    func routeToListStation()
}

protocol BUMainPresentableListener: BUMainProtocol {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func buyUniformsMainMoveBack()
}

final class BUMainVC: UIViewController, BUMainPresentable, BUMainViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: BUMainPresentableListener?

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
    private lazy var disposeBag: DisposeBag = DisposeBag()
    private lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    private var controllers = [UIViewController]()
    private var current: Int = 0
    private let history = BUHistoryVC()
    private let chooseUniformVC = BUChooseUniformVC()
    private var buttons = [UIButton]()
}

// MARK: View's event handlers
extension BUMainVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension BUMainVC {
    func showAlerConfirmChangStation(item: FoodExploreItem) {
        AlertVC.showMessageAlert(for: self, title: "Xác nhận", message: "Khi thay đổi địa chỉ nhận hàng. giỏ hàng sẽ bị xoá", actionButton1: "Không", actionButton2: "Thay đổi", handler2: { [weak self] in
            self?.listener?.didConfirmSelect(item: item)
        })
    }
    
    func showError(error: NSError) {
        AlertVC.showError(for: self, error: error)
    }
    
    func showHistory() {
        self.history.refresh(needScrollTop: true)
        mainAsync { (_) in
            self.chooseUniformVC.reloadData()
        }(())
        let button = self.buttons[safe: 1]
        button?.sendActions(for: .touchUpInside)
    }
    
    func refreshHistory() {
        self.history.refresh(needScrollTop: true)
    }
}

// MARK: Class's private methods
private extension BUMainVC {
    private func localize() {
        // todo: Localize view's here.
        self.title = "Mua đồng phục"
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(.alwaysOriginal)
        let leftBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = leftBarItem
        leftBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.buyUniformsMainMoveBack()
        }.disposed(by: disposeBag)
        
        let imageR = UIImage(named: "ic_header_vato")?.withRenderingMode(.alwaysOriginal)
        let rightBarItem = UIBarButtonItem(image: imageR, landscapeImagePhone: imageR, style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightBarItem
        rightBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.buyUniformsMoveBackRoot()
        }.disposed(by: disposeBag)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        let titles = ["CHỌN HÀNG", "ĐANG MUA"]
        self.buttons = [UIButton]()
        let segment = VatoSegmentView(numberSegment: titles.count, space: 0) { [weak self] (button, idx) in
            guard let wSelf = self else { return }
            let text = titles[safe: idx]
            button.setTitle(text, for: .normal)
            button.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1), for: .normal)
            button.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            wSelf.buttons.addOptional(button)
            button.rx.tap.bind { (_) in
                guard let wSelf = self else { return }
                wSelf.selected(idx: idx)
            }.disposed(by: wSelf.disposeBag)
        }
        
        segment >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.right.left.equalToSuperview()
                make.height.equalTo(48)
            }
        }
        
        segment.addSeperator()
        pageVC.view >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(segment.snp.bottom)
            }
        }
        self.addChild(pageVC)
        pageVC.didMove(toParent: self)
        setupChildsController()
        
    }
    
    func setupChildsController() {
        
        chooseUniformVC.listener = listener
        controllers.append(chooseUniformVC)

        history.listener = listener
        controllers.append(history)
        // Set
        pageVC.setViewControllers([controllers[0]], direction: .forward, animated: false, completion: nil)
    }
    
    private func selected(idx: Int) {
          guard current != idx else {
              return
          }
          
          let direction: UIPageViewController.NavigationDirection = idx > current ? .forward : .reverse
          guard let vc = controllers[safe: idx] else {
              return
          }
          current = idx
          pageVC.setViewControllers([vc], direction: direction, animated: true, completion: nil)
        
        if idx == 0 {
            self.title = "Mua đồng phục"
        } else {
            self.title = "Quản lý đơn hàng"
        }
      }
    
    private func setupRX() {
        listener?.eLoadingObser.bind(onNext: { (value) in
            value.0 ? LoadingManager.instance.show() : LoadingManager.instance.dismiss()
        }).disposed(by: disposeBag)
    }
}

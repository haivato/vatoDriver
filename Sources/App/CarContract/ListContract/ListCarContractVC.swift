//  File name   : ListCarContractVC.swift
//
//  Author      : Phan Hai
//  Created date: 09/09/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxCocoa
import RxSwift

typealias ContractHistoryType = OrderContract

protocol ListCarHistoryHandlerProtocol: AnyObject {
    var itemGetList: Observable<Bool> { get }
    func requestList(params: [String: Any]) -> Observable<ResponsePagingContract<ContractHistoryType>>
    func select(item: ContractHistoryType)
}
protocol ListCarContractRemoveProtocol: UIViewController {
    var type: ContractCarOrderType { get }
    func refresh()
}

protocol ListCarContractPresentableListener: ListCarHistoryHandlerProtocol {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBackHome()
}

final class ListCarContractVC: UIViewController, ListCarContractPresentable, ListCarContractViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    private var controllers: [ListCarContractRemoveProtocol] = []
    weak var listener: ListCarContractPresentableListener?
    @IBOutlet weak var btListRequest: UIButton!
    @IBOutlet weak var btContract: UIButton!
    @IBOutlet weak var vLine: UIView!
    private var currentIdx = 0
    private let disposeBag = DisposeBag()
    private lazy var pageVC: UIPageViewController = {
        guard let p = self.children.compactMap ({ $0 as? UIPageViewController }).first else {
            fatalError("Please Implement")
        }
        return p
    }()

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
}

// MARK: View's event handlers
extension ListCarContractVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ListCarContractVC {
}

// MARK: Class's private methods
private extension ListCarContractVC {
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
        
        let controllers =  ContractCarOrderType.allCases.map { type -> ListCarContractRemoveProtocol in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: ListCar.identifier) as? ListCar else {
                fatalError("Please Implement")
            }
            vc.type = type
            vc.listener = listener
            return vc
        }
        self.controllers = controllers
        self.pageVC.setViewControllers([controllers[0]], direction: .forward, animated: false, completion: nil)
    }
    private func setupRX() {
        let listRequestType = self.btListRequest.rx.tap.map { _ in ContractCarOrderType.listRequest }
        let contract = self.btContract.rx.tap.map { _ in ContractCarOrderType.history }
        
        Observable.merge([listRequestType, contract]).bind(onNext: weakify({ (type, wSelf) in
            wSelf.handle(type: type)
        })).disposed(by: disposeBag)
    }
    private func handle(type: ContractCarOrderType) {
        guard currentIdx != type.rawValue else {
            return
        }
        guard let controller = self.controllers[safe: type.rawValue] else {
            return
        }
        let direction: UIPageViewController.NavigationDirection = currentIdx < type.rawValue ? .forward : .reverse
        pageVC.setViewControllers([controller], direction: direction, animated: true, completion: nil)
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
        currentIdx = type.rawValue
        let positionX = self.view.bounds.width / 2
        UIView.animate(withDuration: 0.5) {
            self.vLine.transform = CGAffineTransform(translationX: CGFloat(type.rawValue) * positionX, y: 0)
        }
    }
}

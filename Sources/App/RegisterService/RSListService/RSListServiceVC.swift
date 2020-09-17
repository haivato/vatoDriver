//  File name   : RSListServiceVC.swift
//
//  Author      : MacbookPro
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa

protocol RSListServicePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveToRegisterService()
    func moveBackShortcut()
    func moveToPolicy(array: [ListServiceVehicel])
    func showAlert(text: String)
    var titleNameObs: Observable<String> {get}
    var itemCarObs: Observable<CarInfo> {get}
    var listServiceObs: Observable<[ListServiceVehicel]> {get}
    var displayName: Observable<String> {get}
    var displayNumber: Observable<String> {get}
    
}

final class RSListServiceVC: UIViewController, RSListServicePresentable, RSListServiceViewControllable {
    private struct Config {
       
    }
    
    /// Class's public properties.
    weak var listener: RSListServicePresentableListener?

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
    private var headerView: PRHeaderView = PRHeaderView.loadXib()
    private let disposebag = DisposeBag()
    private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private let lbNumberService: UILabel = UILabel(frame: .zero)
    private let lbNameService: UILabel = UILabel(frame: .zero)
    private var itemCar: CarInfo?
    private var listService: [ListServiceVehicel] = []
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var btConfirm: UIButton!
    /// Class's private properties.
}

// MARK: View's event handlers
extension RSListServiceVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension RSListServiceVC {
}

// MARK: Class's private methods
private extension RSListServiceVC {
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
        buttonLeft.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBackShortcut()
        }).disposed(by: disposebag)
        title = Text.numberCar.localizedText 
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(self.viewButton.snp.top)
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true 
        tableView.register(PRCreateRequestCell.nib, forCellReuseIdentifier: PRCreateRequestCell.identifier)
        
        headerView.lbContentHeader.text = Text.headerRegisterService.localizedText
        
        self.lbNumberService.text = Text.numberCar.localizedText
        self.lbNameService.text = Text.nameCar.localizedText
        
        self.btConfirm.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.831372549, blue: 0.8470588235, alpha: 1)
        self.btConfirm.isEnabled = false
    }
    private func setupRX() {
        
        self.listener?.titleNameObs.asObservable().bind(onNext: weakify { (name, wSelf) in
            wSelf.headerView.lbHello.text = String(format: Text.hello.localizedText, name)
        }).disposed(by: disposebag)
        
        self.listener?.itemCarObs.asObservable().bind(onNext: weakify { (car, wSelf) in
            wSelf.lbNameService.text = car.marketName
            wSelf.lbNumberService.text = car.plate
            wSelf.tableView.reloadData()
        }).disposed(by: disposebag)
        
        self.listener?.displayName.asObservable().bind(onNext: weakify { (car, wSelf) in
            wSelf.lbNameService.text = car
            wSelf.tableView.reloadData()
        }).disposed(by: disposebag)
        self.listener?.displayNumber.asObservable().bind(onNext: weakify { (car, wSelf) in
            wSelf.lbNumberService.text = car
            wSelf.tableView.reloadData()
        }).disposed(by: disposebag)
        
        self.listener?.listServiceObs.asObservable().bind(onNext: weakify { (listService, wSelf) in
            wSelf.listService = listService
            wSelf.tableView.reloadData()
        }).disposed(by: disposebag)
        
        self.btConfirm.rx.tap.bind { _ in
            var arraySelect: [ListServiceVehicel] = []
            let indexPaths = self.tableView.indexPathsForSelectedRows

            if let indexPaths = indexPaths {
                let a = indexPaths.map({ (index) -> ListServiceVehicel in
                    return self.listService[index.row]
                })
                arraySelect.append(contentsOf: a)
                self.listener?.moveToPolicy(array: arraySelect)
            }
        }.disposed(by: disposebag)
        
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let wSelf = self else { return }
            if let indexPath = wSelf.tableView.indexPathsForSelectedRows {
                wSelf.btConfirm.isEnabled = true
                wSelf.btConfirm.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            }
        }.disposed(by: disposebag)
    }
}
extension RSListServiceVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        v.clipsToBounds = true
        
        let lbAddService: UILabel = UILabel(frame: .zero)
        lbAddService.text = Text.selectAddService.localizedText
        lbAddService.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5058823529, alpha: 1)
        lbAddService.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        v.addSubview(lbAddService)
        lbAddService.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(10)
            make.right.equalToSuperview()
        }

        let vLine: UIView = UIView(frame: .zero)
        vLine.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)

        v.addSubview(vLine)
        vLine.snp.makeConstraints { (make) in
            make.left.equalTo(lbAddService)
            make.bottom.equalTo(lbAddService.snp.top).inset(-16)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        lbNumberService.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        lbNumberService.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        v.addSubview(lbNumberService)
        lbNumberService.snp.makeConstraints { (make) in
            make.left.equalTo(vLine)
            make.bottom.equalTo(vLine.snp.top).inset(-16)
            make.right.equalToSuperview()
        }
        
        lbNameService.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        lbNameService.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        v.addSubview(lbNameService)
        lbNameService.snp.makeConstraints { (make) in
            make.left.equalTo(vLine)
            make.bottom.equalTo(lbNumberService.snp.top).inset(-4)
            make.right.equalToSuperview()
        }
        
        let lbSelectService: UILabel = UILabel(frame: .zero)
        lbSelectService.text = Text.selectCarInGara.localizedText
        lbSelectService.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        lbSelectService.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        v.addSubview(lbSelectService)
        lbSelectService.snp.makeConstraints { (make) in
            make.left.equalTo(vLine)
            make.bottom.equalTo(lbNameService.snp.top).inset(-6)
            make.right.equalToSuperview()
        }
        
        let btChange: UIButton = UIButton(type: .custom)
        btChange.setTitle(Text.change.localizedText, for: .normal)
        btChange.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        btChange.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .normal)
        
        v.addSubview(btChange)
        btChange.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalTo(vLine.snp.top).inset(-31)
        }
        
        v.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(lbSelectService.snp.top).inset(-32)
        }
        
        btChange.rx.tap.bind { _ in
            self.listener?.moveToRegisterService()
        }.disposed(by: disposebag)

        return v
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension RSListServiceVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PRCreateRequestCell.identifier) as! PRCreateRequestCell
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cell.updateUI(model: self.listService[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.listService[indexPath.row].status == .APPROVE {
            return nil
        }
        return indexPath
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let indexPath = self.tableView.indexPathsForSelectedRows {
            
        } else {
            self.btConfirm.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.831372549, blue: 0.8470588235, alpha: 1)
            self.btConfirm.isEnabled = false
        }
    }
    
}

//
//  FavoritePlaceViewController.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD
import VatoNetwork
import FwiCoreRX
import Alamofire



let orangeColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1)

class FavoritePlaceViewController: UIViewController {
    @objc open var didSelectModel: ((ActiveFavoriteModeModel?) -> Void)?
    
    // MARK: - property
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    
    private var searchPlaceVC: ShowPlaceViewController!
    
    private lazy var disposeBag = DisposeBag()
    
    var viewModel = FavoritePlaceVM()
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setRX()
        //        self.viewModel.getData()
        self.requestData()
        
        searchPlaceVC = ShowPlaceViewController(viewModel: self.viewModel.generateShowPlaceVM())
        self.addChild(searchPlaceVC)
        self.viewContent.addSubview(searchPlaceVC.view)
        searchPlaceVC.view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.tableView)
        }
        searchPlaceVC.view.isHidden = true
        
        searchPlaceVC.didSelect = { [weak self] model in
            guard let lat = model.location?.lat,
                let lon = model.location?.lon else { return }
            let latStr = "\(lat)"
            let lonStr = "\(lon)"
            
            let placeModel = PlaceModel(id: nil, name: nil, address: model.address, typeId: .Orther, lat: latStr, lon: lonStr)
            let UpdatePlaceVM = self?.viewModel.generateUpdateViewModel(model: placeModel)
            let vc = UpdatePlaceViewController(mode: UpdatePlaceMode.create, viewModel: UpdatePlaceVM)
            vc.needReloadData = {[weak self] in
                self?.textField.text = ""
                self?.searchPlaceVC.view.isHidden = true
//                self?.searchPlaceVC.searchWithKeywork(keyword: "")
                self?.requestData()
                
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        self.tipLabel.text = ""
        FavoritePlaceManager.shared.getStatusFavMode {[weak self] (error) in
            var value = ""
            if error == nil {
                if let activeFavoriteModeModel = FavoritePlaceManager.shared.activeFavoriteModeModel {
                    value = "Đã sử dụng địa điểm cá nhân trong hôm nay (\(activeFavoriteModeModel.getNumberActiveInDay())/\(activeFavoriteModeModel.getMaxActiveInDay()))"
                }
            }
            self?.tipLabel.text = value
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if let indexPath = self.searchPlaceVC.tableView.indexPathForSelectedRow {
            self.searchPlaceVC.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    // MARK: - Private method
    private func setupNavigationBar() {
        self.title = Text.favoritePlace.localizedText
        
        // left button
        var imageLeftButton = UIImage(named: "back-white")
        imageLeftButton = imageLeftButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeftButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
        
        // right button
        var imageRightButton = UIImage(named: "iconHeaderMap")
        imageRightButton = imageRightButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imageRightButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    func setRX(){
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(){ [weak self] event in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            } .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(){ [weak self] event in
                guard let self = self else { return }
                self.showPinLoationVC()
            }
            .disposed(by: disposeBag)
        
        self.textField.rx.text
            .filter { [weak self] _ in
                self?.textField.isFirstResponder == true
            }.debounce(RxTimeInterval.milliseconds(3), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }
                if let keyword = keyword, !keyword.isEmpty {
                    self.searchPlaceVC.searchWithKeywork(keyword: keyword)
                } else {
                    self.searchPlaceVC.view.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.tableView.rx.setDataSource(self).disposed(by: disposeBag)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.tableView.keyboardDismissMode = .onDrag
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.tableView.register(UINib(nibName: "PlaceTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PlaceTableHeaderView")
        
        
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let self = self else { return }
            if let model = self.viewModel.getModel(at: indexPath) {
                self.tableView.deselectRow(at: indexPath, animated: true)
                if model.id != nil {
                    self.confirmChangeFavePlace(model: model)
                } else {
                    self.showUpdateCreateViewControler(mode: .create, indexPath: indexPath)
                }
            }
            }.disposed(by: disposeBag)
    }
    
    private func showPinLoationVC() {
        let vc = PinLocationViewController()
        vc.didSelect = {[weak self] model in
            guard let self = self else { return }
            guard let lat = model.location?.lat,
                let lon = model.location?.lon else { return }
            let latStr = "\(lat)"
            let lonStr = "\(lon)"
            
            let placeModel = PlaceModel(id: nil, name: nil, address: model.fullAddress, typeId: .Orther, lat: latStr, lon: lonStr)
            let UpdatePlaceVM = self.viewModel.generateUpdateViewModel(model: placeModel)
            let updateVC = UpdatePlaceViewController(mode: UpdatePlaceMode.create, viewModel: UpdatePlaceVM)
            updateVC.needReloadData = {[weak self] in
                self?.removeViewPinLocationFromNavigation(vc: vc)
                self?.textField.text = ""
                self?.requestData()
            }
            self.navigationController?.pushViewController(updateVC, animated: true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func removeViewPinLocationFromNavigation(vc: PinLocationViewController) {
        var listArrVC = self.navigationController?.viewControllers
        if listArrVC != nil,
            listArrVC!.count > 0{
            for index in 0..<listArrVC!.count {
                let currentVC = listArrVC![index]
                if currentVC == vc {
                    listArrVC!.remove(at: index)
                    self.navigationController?.viewControllers = listArrVC!
                    return
                }
            }
        }
    }
    
    func requestData() {
        self.getData().bind { [weak self](list) in
            self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    func loadCreateCar() {
        if let viewModel = FCBookingService.shareInstance()?.homeViewModel,
            let carManagementVC = CarManagementViewController(viewWith: viewModel) {
            let nav = FacecarNavigationViewController(rootViewController: carManagementVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    func activeFavoriteMode(model: PlaceModel) {
        if let viewModel = FCBookingService.shareInstance()?.homeViewModel,
            viewModel.checkIsHaveVehicle() == false{
            UIAlertController.showAlert(in: self, withTitle: "Thông báo", message: "Rấc tiếc, bạn chưa đăng ký xe nào trong hệ thống.\nĐăng ký ngay!", cancelButtonTitle: "Đóng", destructiveButtonTitle: "Đăng ký", otherButtonTitles: nil) {[weak self](controller, action, buttonIndex) in
                if (buttonIndex == 1) {
                    self?.loadCreateCar()
                }
            }
            return
        }
        
        guard let placeId = model.id else { return }
        SessionManager.shared.firebaseToken()
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                UIApplication.shared.beginIgnoringInteractionEvents()
                LoadingManager.instance.show()
                var currentLocation = CLLocation(latitude: 0, longitude: 0)
                if let location = GoogleMapsHelper.shareInstance().currentLocation {
                    currentLocation = location
                }
                return Requester.request(using: VatoAPIRouter.driverActiveFavMode(authToken: authToken, placeId: placeId, coordinate: currentLocation.coordinate), method: .post,
                                         encoding: JSONEncoding.default)
            }.map { $0.1 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                DispatchQueue.main.async { [weak self] in
                    guard let responseManager = ResponseManager.create(data: data) else { return }
                    if let error = responseManager.error {
                        // throw error
                        AlertVC.showError(for: self, error: error)
                    } else {
                        if let activeFavoriteModeModel = ActiveFavoriteModeModel.create(json: responseManager.data) {
                            self?.didSelectModel?(activeFavoriteModeModel)
                            self?.dismiss(animated: true, completion: nil)
                            
                        }
                    }
                    LoadingManager.instance.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }, onError: { (error) in
                DispatchQueue.main.async { [weak self] in
                    AlertVC.showError(for: self, error: error as NSError)
                    LoadingManager.instance.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }).disposed(by: disposeBag)
    }
    
    func changPlace(model: PlaceModel) {
        
        guard let placeId = model.id,
            let activeId = FavoritePlaceManager.shared.activeFavoriteModeModel?.id else  { return }
        SessionManager.shared.firebaseToken()
            .take(1)
            .timeout(7.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                UIApplication.shared.beginIgnoringInteractionEvents()
                LoadingManager.instance.show()
                return Requester.request(using: VatoAPIRouter.driverChangPlaceFavMode(authToken: authToken ?? "", activeId: activeId, placeId: placeId), method: .put,
                                         encoding: JSONEncoding.default)
            }.map {
                $0.1
            }.observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                DispatchQueue.main.async { [weak self] in
                    guard let responseManager = ResponseManager.create(data: data) else { return }
                    if let error = responseManager.error {
                        // throw error
                        AlertVC.showError(for: self, error: error)
                    } else {
                        if let activeFavoriteModeModel = ActiveFavoriteModeModel.create(json: responseManager.data) {
                            self?.didSelectModel?(activeFavoriteModeModel)
                            self?.dismiss(animated: true, completion: nil)
                            
                        }
                    }
                    LoadingManager.instance.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }, onError: { (error) in
                DispatchQueue.main.async { [weak self] in
                    AlertVC.showError(for: self, error: error as NSError)
                    LoadingManager.instance.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }).disposed(by: disposeBag)
    }
    
    
    func getData() -> Observable<[PlaceModel]> {
        let router = SessionManager.shared.firebaseToken().map {
            VatoAPIRouter.getFavPlaceList(authToken: $0, isDriver: true)
        }
        UIApplication.shared.beginIgnoringInteractionEvents()
        LoadingManager.instance.show()
        return router.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<[PlaceModel]>.self, using: $0)
            }.observeOn(MainScheduler.instance)
            .map {[weak self] r in
                guard let self = self else { return [] }
                if let e = r.response.error {
                    AlertVC.showError(for: self, error: e as NSError)
                    throw e
                } else {
                    // tksu warning
                    // let list = r.response.data.orNil(default: [])
                    var list = [PlaceModel]()
                    if let data = r.response.data {
                        list = data
                        // self.viewModel.listModelFavorite = PlaceModel.generateModel(listModelBackend: list)
                        self.viewModel.listModelFavorite = list
                        LoadingManager.instance.dismiss()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    return list
                }
            }.catchError { (e) in
                AlertVC.showError(for: self, error: e as NSError)
                LoadingManager.instance.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
                throw e
        }
    }
    
    private func showUpdateCreateViewControler(mode: UpdatePlaceMode, indexPath: IndexPath?) {
        let UpdatePlaceVM = self.viewModel.generateUpdateViewModel(indexPath: indexPath)
        let vc = UpdatePlaceViewController(mode: mode, viewModel: UpdatePlaceVM)
        vc.needReloadData = {[weak self] in
            self?.requestData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupActionMore(for cell: FavoritePlaceTableViewCell) {
        
        let alertController = UIAlertController(title: nil, message: "Tùy chọn.", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Sửa", style: .default, handler: {[weak self] (alert: UIAlertAction!) -> Void in
            if let indexPath = self?.tableView.indexPath(for: cell),
                let model = self?.viewModel.getModel(at: indexPath) {
                if self?.checkPlaceIsActive(model: model) == false {
                    self?.showUpdateCreateViewControler(mode: UpdatePlaceMode.update, indexPath: indexPath)
                }
            }
        })
        
        let deleteAction = UIAlertAction(title: "Xóa", style: .destructive, handler: {[weak self] (alert: UIAlertAction!) -> Void in
            if let indexPath = self?.tableView.indexPath(for: cell),
                let model = self?.viewModel.getModel(at: indexPath) {
                self?.confirmDeleteFavAddress(model: model)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkPlaceIsActive(model: PlaceModel) -> Bool {
        if let activeFavoriteModeModel = FavoritePlaceManager.shared.activeFavoriteModeModel,
            let placeIdActive = activeFavoriteModeModel.placeId,
            let placeIdCurrent = model.id,
            placeIdCurrent == placeIdActive {
            let message = "Địa điểm này đang được sử dụng để làm địa điểm cá nhân. Nên bạn không được thay đổi"
            AlertVC.showMessageAlert(for: self, title: Text.confirm.localizedText, message: message, actionButton1: Text.cancel.localizedText, actionButton2: nil, handler2:nil)
            return true
        }
        return false
    }
    
    func confirmDeleteFavAddress(model: PlaceModel) {
        if self.checkPlaceIsActive(model: model) {
            return
        }
        
        AlertVC.showMessageAlert(for: self, title: Text.confirm.localizedText, message: Text.deleteThisPlaceConfirm.localizedText, actionButton1: Text.cancel.localizedText, actionButton2: Text.deletePlace.localizedText, handler2:{[weak self] in
            guard let self = self else { return }
            self.deleteFavAddress(model: model)
        })
    }
    
    func confirmChangeFavePlace(model: PlaceModel) {
        if let activeFavoriteModeModel = FavoritePlaceManager.shared.activeFavoriteModeModel,
            activeFavoriteModeModel.getIsActive() == true  {
            AlertVC.showMessageAlert(for: self, title: Text.confirm.localizedText, message: "Bạn đang trong chế độ Địa điểm cá nhân. Bạn có muốn đổi sang địa điểm này không?", actionButton1: Text.cancel.localizedText, actionButton2: "Thay đổi", handler2:{ [weak self] in
                guard let self = self else { return }
                self.changPlace(model: model)
            })
        } else {
            if let activeFavoriteModeModel = FavoritePlaceManager.shared.activeFavoriteModeModel,
                activeFavoriteModeModel.getNumberActiveInDay() >= activeFavoriteModeModel.getMaxActiveInDay() {
                AlertVC.showMessageAlert(for: self, title: Text.confirm.localizedText, message: "Đã sử dụng hết số lần cho chức năng địa điểm yêu thích", actionButton1: Text.cancel.localizedText, actionButton2: nil, handler2:nil)
                return;
            }
            self.activeFavoriteMode(model: model)
        }
    }
    
    func deleteFavAddress(model: PlaceModel?) {
        self.deleteFavPlace(model: model)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self](_) in
                self?.requestData()
                }, onError: { (e) in
                    AlertVC.showError(for: self, message: e.localizedDescription)
            },onDisposed: {
                LoadingManager.instance.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }).disposed(by: disposeBag)
    }
    
    func deleteFavPlace(model: PlaceModel?) -> Observable<Data>{
        guard let placeId = model?.id else { return Observable.empty() }
        
        
        return SessionManager.shared.firebaseToken()
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                UIApplication.shared.beginIgnoringInteractionEvents()
                LoadingManager.instance.show()
                return Requester.request(using: VatoAPIRouter.deleteFavPlace(authToken: authToken, placeId: placeId),
                                         method: .delete,
                                         encoding: JSONEncoding.default)
                
            }.map {
                $0.1
                
        }
    }
}

extension FavoritePlaceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getNumberSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberRow(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "FavoritePlaceTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavoritePlaceTableViewCell
        if cell == nil {
            cell = FavoritePlaceTableViewCell.newCell(reuseIdentifier: identifier)
        }
        if let model = self.viewModel.getModel(at: indexPath) {
            cell?.displayData(model: model)
        }
        cell?.didselectMoreButton = {[weak self] _cell in
            self?.setupActionMore(for: _cell)
        }
        return cell!
    }
    
}

extension FavoritePlaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewModel.getNumberRow(section: section) > 0 {
            return 40
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
    // MARK - tableview delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewModel.getNumberRow(section: section) == 0 {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PlaceTableHeaderView") as! PlaceTableHeaderView
        headerView.displayWithText(text: self.viewModel.getHeaderText(section: section))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

//
//  UpdatePlaceViewController.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FwiCoreRX
import VatoNetwork
import Alamofire
import SVProgressHUD

enum UpdatePlaceMode {
    case create
    case update
}

class UpdatePlaceViewController: UIViewController {
    var needReloadData: (() -> Void)?
    
    var modeSubject = BehaviorSubject<UpdatePlaceMode>(value: UpdatePlaceMode.create)
    var viewModel: UpdatePlaceVM!
    
    // MARK: - property
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var buttonActionAddress: UIButton!
    @IBOutlet weak var saveAddressButton: UIButton!
    @IBOutlet weak var addressTextfield: UITextField!
    internal lazy var disposeBag = DisposeBag()
    @IBOutlet var buttonSaveAddressKeyboard: UIButton!
    
    @IBOutlet var viewAccessoryKeyboard: UIView!
    private var listSection = [FavoritePlaceSection.Fav, FavoritePlaceSection.Other]
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        self.nameTextField.placeholder = Text.nameOfPlace.localizedText
        self.saveAddressButton.setTitle(Text.savePlace.localizedText, for: .normal)
        self.buttonSaveAddressKeyboard.setTitle(Text.savePlace.localizedText, for: .normal)
        
        self.nameTextField.inputAccessoryView = self.viewAccessoryKeyboard
        fillData()
        setRX()
    }

    convenience init(mode: UpdatePlaceMode, viewModel: UpdatePlaceVM?) {
        self.init()
        self.modeSubject.onNext(mode)
        self.viewModel = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Private method
    private func setupNavigationBar() {
        self.title = Text.favoritePlace.localizedText
        
        // left button
        var imageLeftButton = UIImage(named: "back-white")
        imageLeftButton = imageLeftButton?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeftButton, style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    func setRX(){
        self.nameTextField.becomeFirstResponder()
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(){[weak self] event in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        
        self.modeSubject.subscribe { mode in
            if mode.element == .create {
                self.title = Text.addFavoritePlace.localizedText
            } else {
                self.title = Text.updateFavoritePlace.localizedText
            }
        }.disposed(by: disposeBag)

        self.nameTextField.rx.text
            .subscribe(onNext: { [weak self] keyword in
                self?.viewModel.updateName(name: keyword)
                self?.checkEnableButtonConfirm()
            })
            .disposed(by: disposeBag)
 
        self.buttonSaveAddressKeyboard.rx.tap
            .subscribe(){ [weak self]event in
                guard let self = self else { return }
                self.checkCreateOrUpdate()
            }
            .disposed(by: disposeBag)
        
        self.buttonActionAddress.rx.tap
            .subscribe(){event in
                let vc = SearchPlaceViewController(viewModel: self.viewModel.generateSearchPlaceVM())
                vc.didSelect = {[weak self] model in
                    self?.viewModel.updateModel(model: model)
                    vc.navigationController?.popViewController(animated: true)
                    self?.fillData()
                }
                vc.didSelectDetail = {[weak self] model in
                    self?.viewModel.updateModelFromDetail(model: model)
                    self?.fillData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        self.saveAddressButton.rx.tap
            .subscribe(){ [weak self]event in
                guard let self = self else { return }
                self.checkCreateOrUpdate()
            }
            .disposed(by: disposeBag)
    }
    
    func checkCreateOrUpdate() {
        self.modeSubject.take(1).subscribe(onNext: {[weak self] mode in
            guard let self = self else { return }
            if mode == .update && self.viewModel.model?.id != nil {
                self.updateFavAddress()
            } else {
                self.createFavAddress()
            }

        }).disposed(by: disposeBag)
    }
    
    private lazy var indicator: ActivityIndicator = ActivityIndicator()
    func createFavAddress() {
        self.createFavPlace()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self](_) in
                self?.needReloadData?()
                self?.navigationController?.popViewController(animated: true)
            }, onError: { (e) in
                let error = e as NSError
                AlertVC.showError(for: self, error: error)
            },onDisposed: {
                LoadingManager.instance.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }).disposed(by: disposeBag)
 
    }
    
    func createFavPlace() -> Observable<Data>{
        guard let name = self.viewModel.model?.name?.trim(),
            let address = self.viewModel.model?.address,
            let typeId = self.viewModel.model?.typeId.rawValue,
            let lat = self.viewModel.model?.lat,
            let long = self.viewModel.model?.lon else { return Observable.empty() }
        
        
        return SessionManager.shared.firebaseToken()
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                UIApplication.shared.beginIgnoringInteractionEvents()
                LoadingManager.instance.show()
                return Requester.request(using: VatoAPIRouter.createFavPlace(authToken: authToken,
                                                                             name: name,
                                                                             address: address,
                                                                             typeId: typeId,
                                                                             lat: lat, lon: long,isDriver: true),
                                                                             method: .post,
                                                                             encoding: JSONEncoding.default)
                
            }.map {
                $0.1
                
        }
    }
    
    func confirmDeleteFavAddress() {
        AlertVC.showMessageAlert(for: self, title: Text.confirm.localizedText, message: Text.deleteThisPlaceConfirm.localizedText, actionButton1: Text.cancel.localizedText, actionButton2: Text.deletePlace.localizedText, handler2:{[weak self] in
            guard let self = self else { return }
            self.deleteFavAddress()
        })
    }
    
    func deleteFavAddress() {
        self.deleteFavPlace()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self](_) in
                self?.needReloadData?()
                self?.navigationController?.popViewController(animated: true)
                }, onError: { (e) in
                    AlertVC.showError(for: self, message: e.localizedDescription)
            },onDisposed: {
                LoadingManager.instance.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }).disposed(by: disposeBag)
    }
    
    func deleteFavPlace() -> Observable<Data>{
        guard let placeId = self.viewModel.model?.id else { return Observable.empty() }
        
        
        return SessionManager.shared.firebaseToken()
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                UIApplication.shared.beginIgnoringInteractionEvents()
                LoadingManager.instance.show()
                return Requester.request(using: VatoAPIRouter.deleteFavPlace(authToken: authToken, placeId: placeId),
                                         method: .delete,
                                         encoding: JSONEncoding.default)
                
            }.map { $0.1 }
    }
    
    func updateFavAddress() {
        self.updateFavPlace()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self](_) in
                self?.needReloadData?()
                self?.navigationController?.popViewController(animated: true)
                }, onError: { (e) in
                    AlertVC.showError(for: self, message: e.localizedDescription)
            },onDisposed: {
                LoadingManager.instance.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }).disposed(by: disposeBag)
        
    }
    
    func updateFavPlace() -> Observable<Data>{
        guard let name = self.viewModel.model?.name?.trim(),
            let address = self.viewModel.model?.address,
            let typeId = self.viewModel.model?.typeId.rawValue,
            let lat = self.viewModel.model?.lat,
            let id = self.viewModel.model?.id,
            let long = self.viewModel.model?.lon else { return Observable.empty() }
        
        
        return SessionManager.shared.firebaseToken()
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                UIApplication.shared.beginIgnoringInteractionEvents()
                LoadingManager.instance.show()
                return Requester.request(using: VatoAPIRouter.updateFavPlace(authToken: authToken,
                                                                             placeId: id,
                                                                             name: name,
                                                                             address: address,
                                                                             typeId: typeId,
                                                                             lat: lat, lon: long,isDriver: true),
                                         method: .put,
                                         encoding: JSONEncoding.default)
                
            }.map { $0.1 }
    }
    
    func fillData() {
        self.nameTextField.text = self.viewModel.model?.name
        self.nameTextField.isEnabled = self.viewModel.isAllowEditName()
        self.addressTextfield.text = self.viewModel.getAddress() ?? ""
        self.addressTextfield.textColor = UIColor.black
        self.checkEnableButtonConfirm()
    }
    
    func checkEnableButtonConfirm() {
        if let address = self.viewModel.model?.address,
            address.count > 0,
            let name = self.viewModel.model?.name?.trim(),
            name.count > 0 {
            self.saveAddressButton.isEnabled = true
            self.saveAddressButton.backgroundColor = orangeColor
            self.buttonSaveAddressKeyboard.isEnabled = true
            self.buttonSaveAddressKeyboard.backgroundColor = orangeColor
            return
        }
        self.saveAddressButton.isEnabled = false
        self.saveAddressButton.backgroundColor = UIColor.lightGray
        self.buttonSaveAddressKeyboard.isEnabled = false
        self.buttonSaveAddressKeyboard.backgroundColor = UIColor.lightGray
    }
    // MARK: - Selector
}


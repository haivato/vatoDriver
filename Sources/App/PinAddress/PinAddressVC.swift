//  File name   : PinAddressVC.swift
//
//  Author      : vato.
//  Created date: 8/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import GoogleMaps
import VatoNetwork

protocol PinAddressPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBack()
    var defaultPlaceObservable: Observable<AddressProtocol?>  { get }
    var placeDetailObservable: Observable<AddressProtocol?>  { get }
    var isOrigin: Bool { get }
    func lookupAddress(for coordinate: CLLocationCoordinate2D)
    func removeCurrentPlace()
    func didSelectModel()
}

final class PinAddressVC: UIViewController, PinAddressPresentable, PinAddressViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: PinAddressPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.resetNavigation()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    @IBOutlet weak var markerImageView: UIImageView!
    private lazy var disposeBag = DisposeBag()
    @IBOutlet  private weak var mapView: GMSMapView!
    @IBOutlet  private weak var chooseAddressBtn: UIButton!
    @IBOutlet  private weak var currentLocationBtn: UIButton!
    private var titleLabel: UILabel!
}

// MARK: View's event handlers
extension PinAddressVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension PinAddressVC {
}

// MARK: Class's private methods
private extension PinAddressVC {
    private func setupRX() {
        self.currentLocationBtn.rx.tap.bind { [weak self] in
            if let coordinate = VatoLocationManager.shared.location?.coordinate {
                self?.mapView.animate(toLocation: coordinate)
            }
            }.disposed(by: disposeBag)
        
        self.listener?.defaultPlaceObservable.subscribe(onNext: {[weak self] (model) in
            if let model = model {
                self?.mapView.animate(with: GMSCameraUpdate.setTarget(model.coordinate))
                self?.mapView.animate(toZoom: 18.0)
            } else if let coordinate = VatoLocationManager.shared.location?.coordinate {
                    self?.mapView.animate(toLocation: coordinate)
            }
        }).disposed(by: disposeBag)
        
        self.listener?.placeDetailObservable.subscribe(onNext: { [weak self] model in
            if let model = model {
                self?.titleLabel.text = model.subLocality
                self?.chooseAddressBtn.isUserInteractionEnabled = true
                self?.chooseAddressBtn.alpha = 1
            } else {
                self?.titleLabel.text = Text.search.localizedText + "..."
                self?.chooseAddressBtn.isUserInteractionEnabled = false
                self?.chooseAddressBtn.alpha = 0.5
            }
        }).disposed(by: disposeBag)
    }
    
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        if let nightURL = Bundle.main.url(forResource: "custom-map", withExtension: "json"),
            let style = try? GMSMapStyle(contentsOfFileURL: nightURL) {
            mapView.mapStyle = style
        }
        
        mapView.isBuildingsEnabled = false
        mapView.settings.indoorPicker = false
        mapView.settings.rotateGestures = false
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.setMinZoom(1, maxZoom: 20)
        mapView.delegate = self
        
        if let coordinate = VatoLocationManager.shared.location?.coordinate {
            mapView.animate(with: GMSCameraUpdate.setTarget(coordinate))
            mapView.animate(toZoom: 18.0)
        }
        var bottomAreaInsets: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomAreaInsets = window?.safeAreaInsets.bottom ?? 0
        }
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: -bottomAreaInsets, right: 0)
        
        self.chooseAddressBtn.setTitle(Text.confirm.localizedText, for: .normal)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        titleLabel.textColor = UIColor.white
        self.navigationItem.titleView = titleLabel
        
        let markerImage = (self.listener?.isOrigin ?? true) ? UIImage(named: "pick-origin") : UIImage(named: "pick-destination")
        markerImageView.image = markerImage
        
        if self.listener?.isOrigin ?? true {
            chooseAddressBtn.backgroundColor  = Color.darkGreen

        } else {
            chooseAddressBtn.backgroundColor = Color.orange

        }
    }
    
    func resetNavigation() {
        UIApplication.setStatusBar(using: .lightContent)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar?.shadowImage = UIImage()
        
        if #available(iOS 12, *) {
        } else {
            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
                $0.isHidden = true
            })
        }
        
        UIApplication.setStatusBar(using: .lightContent)
        
        self.navigationController?.navigationBar.tintColor = .white
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        
        item.rx.tap.bind { [weak self] in
            self?.listener?.moveBack()
            }.disposed(by: disposeBag)
        
        chooseAddressBtn.rx.tap.bind { [weak self] in
            self?.listener?.didSelectModel()
            }.disposed(by: disposeBag)
    }
}


extension PinAddressVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.listener?.removeCurrentPlace()
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.listener?.lookupAddress(for: position.target)
    }
}

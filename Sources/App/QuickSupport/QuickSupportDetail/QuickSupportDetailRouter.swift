//  File name   : QuickSupportDetailRouter.swift
//
//  Author      : khoi tran
//  Created date: 1/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import AXPhotoViewer

protocol QuickSupportDetailInteractable: Interactable {
    var router: QuickSupportDetailRouting? { get set }
    var listener: QuickSupportDetailListener? { get set }
}

protocol QuickSupportDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class QuickSupportDetailRouter: ViewableRouter<QuickSupportDetailInteractable, QuickSupportDetailViewControllable> {
    /// Class's constructor.
    override init(interactor: QuickSupportDetailInteractable, viewController: QuickSupportDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: QuickSupportDetailRouting's members
extension QuickSupportDetailRouter: QuickSupportDetailRouting {
    func showImages(images: [URL], currentIndex: Int, stackView: UIStackView) {
        let photos = images.compactMap { AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageData: nil, image: nil, url: $0) }
        let startingView = stackView.arrangedSubviews[safe: currentIndex] as? UIImageView
        let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: startingView) { (photo, index) -> UIImageView? in
            return stackView.arrangedSubviews[safe: index] as? UIImageView
        }

        let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: currentIndex)
        let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)
        photosViewController.modalTransitionStyle = .coverVertical
        photosViewController.modalPresentationStyle = .fullScreen
        self.viewController.uiviewController.present(photosViewController, animated: true)
    }
    
}

// MARK: Class's private methods
private extension QuickSupportDetailRouter {
}

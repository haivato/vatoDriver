//
//  AddImageCell.swift
//  FC
//
//  Created by vato. on 1/16/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka
import FwiCoreRX
import FwiCore
import SnapKit

class RequestQuickSupportImageCell: Eureka.Cell<String>, CellType, UITextFieldDelegate, UpdateDisplayProtocol {
    
    private struct Config {
      static let maximumPhoto = 3
    }
    
    var didSelectClear: ((_ indexPath: IndexPath) -> Void)?
    var didSelectAdd: (() -> Void)?
    var didSelectOpen: ((_ indexPath: IndexPath) -> Void)?
    
    var listImage: [ImageRequestModel] = [ImageRequestModel]()
    let lblTitle: UILabel
    var bgRoundView: UIView?
    var collectionView: UICollectionView
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle = UILabel(frame: .zero)
        let tagCellLayout = UICollectionViewFlowLayout()
        tagCellLayout.minimumLineSpacing = 0
        tagCellLayout.minimumInteritemSpacing = 0
        tagCellLayout.scrollDirection = .horizontal
        tagCellLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 13)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagCellLayout)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
        collectionView.register(AddImageCell.nib, forCellWithReuseIdentifier: "AddImageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        lblTitle >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.numberOfLines = 2
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.right.equalTo(-10)
            })
        }
        
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(60)
                make.bottom.equalTo(-4)
            })
        }
        
        let viewLine: UIView = UIView(frame: .zero)
        viewLine.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        
        viewLine >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.left.equalToSuperview().inset(16)
                make.height.equalTo(1)
            }
        }
    }
    
    func reloadData(_images: [UIImage]) {
        var images = _images.compactMap{ ImageRequestModel(image: $0, type: .image) }
        
        if images.count < Config.maximumPhoto {
            images.append(ImageRequestModel(image: nil, type: .addNew))
        }
        self.listImage = images
        self.collectionView.reloadData()
    }
    
    func update(title: String?) {
        lblTitle.text = title
    }
    
    func setupRX() { }

    func setupDisplay(item: String?) {}
}


extension RequestQuickSupportImageCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCell", for: indexPath) as? AddImageCell else {
            fatalError("Error")
        }
        let model = self.listImage[indexPath.row]
        if model.type == .addNew {
            cell.imageView.image = UIImage(named: "iconPhotoUpload")
            cell.buttonClear.isHidden = true
        } else {
            cell.imageView.image = model.image
            cell.buttonClear.isHidden = false
        }
        cell.didSelectClear = { [weak self] (sender) in
            self?.didSelectClear?(indexPath)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.listImage[safe: indexPath.row] else { return }
        
        if model.type == .addNew {
            self.didSelectAdd?()
        } else {
            self.didSelectOpen?(indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:60, height: 60)
    }
}

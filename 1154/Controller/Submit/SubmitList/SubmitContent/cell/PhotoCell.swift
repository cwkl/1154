//
//  photoCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 9..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


protocol PhotoCellDelegate{
    func showImageDetail(imageDetailView : UIViewController)
}

class PhotoCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var imageUrl: [String]?

    var photoCellDelegate : PhotoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoCollectionView.register(UINib(nibName: "photoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCollectionViewCell")
        
        photoCollectionView.flashScrollIndicators()
        photoCollectionView.showsHorizontalScrollIndicator = true
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        self.selectionStyle = .none
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrl?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        guard let imageUrl = imageUrl else{return cell}
        cell.cellImageView.kf.setImage(with: URL(string: imageUrl[indexPath.row]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoZoomViewController") as? PhotoZoomViewController{
            view.indexPath = indexPath
            view.imageUrl = imageUrl
            photoCellDelegate?.showImageDetail(imageDetailView: view)
        }
    }
}

//
//  PhotoZoomCollectionViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 16..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol PhotoZoomDelegate {
    func viewHideEvent()
}

class PhotoZoomCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var photoZoomDelegate: PhotoZoomDelegate?
    
    
    override func awakeFromNib() {
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTap(_:))))
        imageView.isUserInteractionEnabled = true
        
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
    }
    
    @objc func imageViewTap(_ sender: UITapGestureRecognizer){
        photoZoomDelegate?.viewHideEvent()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

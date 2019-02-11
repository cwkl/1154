//
//  PhotoZoomViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoZoomViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoZoomDelegate {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var statusView: UIView!
    
    
    var imageUrl: [String]?
    var indexPath: IndexPath?
    var statusBarHidden = false
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrl?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoZoomCollectionViewCell", for: indexPath) as! PhotoZoomCollectionViewCell
        guard let imageUrl = imageUrl else{return cell}
        cell.imageView.kf.setImage(with: URL(string: imageUrl[indexPath.row]))
        cell.photoZoomDelegate = self

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCollectionView.frame.width, height: imageCollectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let imageUrl = imageUrl else{return}
        let indexPath = IndexPath(item: Int(targetContentOffset.pointee.x / view.frame.width), section: 0)
        countLabel.text = "\(indexPath.row + 1) / \(imageUrl.count)"
        countLabel.textColor = UIColor.white
    }
    
    func viewHideEvent(){
        if navigationBar.isHidden {
            navigationBar.isHidden = false
            statusBarHidden = false
            self.setNeedsStatusBarAppearanceUpdate()
        }else{
            navigationBar.isHidden = true
            statusBarHidden = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return statusBarHidden
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    

    override func viewDidAppear(_ animated: Bool) {
        guard let indexPath = indexPath else {return}
        imageCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        UIView.animate(withDuration: 0.0, delay: 0.001, animations: {
            self.imageCollectionView.alpha = 1.0
        }, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.alpha = 0.0
        imageCollectionView.contentInsetAdjustmentBehavior = .never
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        guard let imageUrl = imageUrl, let indexPath = indexPath else {return}
        countLabel.text = "\(indexPath.row + 1) / \(imageUrl.count)"
        countLabel.textColor = UIColor.white
    }
    
    @IBAction func backEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

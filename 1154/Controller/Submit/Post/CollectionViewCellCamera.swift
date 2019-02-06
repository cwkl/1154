//
//  CollectionViewCellCamera.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 17..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class CollectionViewCellCamera: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkedBackground: UIView!
    @IBOutlet weak var checkedImage: UIImageView!
    
    var indexPath: IndexPath?

    override var isSelected: Bool{
        didSet{
            if indexPath?.row != 0{
                if isSelected {
                    checkedBackground.isHidden = false
                    checkedImage.isHidden = false
                } else {
                    checkedBackground.isHidden = true
                    checkedImage.isHidden = true
                }
            }
        }
    }
    
    override func awakeFromNib() {
        imageView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 5
        checkedBackground.layer.cornerRadius = 5
    }
}

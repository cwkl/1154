//
//  CollectionViewCellPhoto.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 19..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class CollectionViewCellPhoto: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
    }
    
}

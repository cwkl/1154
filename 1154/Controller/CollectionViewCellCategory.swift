//
//  CollectionViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 3..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol CollectionViewCellCategoryDelegate {
    func tapCell(indexPath: IndexPath)
}

class CollectionViewCellCategory: UICollectionViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    
    var tapGesture = UITapGestureRecognizer()
    var indexPath: IndexPath? {
        didSet {
            if indexPath?.item == 0 {
                cellLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.9) /* #134563 */
            } else {
                cellLabel.textColor = .lightGray
            }
        }
    }
    
    var delegate: CollectionViewCellCategoryDelegate?
    
    override func awakeFromNib() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        tapGesture.isEnabled = true
        cellLabel.isUserInteractionEnabled = true
        cellLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapCell() {
        guard let indexPath = self.indexPath else { return }
        
        self.delegate?.tapCell(indexPath: indexPath)
    }
}





    


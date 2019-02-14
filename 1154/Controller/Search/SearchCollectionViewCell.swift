//
//  SearchCollectionViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 14..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol SearchCollectionViewCellDelegate {
    func tapCell(indexPath: IndexPath)
}

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var tapGesture = UITapGestureRecognizer()
    var indexPath: IndexPath? {
        didSet {
            if indexPath?.item == 0 {
                categoryLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.9) /* #134563 */
            } else {
                categoryLabel.textColor = .lightGray
            }
        }
    }
    
    var delegate: SearchCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        tapGesture.isEnabled = true
        mainView.isUserInteractionEnabled = true
        mainView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapCell() {
        guard let indexPath = self.indexPath else { return }
        
        self.delegate?.tapCell(indexPath: indexPath)
    }
}

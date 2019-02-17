//
//  ListCollectionViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 7..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol ListCollectionViewCellDelegate {
    func tapCell(indexPath: IndexPath)
}

class ListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
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
    
    var delegate: ListCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        tapGesture.isEnabled = true
        mainView.isUserInteractionEnabled = true
        mainView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapCell() {
        guard let indexPath = self.indexPath else { return }
        if cellLabel.textColor == .lightGray{
            self.delegate?.tapCell(indexPath: indexPath)
        }
    }
    
}

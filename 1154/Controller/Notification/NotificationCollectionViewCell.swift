//
//  NotificationCollectionViewCell.swift
//  
//
//  Created by Junhyeok Kwon on 2019. 2. 16..
//

import UIKit

protocol NotificationCollectionViewCellDelegate {
    func tapCell(indexPath: IndexPath)
}

class NotificationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    
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
    
    var delegate: NotificationCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        configureViewOption()
        addGestrue()
    }
    
    func configureViewOption(){
        badgeView.layer.cornerRadius = badgeView.frame.height / 2
    }
    
    func addGestrue(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        tapGesture.isEnabled = true
        mainView.isUserInteractionEnabled = true
        mainView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapCell() {
        guard let indexPath = self.indexPath else { return }
        if categoryLabel.textColor == .lightGray{
            self.delegate?.tapCell(indexPath: indexPath)
        }
    }
    
}

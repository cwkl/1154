//
//  UserTableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func tapCell(submitId: String)
    func activityIndicatorStop()
}

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var userTableViewCellDelegate: UserTableViewCellDelegate?
    var submitId: String?
    var userId: String?{
        didSet{
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViewOption()
        addGesture()
    }
    
    func configureViewOption(){
        mainView.layer.cornerRadius = 5
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }
    
    func addGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent))
        mainView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapEvent(){
        guard let submitId = self.submitId else {return}
        userTableViewCellDelegate?.tapCell(submitId: submitId)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

//
//  UserTableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func tapCell(submitModel: SubmitModel)
    func activityIndicatorStop()
}

class UserTableViewCell: UITableViewCell {
    
    var userTableViewCellDelegate: UserTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

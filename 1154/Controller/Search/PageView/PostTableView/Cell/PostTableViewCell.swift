//
//  PostTableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol PostTableViewCellDelegate {
    func tapCell(submitModel: SubmitModel)
    func activityIndicatorStop()
}

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    var postTableViewCellDelegate: PostTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

//
//  PostCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 6..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation

class PostCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var viewsCountLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        mainView.layer.cornerRadius = 5
        self.selectionStyle = .none
    }
}

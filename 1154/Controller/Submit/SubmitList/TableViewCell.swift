//
//  TableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 10..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
    @IBOutlet weak var cellLayout: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellLayout.layer.cornerRadius = 5
        cellLayout.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}

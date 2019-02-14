//
//  SearchTableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 14..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

protocol SearchTableViewCellDelegate {
    func tapCell(submitModel: SubmitModel)
    func activityIndicatorStop()
}

class SearchTableViewCell: UITableViewCell {
    
    var searchTableViewCellDelegate: SearchTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

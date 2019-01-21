//
//  contentCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 9..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation
import UIKit

class ContentCell: UITableViewCell {
    @IBOutlet weak var contentTextView: UITextView!
    
    override func awakeFromNib() {
        contentTextView.font = UIFont.systemFont(ofSize: 17)
    }
    
}

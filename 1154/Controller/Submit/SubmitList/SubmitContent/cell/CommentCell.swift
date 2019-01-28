//
//  commentCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 9..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol CommentCellDelegate {
    func showDeleteAlert(submitId: String, commentId: String)
}

class CommentCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeTextLabel: UILabel!
    @IBOutlet weak var replyButton: UILabel!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet weak var deleteButton: UILabel!
    var submitId: String?
    var commentId: String?
    var commentCellDelegate: CommentCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        deleteButton.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteEvent(_:)))
        deleteButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func deleteEvent(_ sender: UITapGestureRecognizer) {
        guard let submitId = self.submitId, let commentId = self.commentId else {return}
        commentCellDelegate?.showDeleteAlert(submitId: submitId, commentId: commentId)
    }
}

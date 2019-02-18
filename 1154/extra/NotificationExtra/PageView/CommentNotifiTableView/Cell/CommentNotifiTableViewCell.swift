////
////  CommentNotifiTableViewCell.swift
////  1154
////
////  Created by Junhyeok Kwon on 2019. 2. 16..
////  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
////
//
//import UIKit
//
//protocol CommentNotifiTableViewCellDelegate {
//    func tapCell(submitId: String)
//    func activityIndicatorStop()
//}
//
//class CommentNotifiTableViewCell: UITableViewCell {
//    @IBOutlet weak var mainView: UIView!
//
//
//    var commentNotifiTableViewCellDelegate: CommentNotifiTableViewCellDelegate?
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        configureViewOption()
//    }
//
//    func configureViewOption(){
//        mainView.layer.cornerRadius = 5
//    }
//
//    func addGesture(){
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent))
//        mainView.addGestureRecognizer(tapGesture)
//    }
//
//    @objc func tapEvent(){
//        commentNotifiTableViewCellDelegate?.tapCell(submitId: "")
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//
//}

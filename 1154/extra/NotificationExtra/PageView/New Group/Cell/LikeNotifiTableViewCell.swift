////
////  LIkeNotifiTableViewCell.swift
////  1154
////
////  Created by Junhyeok Kwon on 2019. 2. 16..
////  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
////
//
//import UIKit
//
//protocol LikeNotifiTableViewCellDelegate {
//    func tapCell(submitId: String)
//    func activityIndicatorStop()
//}
//
//class LikeNotifiTableViewCell: UITableViewCell {
//    
//    @IBOutlet weak var mainView: UIView!
//    
//    
//    var likeNotifiTableViewCellDelegate: LikeNotifiTableViewCellDelegate?
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        configureViewOption()
//    }
//    
//    func configureViewOption(){
//      mainView.layer.cornerRadius = 5
//    }
//    
//    func addGesture(){
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent))
//        mainView.addGestureRecognizer(tapGesture)
//    }
//    
//    @objc func tapEvent(){
//        likeNotifiTableViewCellDelegate?.tapCell(submitId: "")
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//
//}

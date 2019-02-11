//
//  cell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 9..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import CodableFirebase

protocol TitleCellDelegate {
    func presentSubmitUserProfile()
}

class TitleCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likebutton: UIButton!
    @IBOutlet weak var likeButtonView: UIView!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    var isJudge = false
    var uid: String?
    var titleCellDelegate: TitleCellDelegate?
    var likeArray: [IdDateModel] = []
    var isLike: Bool?
    var presentIsBookmark: Bool?{
        didSet{
            guard let presentIsBookmark = self.presentIsBookmark else {return}
            if presentIsBookmark{
                self.bookmarkButton.setImage(UIImage(named: "fillbookmark"), for: UIControl.State.normal)
            }
        }
    }
    var isBookmark: Bool?{
        didSet{
            guard let isBookmark = self.isBookmark else {return}
            DispatchQueue.main.async {
                if isBookmark{
                    self.bookmarkButton.setImage(UIImage(named: "fillbookmark"), for: UIControl.State.normal)
                }else{
                    self.bookmarkButton.setImage(UIImage(named: "bookmark"), for: UIControl.State.normal)
                }
            }
        }
    }
    var submitId: String? {
        didSet{
            if !isJudge{
                judgeIsBookmark()
                judgeIsLike()
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViewOption()
        addGesture()
    }
    
    func addGesture(){
        let profileImageGesture = UITapGestureRecognizer(target: self, action: #selector(presentSubmitUserProfile))
        let nameGesture = UITapGestureRecognizer(target: self, action: #selector(presentSubmitUserProfile))
        profileImageView.addGestureRecognizer(profileImageGesture)
        nameLabel.addGestureRecognizer(nameGesture)
    }
    
    @objc func presentSubmitUserProfile(){
        titleCellDelegate?.presentSubmitUserProfile()
    }
    
    func configureViewOption(){
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        self.selectionStyle = .none
    }
    
    func judgeIsBookmark(){
        DispatchQueue.global().async {
            guard let uid = self.uid, let id = self.submitId else {return}
            Firestore.firestore().collection("users").document(uid).collection("bookmark").document(id).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    if let snapshot = snapshot?.data(){
                        self.isBookmark = true
                    }else{
                        self.isBookmark = false
                        
                    }
                }
            })
        }
    }
    
    func judgeIsLike(){
        DispatchQueue.global().async {
            guard let uid = self.uid, let id = self.submitId else {return}
            Firestore.firestore().collection("submit").document(id).collection("like").getDocuments { (snapshot, error) in
                if error != nil{
                    print("error")
                }else{
                    guard let snapshot = snapshot else {return}
                    if snapshot.isEmpty{
                        self.isLike = false
                    }else{
                        for  document in snapshot.documents{
                            let likeModel = try? FirebaseDecoder().decode(IdDateModel.self, from: document.data())
                            guard let model = likeModel else {return}
                            self.likeArray.append(model)
                        }
                        self.isLike = false
                        for (index, _) in self.likeArray.enumerated(){
                            if self.likeArray[index].id == uid{
                                self.isLike = true
                            }
                            DispatchQueue.main.async {
                                if index + 1 == self.likeArray.count{
                                    self.isJudge = true
                                    guard let isLike = self.isLike else {return}
                                    if isLike{
                                        self.likebutton.setImage(UIImage(named: "fillheart"), for: UIControl.State.normal)
                                    }else{
                                        self.likebutton.setImage(UIImage(named: "heart2"), for: UIControl.State.normal)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func likeButtonEvent(_ sender: Any) {
        DispatchQueue.global().async {
            guard let isLike = self.isLike, let uid = self.uid, let id = self.submitId else {return}
            if isLike{
                DispatchQueue.main.async {
                    self.likebutton.setImage(UIImage(named: "heart2"), for: UIControl.State.normal)
                    self.isLike = false
                }
                Firestore.firestore().collection("submit").document(id).collection("like").document(uid).delete()
                Firestore.firestore().collection("users").document(uid).collection("like").document(id).delete()
            }else{
                DispatchQueue.main.async {
                    self.likebutton.setImage(UIImage(named: "fillheart"), for: UIControl.State.normal)
                    self.isLike = true
                }
                let likeModel = IdDateModel(id: uid, date: SharedFunction.shared.getToday())
                let data = try? FirestoreEncoder().encode(likeModel)
                guard let likeData = data else {return}
                Firestore.firestore().collection("submit").document(id).collection("like").document(uid).setData(likeData)
                Firestore.firestore().collection("users").document(uid).collection("like").document(id).setData(["submitId" : id, "date" : SharedFunction.shared.getToday()])
            }
        }
    }
    
    @IBAction func bookmarkButtonEvent(_ sender: Any) {
        DispatchQueue.global().async {
            guard let uid = self.uid, let submitId = self.submitId, let isBookmark = self.isBookmark else {return}
            if isBookmark{
                Firestore.firestore().collection("users").document(uid).collection("bookmark").document(submitId).delete()
                self.isBookmark = false
            }else{
                Firestore.firestore().collection("users").document(uid).collection("bookmark").document(submitId).setData(["submitId" : submitId, "date" : SharedFunction.shared.getToday()])
                self.isBookmark = true
            }
        }
    }
}



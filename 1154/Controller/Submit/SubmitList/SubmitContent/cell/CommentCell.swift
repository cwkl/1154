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
import CodableFirebase

protocol CommentCellDelegate {
    func showDeleteAlert(submitId: String, commentId: String)
    func showReplyingBar(name: String, uid: String, commentId: String)
    func setIsLike(isLike: Bool, indexPath: Int)
}

class CommentCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIImageView!
    @IBOutlet weak var likeButtonView: UIView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeTextLabel: UILabel!
    @IBOutlet weak var replyButtonView: UIView!
    @IBOutlet weak var deleteButtonView: UIView!
    
    private var isLike: Bool?
    private var isJudge = false
    private var likeArray: [LikeModel] = []
    var commentCellDelegate: CommentCellDelegate?
    var submitId: String?
    var uid: String?
    var name: String?
    var indexPath: Int?
    var parentIsSubComment: Bool?
    var parentId: String?
    var isLiked: Bool?{
        didSet{
            guard let isLiked = isLiked else {return}
            if isLiked{
                self.likeButton.image = UIImage(named: "fillheart")
            }else{
                self.likeButton.image = UIImage(named: "heart2")
            }
        }
    }
    var commentId: String?{
        didSet{
            if !isJudge{
                judgeLike()
            }
            commentLikeObserver()
        }
    }
    
    var listener: ListenerRegistration?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        deleteButtonView.isUserInteractionEnabled = true
        let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(deleteEvent(_:)))
        deleteButtonView.addGestureRecognizer(deleteGesture)
        likeButtonView.isUserInteractionEnabled = true
        let likeGesture = UITapGestureRecognizer(target: self, action: #selector(likeButtonEvent(_:)))
        likeButtonView.addGestureRecognizer(likeGesture)
        replyButtonView.isUserInteractionEnabled = true
        let replyGesture = UITapGestureRecognizer(target: self, action: #selector(replyButtonEvent(_:)))
        replyButtonView.addGestureRecognizer(replyGesture)
    }
    
    func judgeLike(){
        DispatchQueue.global().async {
            guard let submitId = self.submitId, let uid = self.uid, let commentId = self.commentId else {return}
            Firestore.firestore().collection("submit").document(submitId).collection("comment").document(commentId).collection("like").getDocuments(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot else {return}
                    if snapshot.isEmpty{
                        self.isLike = false
                    }else{
                        for document in snapshot.documents{
                            let likeModel = try? FirebaseDecoder().decode(LikeModel.self, from: document.data())
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
                                        self.likeButton.image = UIImage(named: "fillheart")
                                    }else{
                                        self.likeButton.image = UIImage(named: "heart2")
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func commentLikeObserver(){
        DispatchQueue.global().async {
            guard let submitId = self.submitId, let commentId = self.commentId, let uid = self.uid, let indexPath = self.indexPath else {return}
            self.listener = Firestore.firestore().collection("submit").document(submitId).collection("comment").document(commentId).collection("like").addSnapshotListener({ (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot else {return}
                    var likeArray: [LikeModel] = []
                    var isLike = false
                    for document in snapshot.documents{
                        guard let likeModel = try? FirebaseDecoder().decode(LikeModel.self, from: document.data()) else {return}
                        if likeModel.id == uid{
                            isLike = true
                            
                        }
                        likeArray.append(likeModel)
                    }
                    if isLike{
                        self.likeButton.image = UIImage(named: "fillheart")
                        self.commentCellDelegate?.setIsLike(isLike: isLike, indexPath: indexPath)
                    }else{
                        self.likeButton.image = UIImage(named: "heart2")
                        self.commentCellDelegate?.setIsLike(isLike: isLike, indexPath: indexPath)
                    }
                    let likeCount = likeArray.count
                    self.likeCountLabel.text = "\(likeArray.count)"
                    if 1 < likeCount{
                        self.likeTextLabel.text = "likes"
                    }else{
                        self.likeTextLabel.text = "like"
                    }
                    Firestore.firestore().collection("submit").document(submitId).collection("comment").document(commentId).updateData(["commentLikeCount" : likeCount], completion: { (error) in
                        if error != nil{
                        }else{
                            
                        }
                    })
                }
            })
        }
    }
    
    @objc func deleteEvent(_ sender: UITapGestureRecognizer) {
        guard let submitId = self.submitId, let commentId = self.commentId else {return}
        commentCellDelegate?.showDeleteAlert(submitId: submitId, commentId: commentId)
    }
    
    @objc func likeButtonEvent(_ sender: UITapGestureRecognizer) {
        DispatchQueue.global().async {
            guard let submitId = self.submitId,
                let uid = self.uid,
                let commentId = self.commentId,
                let isLike = self.isLike else {return}
            if isLike{
                DispatchQueue.main.async {
                    self.likeButton.image = UIImage(named: "heart2")
                    self.isLike = false
                }
                Firestore.firestore().collection("submit").document(submitId).collection("comment").document(commentId).collection("like").document(uid).delete { (error) in
                    if error != nil{
                    }else{
                        
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.likeButton.image = UIImage(named: "fillheart")
                    self.isLike = true
                }
                let likeModel = LikeModel(id: uid, date: SharedFunction.shared.getToday())
                guard let data = try? FirestoreEncoder().encode(likeModel) else {return}
                Firestore.firestore().collection("submit").document(submitId).collection("comment").document(commentId).collection("like").document(uid).setData(data) { (error) in
                    if error != nil{
                    }else{
                        
                    }
                }
            }
        }
    }
    
    @objc func replyButtonEvent(_ sender: UITapGestureRecognizer){
        guard let name = self.name ,
            let uid = self.uid,
            let commentId = self.commentId,
            let parentIsSubComment = self.parentIsSubComment,
            let parentId = self.parentId else {return}
        if parentIsSubComment{
            commentCellDelegate?.showReplyingBar(name: name, uid: uid, commentId: parentId)
        }else{
            commentCellDelegate?.showReplyingBar(name: name, uid: uid, commentId: commentId)
        }
    }
}

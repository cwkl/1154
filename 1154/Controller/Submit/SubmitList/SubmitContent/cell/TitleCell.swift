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

class TitleCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likebutton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    var uid: String?
    var submitId: String?
    var likeArray: [LikeModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        self.selectionStyle = .none
        
        
    }
    
    func setLike(){
        DispatchQueue.global().async {
            guard let uid = self.uid, let id = self.submitId else {return}
            let likeModel = LikeModel(id: uid, date: SharedFunction.shared.getToday())
            let data = try? FirestoreEncoder().encode(likeModel)
            guard let likeData = data else {return}
            Firestore.firestore().collection("submit").document(id).collection("likes").document(uid).setData(likeData) { (error) in
                if error != nil{
                }else{
                    self.likebutton.setImage(UIImage(named: "fillheart"), for: UIControl.State.normal)
                    print("like")
                }
            }
        }
    }
    
    @IBAction func likeButtonEvent(_ sender: Any) {
        guard let uid = self.uid, let id = submitId else {return}
        DispatchQueue.global().async {
            Firestore.firestore().collection("submit").document(id).collection("likes").getDocuments { (snapshot, error) in
                if error != nil{
                    print("error")
                }else{
                    guard let snapshot = snapshot else {return}
                    if snapshot.isEmpty{
                        self.setLike()
                    }else{
                        for  document in snapshot.documents{
                            print("aaaaa")
                            let likeModel = try? FirebaseDecoder().decode(LikeModel.self, from: document.data())
                            guard let model = likeModel else {return}
                            self.likeArray.append(model)
                        }
                        var isLike = false
                        for (index, _) in self.likeArray.enumerated(){
                            if self.likeArray[index].id == uid{
                                isLike = true
                            }
                            DispatchQueue.main.async {
                                if index + 1 == self.likeArray.count{
                                    if isLike{
                                        Firestore.firestore().collection("submit").document(id).collection("likes").document(uid).delete(completion: { (error) in
                                            if error != nil{
                                                
                                            }else{
                                                self.likebutton.setImage(UIImage(named: "heart2"), for: UIControl.State.normal)
                                                print("delete success")
                                            }
                                        })
                                    }else{
                                        self.setLike()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}



//
//  TableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 10..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

class TableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
    @IBOutlet weak var cellLayout: UIView!
    
    var submitUid: String?{
        didSet{
            submitUserDataLoad()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellLayout.layer.cornerRadius = 5
        cellLayout.backgroundColor = UIColor.white
        userImage.contentMode = .scaleAspectFill
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.layer.masksToBounds = true
        
    }
    
    func submitUserDataLoad(){
        if let uid = submitUid{
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.data(),
                        let userModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot) else {return}
                    self.userName.text = userModel.name
                    if let imageUrl = userModel.profileImageUrl{
                        self.userImage.kf.setImage(with: URL(string: imageUrl))
                    }else{
                        self.userImage.image = UIImage(named: "defaultprofile")
                    }
                    
                }
            }
    
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

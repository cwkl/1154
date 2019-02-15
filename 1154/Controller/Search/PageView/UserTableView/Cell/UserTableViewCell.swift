//
//  UserTableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

protocol UserTableViewCellDelegate {
    func tapCell(userModel: UserModel)
    func activityIndicatorStop()
}

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var userModel: UserModel?
    var userTableViewCellDelegate: UserTableViewCellDelegate?
    var userId: String?{
        didSet{
            if let userId = self.userId{
                userDataLoad(id: userId)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViewOption()
        addGesture()
    }
    
    func configureViewOption(){
        mainView.layer.cornerRadius = 5
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }
    
    func addGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent))
        mainView.addGestureRecognizer(tapGesture)
    }
    
    func userDataLoad(id: String){
        DispatchQueue.global().async {
            Firestore.firestore().collection("users").document(id).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.data(),
                        let data = try? FirestoreDecoder().decode(UserModel.self, from: snapshot)
                        else {return}
                        self.userModel = data
                    DispatchQueue.main.async {
                        self.nameLabel.text = data.name
                        if data.profileImageUrl != nil{
                            guard let url = data.profileImageUrl else {return}
                            self.profileImageView.kf.setImage(with: URL(string: url)) { result in
                                switch result {
                                case .success( _):
                                    self.userTableViewCellDelegate?.activityIndicatorStop()
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }else{
                            self.profileImageView.image = UIImage(named: "defaultprofile")
                            self.userTableViewCellDelegate?.activityIndicatorStop()
                        }
                    }
                }
            })
        }
    }
    
    @objc func tapEvent(){
        guard let userModel = self.userModel else {return}
        userTableViewCellDelegate?.tapCell(userModel: userModel)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

//
//  ListTableViewCell.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 7..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

protocol ListTableViewCellDelegate {
    func tapCell(submitModel: SubmitModel)
    func activityIndicatorStop()
}

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    private var submitModel: SubmitModel?
    var listTableViewCellDelegate: ListTableViewCellDelegate?
    
    var submitId: String?{
        didSet{
            loadSubmitData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViewOption()
        addGesture()
    }
    
    func configureViewOption(){
        mainView.layer.cornerRadius = 5
        mainView.backgroundColor = UIColor.white
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }
    
    func addGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent))
        mainView.addGestureRecognizer(tapGesture)
        mainView.isUserInteractionEnabled = true
    }
    
    @objc func tapEvent(){
        if let submitModel = self.submitModel{
            listTableViewCellDelegate?.tapCell(submitModel: submitModel)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func loadSubmitData(){
        DispatchQueue.global().async {
            guard let submitId = self.submitId else {return}
            Firestore.firestore().collection("submit").document(submitId).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.data(), let model = try? FirestoreDecoder().decode(SubmitModel.self, from: snapshot) else {return}
                    
                    self.loadUserData(model: model)
                    self.submitModel = model
                    
                    DispatchQueue.main.async {
                        self.titleLabel.text = model.title
                        self.commentCountLabel.text = "\(model.commentCount)"
                        self.likeCountLabel.text = "\(model.likeCount)"
                        self.viewsCountLabel.text = "\(model.viewsCount)"
                        self.dateLabel.text = SharedFunction.shared.getCurrentLocaleDateFromString(string: model.date, format: "yyyy. MM. dd")
                    }
                }
            })
        }
    }
    
    func loadUserData(model: SubmitModel){
        DispatchQueue.global().async {
            Firestore.firestore().collection("users").document(model.uid).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.data(), let model = try? FirestoreDecoder().decode(UserModel.self, from: snapshot) else {return}
                    
                    DispatchQueue.main.async {
                        self.nameLabel.text = model.name
                        if let imageUrl = model.profileImageUrl{
                            self.profileImageView.kf.setImage(with: URL(string: imageUrl))
                            self.listTableViewCellDelegate?.activityIndicatorStop()
                        }else{
                            self.profileImageView.image = UIImage(named: "defaultprofile")
                            self.listTableViewCellDelegate?.activityIndicatorStop()
                        }
                    }
                }
            })
        }
    }
}

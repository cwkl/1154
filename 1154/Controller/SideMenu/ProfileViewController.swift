//
//  ProfileViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 5..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var editButtonView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var postlikesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var registeredLabel: UILabel!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var regionView: UIView!
    
    private var submitModel: [SubmitModel] = []
    private var postCount: Int?
    var userModel: UserModel?{
        didSet{
            loadCountData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewOption()
        addGesture()
        setUserData()
        checkSelfProfile()
    }
    
    func checkSelfProfile(){
        guard let uid = Auth.auth().currentUser?.uid, let modelUid = userModel?.uid else {return}
        if  modelUid == uid{
            self.editButtonView.isHidden = false
        }else{
            self.editButtonView.isHidden = true
        }
    }
    
    func loadCountData(){
        DispatchQueue.global().async {
            var likesCount = 0
            guard let userModel = self.userModel else {return}
            Firestore.firestore().collection("submit").whereField("uid", isEqualTo: userModel.uid).getDocuments { (snapshot, error) in
                if error != nil{
                }else{
                    guard let postCount = snapshot?.count, let snapshot = snapshot?.documents else {return}
                    self.postCount = postCount
                    self.postsCountLabel.text = "\(postCount)"
                    if postCount == 0{
                        self.postlikesLabel.text = "0"
                    }else{
                        for (index, document) in snapshot.enumerated(){
                            do{
                                guard let submitModel = try? FirebaseDecoder().decode(SubmitModel.self, from: document.data()) else {return}
                                self.submitModel.append(submitModel)
                                likesCount += submitModel.likeCount
                                
                                if index + 1 == postCount{
                                    DispatchQueue.main.async {
                                        self.postlikesLabel.text = "\(likesCount)"
                                        self.postTableView.delegate = self
                                        self.postTableView.dataSource = self
                                        self.postTableView.reloadData()
                                    }
                                }
                            }catch let error{
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            
            Firestore.firestore().collection("totalCommentCount").whereField("uid", isEqualTo: userModel.uid).getDocuments(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let commentCount = snapshot?.count else {return}
                    self.commentsCountLabel.text = "\(commentCount)"
                    
                }
            })
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let postCount = self.postCount else {return 0}
        return postCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = postTableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostCell{
            cell.titleLabel.text = submitModel[indexPath.row].title
            cell.commentCountLabel.text = "\(submitModel[indexPath.row].commentCount)"
            cell.likeCountLabel.text = "\(submitModel[indexPath.row].likeCount)"
            cell.viewsCountLable.text = "\(submitModel[indexPath.row].viewsCount)"
            cell.dateLabel.text = SharedFunction.shared.getCurrentLocaleDateFromString(string: submitModel[indexPath.row].date, format: "yyyy. MM. dd")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SubmitContentViewController") as? SubmitContentViewController{
            view.model = submitModel[indexPath.row]
            self.present(view, animated: true, completion: nil)
        }
    }
    
    func configureViewOption(){
        editButtonView.layer.cornerRadius = 5
        editButtonView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        editButtonView.layer.borderWidth = 1
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        
        postTableView.register(UINib(nibName: "postCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        
    }
    
    func addGesture(){
        let editGesture = UITapGestureRecognizer(target: self, action: #selector(editButtonEvent))
        editButtonView.addGestureRecognizer(editGesture)
    }
    
    @objc func editButtonEvent(){
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController{
            view.userModel = self.userModel
            self.present(view, animated: true, completion: nil)
        }
    }
    @IBAction func backButtonEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUserData(){
        if let userModel = self.userModel{
            if userModel.profileImageUrl != nil{
                guard let imageUrl = userModel.profileImageUrl else {return}
                profileImageView.kf.setImage(with: URL(string: imageUrl))
            }else{
                profileImageView.image = UIImage(named: "defaultprofile")
            }
            
            nameLabel.text = userModel.name
            
            if userModel.region == "Korea"{
                regionLabel.text = userModel.region
            }else if userModel.region == "Japan"{
                regionLabel.text = userModel.region
            }else{
                regionView.isHidden = true
            }
            
            registeredLabel.text = SharedFunction.shared.getCurrentLocaleDateFromString(string: userModel.startDate, format: "yyyy. MM. dd")
        }
    }
}
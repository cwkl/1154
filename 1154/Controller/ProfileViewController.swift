//
//  ProfileViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 5..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
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
    
    var userModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewOption()
        addGesture()
        setUserData()
    }
    
    func configureViewOption(){
        editButtonView.layer.cornerRadius = 5
        editButtonView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        editButtonView.layer.borderWidth = 1
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
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
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuController"){
            self.present(view , animated: true, completion: nil)
        }
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

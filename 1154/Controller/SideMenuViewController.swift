//
//  ProfileViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 2..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//


import UIKit
import SideMenuSwift
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class SideMenuViewController: UIViewController {
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var signoutView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var mainViewLeading: NSLayoutConstraint!
    
    private var userModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewOption()
        buttonGestureAdd()
        loadUserData()
    }
    
    func loadUserData(){
        DispatchQueue.global().async {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil{
                }else{
                    do{
                        guard let snapshot = snapshot?.data(),
                            let userModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot) else {return}
                        self.userModel = userModel
                        if userModel.profileImageUrl != nil{
                            guard let imageUrl = userModel.profileImageUrl else {return}
                            self.profileImageView.kf.setImage(with: URL(string: imageUrl))
                        }else{
                            self.profileImageView.image = UIImage(named: "defaultprofile")
                        }
                        self.nameLabel.text = userModel.name
                        self.accountLabel.text = userModel.email
                        
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func configureViewOption(){
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        mainViewLeading.constant = +(UIScreen.main.bounds.width - (((UIScreen.main.bounds.width / 3) * 2) + 20))
    }
    
    func buttonGestureAdd(){
        let profileImageGesture = UITapGestureRecognizer(target: self, action: #selector(profileTouchEvent))
        profileImageView.addGestureRecognizer(profileImageGesture)
        profileImageView.isUserInteractionEnabled = true
        
        let nameGesture = UITapGestureRecognizer(target: self, action: #selector(profileTouchEvent))
        nameLabel.addGestureRecognizer(nameGesture)
        nameLabel.isUserInteractionEnabled = true
        
        let accountGesture = UITapGestureRecognizer(target: self, action: #selector(profileTouchEvent))
        accountLabel.addGestureRecognizer(accountGesture)
        accountLabel.isUserInteractionEnabled = true
        
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(profileTouchEvent))
        profileView.addGestureRecognizer(profileGesture)
        
        let listGesture = UITapGestureRecognizer(target: self, action: #selector(listTouchEvent))
        listView.addGestureRecognizer(listGesture)
        
        let signoutGesture = UITapGestureRecognizer(target: self, action: #selector(signoutTouchEvent))
        signoutView.addGestureRecognizer(signoutGesture)
    }
    
    @objc func profileTouchEvent(){
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController{
            view.userModel = self.userModel
            self.present(view, animated: true, completion: nil)
        }
    }

    @objc func listTouchEvent(){
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController"){
            self.present(view, animated: true, completion: nil)
        }
    }
    
    @objc func signoutTouchEvent(){
        try! Auth.auth().signOut()
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController"){
            self.present(view, animated: true, completion: nil)
        }
    }
}

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
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var loginView: UIView!
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
        NotificationManager.receive(sideUserReload: self, selector: #selector(sideUserLoadNotification))
        NotificationManager.receive(sideUserReload: self, selector: #selector(sideUserLoadNotification))
    }
    
    @objc func sideUserLoadNotification(){
        loadUserData()
    }
    
    func loadUserData(){
        DispatchQueue.global().async {
            guard let uid = Auth.auth().currentUser?.uid
                else {
                    DispatchQueue.main.async {
                        self.profileView.isHidden = true
                        self.listView.isHidden = true
                        self.signoutView.isHidden = true
                        self.loginView.isHidden = false
                        self.nameLabel.text = "Guest"
                        self.accountLabel.isHidden = true
                        self.profileImageView.isUserInteractionEnabled = false
                        self.nameLabel.isUserInteractionEnabled = false
                        self.accountLabel.isUserInteractionEnabled = false
                        self.profileImageView.image = UIImage(named: "defaultprofile")
                    }
                    return
            }
            DispatchQueue.main.async {
                self.profileView.isHidden = false
                self.listView.isHidden = false
                self.signoutView.isHidden = false
                self.loginView.isHidden = true
                self.accountLabel.isHidden = false
                self.profileImageView.isUserInteractionEnabled = true
                self.nameLabel.isUserInteractionEnabled = true
                self.accountLabel.isUserInteractionEnabled = true
            }
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
        
        let loginGesture = UITapGestureRecognizer(target: self, action: #selector(loginTouchEvent))
        loginView.addGestureRecognizer(loginGesture)
    }
    
    @objc func loginTouchEvent(){
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavViewController") as? UINavigationController{
            self.present(view, animated: true){
                self.sideMenuController?.hideMenu()
            }
        }
    }
    
    @objc func profileTouchEvent(){
        if let navView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewNavController") as? UINavigationController{
            if !navView.viewControllers.isEmpty, let pro = navView.viewControllers[0] as? ProfileViewController {
               pro.userModel = self.userModel
            }
            self.present(navView, animated: true) {
                self.sideMenuController?.hideMenu()
            }
        }
    }

    @objc func listTouchEvent(){
        if let navView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewNavController") as? UINavigationController{
            
            self.present(navView, animated: true) {
                self.sideMenuController?.hideMenu()
            }
        }
    }
    
    @objc func signoutTouchEvent(){
        try! Auth.auth().signOut()
        if let navView = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavViewController") as? UINavigationController{
            self.present(navView, animated: true){
                self.sideMenuController?.hideMenu()
            }
        }
    }
}

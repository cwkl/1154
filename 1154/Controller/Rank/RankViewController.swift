//
//  RankViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 11..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import SideMenuSwift
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class RankViewController: UIViewController {
    @IBOutlet weak var barProfileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userDateLoad()
        configureViewOption()
        addGesture()
        notificationReceive()
    }
    
    func configureViewOption(){
        barProfileImageView.layer.cornerRadius = barProfileImageView.frame.height / 2
        barProfileImageView.layer.masksToBounds = true
    }
    
    func addGesture(){
        let barImageGesture = UITapGestureRecognizer(target: self, action: #selector(barImageButtonEvent))
        barProfileImageView.addGestureRecognizer(barImageGesture)
        barProfileImageView.isUserInteractionEnabled = true
    }
    
    func notificationReceive(){
        NotificationManager.receive(mainUserReload: self, selector: #selector(mainUserLoadNotificaiton))
    }
    
    @objc func mainUserLoadNotificaiton(){
        userDateLoad()
    }
    
    @objc func barImageButtonEvent(){
        self.sideMenuController?.revealMenu()
    }
    
    func userDateLoad(){
        DispatchQueue.global().async {
            guard let uid = Auth.auth().currentUser?.uid
                else {
                    DispatchQueue.main.async {
                        self.barProfileImageView.image = UIImage(named: "defaultprofile")
                    }
                    return
            }
            
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil {
                }else{
                    do{
                        guard let snapshot = snapshot?.data(),
                            let userModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot) else {return}
                        
                        if userModel.profileImageUrl != nil{
                            guard let imageUrl = userModel.profileImageUrl else {return}
                            DispatchQueue.main.async {
                                self.barProfileImageView.alpha = 0
                                self.barProfileImageView.kf.setImage(with: URL(string: imageUrl)) { result in
                                    switch result {
                                    case .success( _):
                                        UIView.animate(withDuration: 0.2, animations: {
                                            self.barProfileImageView.alpha = 1
                                        })
                                    case .failure(let error):
                                        print(error)
                                        
                                    }
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.barProfileImageView.alpha = 0
                                self.barProfileImageView.image = UIImage(named: "defaultprofile")
                                
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.barProfileImageView.alpha = 1
                                })
                            }
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

//
//  NotificationViewController.swift
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

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationTableViewCellLikeDelegate{
    
    @IBOutlet weak var barProfileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var notifiModel: [NotificationModel] = []
    private var refreshControl : UIRefreshControl?
    private var isAddIndicator = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        startIndicator()
        notifiDataLoad()
        userDateLoad()
        configureViewOption()
        addGesture()
        notificationReceive()
    }
    
    func configureViewOption(){
        barProfileImageView.layer.cornerRadius = barProfileImageView.frame.height / 2
        barProfileImageView.layer.masksToBounds = true
        
        tableView.register(UINib(nibName: "NotificationTableViewCellLike", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCellLike")
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        self.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshed), for: .valueChanged)
    }
    
    func startIndicator() {
        if !isAddIndicator{
            self.tableView.alpha = 0
            ActivityIndicator.shared.addIndicator(view: self.view)
            ActivityIndicator.shared.start(view: tableView)
            isAddIndicator = true
        }
    }
    
    func activityIndicatorStop() {
        ActivityIndicator.shared.stop(view: tableView)
        isAddIndicator = false
    }
    
    @objc func refreshed(){
        notifiDataLoad()
    }
    
    func refreshEnd() {
        refreshControl?.endRefreshing()
    }
    
    func addGesture(){
        let barImageGesture = UITapGestureRecognizer(target: self, action: #selector(barImageButtonEvent))
        barProfileImageView.addGestureRecognizer(barImageGesture)
        barProfileImageView.isUserInteractionEnabled = true
    }
    
    func notificationReceive(){
        NotificationManager.receive(mainUserReload: self, selector: #selector(mainUserLoadNotification))
        NotificationManager.receive(pushNotification: self, selector: #selector(pushNotification))
    }
    
    @objc func pushNotification(){
        startIndicator()
        notifiDataLoad()
    }
    
    @objc func mainUserLoadNotification(){
        userDateLoad()
    }
    
    @objc func barImageButtonEvent(){
        self.sideMenuController?.revealMenu()
    }
    
    func tapMainCell(submitId: String, type: String, commentId: String) {
        self.view.isUserInteractionEnabled = false
        DispatchQueue.global().async {
            Firestore.firestore().collection("submit").document(submitId).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.data(), let data = try? FirestoreDecoder().decode(SubmitModel.self, from: snapshot) else {return}
                    DispatchQueue.main.async {
                        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SubmitContentViewController") as? SubmitContentViewController{
                            if type == "comment"{
                                view.fromNotifiCommentId = commentId
                            }else if type == "commentlike"{
                                view.fromNotifiCommentId = commentId
                            }
                            view.model = data
                            view.hidesBottomBarWhenPushed = true
                            self.view.isUserInteractionEnabled = true
                            self.navigationController?.pushViewController(view, animated: true)
                        }
                    }
                }
            })
        }
        
    }
    
    func tapProfileCell(uid: String) {
        self.view.isUserInteractionEnabled = false
        DispatchQueue.global().async {
            Firestore.firestore().collection("users").document(uid).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.data(), let data = try? FirestoreDecoder().decode(UserModel.self, from: snapshot) else {return}
                    DispatchQueue.main.async {
                        if let navView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewNavController") as? UINavigationController{
                            if !navView.viewControllers.isEmpty, let pro = navView.viewControllers[0] as? ProfileViewController {
                                pro.userModel = data
                            }
                             self.view.isUserInteractionEnabled = true
                            self.present(navView, animated: true)
                        }
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifiModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCellLike", for: indexPath) as? NotificationTableViewCellLike{
            cell.notificationTableViewCellLikeDelegate = self
            cell.selectionStyle = .none
            cell.submitId = self.notifiModel[indexPath.row].submitId
            cell.type = self.notifiModel[indexPath.row].type
            cell.commentId = self.notifiModel[indexPath.row].id
            cell.date = self.notifiModel[indexPath.row].date
            cell.content = self.notifiModel[indexPath.row].content
            cell.uid = self.notifiModel[indexPath.row].uid
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func userDateLoad(){
        DispatchQueue.global().async {
            guard let uid = Auth.auth().currentUser?.uid
                else {
                    DispatchQueue.main.async {
                        self.barProfileImageView.image = UIImage(named: "defaultprofile")
                        self.activityIndicatorStop()
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
    
    func notifiDataLoad(){
        guard let uid = Auth.auth().currentUser?.uid
            else {
                tableView.reloadData()
                refreshEnd()
                return
        }
        DispatchQueue.global().async {
            Firestore.firestore().collection("users").document(uid).collection("notification").order(by: "date", descending: true).getDocuments(completion: { (snapshot, error) in
                if error != nil{
                    
                }else{
                    guard let snapshot = snapshot?.documents else {return}
                    if snapshot.count == 0 {
                        self.activityIndicatorStop()
                        self.refreshControl?.endRefreshing()
                    }
                    self.notifiModel.removeAll()
                    for (index, document) in snapshot.enumerated(){
                        guard let data = try? FirestoreDecoder().decode(NotificationModel.self, from: document.data()) else {return}
                        self.notifiModel.append(data)
                        
                        if index + 1 == snapshot.count{
                            self.tableView.delegate = self
                            self.tableView.dataSource = self
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        }
    }
}

extension NotificationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

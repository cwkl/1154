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

class NotificationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NotificationCollectionViewCellDelegate {

    @IBOutlet weak var barProfileImageView: UIImageView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    private var pagerView: NotificationPageViewController = NotificationPageViewController()
    private var bar = UIView()
    private var leftConstraints: NSLayoutConstraint?
    private let item = ["Like","Comment"]
    
    var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userDateLoad()
        configureViewOption()
        addView()
        addGesture()
        notificationReceive()
    }
    
    func configureViewOption(){
        barProfileImageView.layer.cornerRadius = barProfileImageView.frame.height / 2
        barProfileImageView.layer.masksToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        pagerView.collectionView = self.collectionView
    }
    
    func addView(){
        let bar = UIView()
        menuView.addSubview(bar)
        self.bar = bar
        bar.backgroundColor = UIColor(red: 218/255, green: 65/255, blue: 103/255, alpha: 1.0) /* #da4167 */
        bar.translatesAutoresizingMaskIntoConstraints = false
        leftConstraints = bar.leadingAnchor.constraint(equalTo: menuView.leadingAnchor)
        leftConstraints?.isActive = true
        bar.bottomAnchor.constraint(equalTo: menuView.bottomAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        bar.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / CGFloat(item.count)).isActive = true
        
        pagerView.bar = bar
        pagerView.leftConstraints = leftConstraints
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotificationPageViewController,
            segue.identifier == "NotificationPager"{
            self.pagerView = vc
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? NotificationCollectionViewCell{
            cell.categoryLabel.text = item[indexPath.item]
            cell.indexPath = indexPath
            cell.delegate = self
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / CGFloat(item.count), height: collectionView.frame.height)
    }
    
    func tapCell(indexPath: IndexPath) {
        for visibleCell in collectionView.visibleCells {
            if let visibleCell = visibleCell as? NotificationCollectionViewCell {
                visibleCell.tapGesture.isEnabled = false
                
                if visibleCell.indexPath?.item == indexPath.item {
                    visibleCell.categoryLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.9) /* #134563 */
                } else {
                    visibleCell.categoryLabel.textColor = .lightGray
                }
            }
        }
        
        if !isAnimating {
            isAnimating = true
            let index = indexPath.row
            let x = (UIScreen.main.bounds.width / CGFloat(item.count)) * CGFloat(index)
            leftConstraints?.constant = x
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (complete) in
                self.isAnimating = false
                
                for visibleCell in self.collectionView.visibleCells {
                    if let visibleCell = visibleCell as? NotificationCollectionViewCell {
                        visibleCell.tapGesture.isEnabled = true
                    }
                }
            }
            self.pagerView.itemWasPressed(index: index)
        }
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

//
//  MainViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 11. 30..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import SideMenuSwift
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase


class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionViewCellCategoryDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var submitButton: UIImageView!
    @IBOutlet weak var barCountryItem: UIButton!
    @IBOutlet weak var barProfileItem: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var splashView: UIView!
    
    
    private var pagerView:PageViewController = PageViewController()
    private var bar = UIView()
    private var leftConstraints: NSLayoutConstraint?
    private let item = ["All","Free","Trevel","Food","Shopping"]
    private var statusBarHidden = true
    private var isFirst = true
    private var isIndicator = false
    private var isGuest = false
    var isAnimating = false
    
    var isProfileView = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDateLoad()
        addView()
        configureViewOption()
        addButtonGesture()
        splashStart()
        notificationReceive()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override var prefersStatusBarHidden: Bool{
        return statusBarHidden
    }
    
    func notificationReceive(){
        NotificationManager.receive(splashEnd: self, selector: #selector(splashEnd))
        NotificationManager.receive(mainUserReload: self, selector: #selector(mainUserLoadNotificaiton))
    }
    
    func splashStart(){
        if isFirst{
            splashView.backgroundColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1) /* #134563 */
            splashView.alpha = 1
            mainView.alpha = 0
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @objc func splashEnd(){
        DispatchQueue.main.async {
            self.isFirst = false
            self.tabBarController?.tabBar.isHidden = false
            self.statusBarHidden = false
            self.setNeedsStatusBarAppearanceUpdate()
            
            UIView.animate(withDuration: 0.4, animations: {
                self.mainView.alpha = 1
                self.splashView.alpha = 0
                self.splashView.isHidden = true
            })
            NotificationManager.removeSplashEnd(observer: self)
        }
    }
    
    @objc func mainUserLoadNotificaiton(){
        userDateLoad()
        mainView.alpha = 0
        ActivityIndicator.shared.addIndicator(view: self.view)
        ActivityIndicator.shared.start(view: self.view)
        isIndicator = true
    }
    
    func userDataLoadFailed(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.isGuest = true
            self.submitButton.isUserInteractionEnabled = true
            self.barProfileItem.image = UIImage(named: "defaultprofile")
            if self.isIndicator{
                self.mainView.alpha = 1
                ActivityIndicator.shared.stop(view: self.view)
                self.isIndicator = false
            }
        })
    }
    
    func userDateLoad(){
        DispatchQueue.global().async {
            guard let uid = Auth.auth().currentUser?.uid else {self.userDataLoadFailed(); return}
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil {
                }else{
                    do{
                        guard let snapshot = snapshot?.data(),
                            let userModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot)
                            else {self.userDataLoadFailed(); return}
                        
                        self.submitButton.isUserInteractionEnabled = true
                        self.isGuest = false
                        if userModel.profileImageUrl != nil{
                            guard let imageUrl = userModel.profileImageUrl else {return}
                            DispatchQueue.main.async {
                                self.barProfileItem.alpha = 0
                                
                                self.barProfileItem.kf.setImage(with: URL(string: imageUrl)) { result in
                                    switch result {
                                    case .success( _):
                                        UIView.animate(withDuration: 0.2, animations: {
                                            self.barProfileItem.alpha = 1
                                        })
                                        if self.isIndicator{
                                            self.mainView.alpha = 1
                                            ActivityIndicator.shared.stop(view: self.view)
                                            self.isIndicator = false
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.barProfileItem.alpha = 0
                                self.barProfileItem.image = UIImage(named: "defaultprofile")
                                
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.barProfileItem.alpha = 1
                                })
                                if self.isIndicator{
                                    self.mainView.alpha = 1
                                    ActivityIndicator.shared.stop(view: self.view)
                                    self.isIndicator = false
                                }
                            }
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    func addButtonGesture(){
        let submitGesture = UITapGestureRecognizer(target: self, action: #selector(submitButtonEvent))
        submitButton.isUserInteractionEnabled  = false
        submitButton.addGestureRecognizer(submitGesture)
        
        let sideMenuGesture = UITapGestureRecognizer(target: self, action: #selector(barProfileTouchEvent))
        barProfileItem.isUserInteractionEnabled = true
        barProfileItem.addGestureRecognizer(sideMenuGesture)
    }
    
    func configureViewOption(){
        collectionView.backgroundColor = UIColor.white
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        pagerView.collectionView = self.collectionView
        
        barCountryItem.setImage(UIImage(named: "all")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
        barProfileItem.layer.cornerRadius = barProfileItem.frame.height / 2
        barProfileItem.layer.masksToBounds = true
        barProfileItem.contentMode = .scaleAspectFill
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
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
    

    @objc func barProfileTouchEvent() {
        self.sideMenuController?.revealMenu()
    }
    
    @IBAction func barItemTouchEvent(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertController.Style.actionSheet)
        
        let all: UIAlertAction = UIAlertAction(title: "All", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.barCountryItem.setImage(UIImage(named: "all")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
            let country = "all"
            for viewController in self.pagerView.viewControllerList {
                if let allVC = viewController as? AllTableViewController {
                    allVC.country = country
                    allVC.tableViewLoad()
                }else if let freeVC = viewController as? FreeTableViewController {
                    freeVC.country = country
                    freeVC.tableViewLoad()
                }else if let trevelVC = viewController as? TrevelTableViewController {
                    trevelVC.country = country
                    trevelVC.tableViewLoad()
                }else if let foodVC = viewController as? FoodTableViewController {
                    foodVC.country = country
                    foodVC.tableViewLoad()
                }else if let shoppingVC = viewController as? ShoppingTableViewController {
                    shoppingVC.country = country
                    shoppingVC.tableViewLoad()
                }
            }
        })
        let korea: UIAlertAction = UIAlertAction(title: "Korea", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.barCountryItem.setImage(UIImage(named: "korea")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
            let country = "korea"
            for viewController in self.pagerView.viewControllerList {
                if let allVC = viewController as? AllTableViewController {
                    allVC.country = country
                    allVC.tableViewLoad()
                }else if let freeVC = viewController as? FreeTableViewController {
                    freeVC.country = country
                    freeVC.tableViewLoad()
                }else if let trevelVC = viewController as? TrevelTableViewController {
                    trevelVC.country = country
                    trevelVC.tableViewLoad()
                }else if let foodVC = viewController as? FoodTableViewController {
                    foodVC.country = country
                    foodVC.tableViewLoad()
                }else if let shoppingVC = viewController as? ShoppingTableViewController {
                    shoppingVC.country = country
                    shoppingVC.tableViewLoad()
                }
            }
        })
        let japan: UIAlertAction = UIAlertAction(title: "Japan", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.barCountryItem.setImage(UIImage(named: "japan")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
            let country = "japan"
            for viewController in self.pagerView.viewControllerList {
                if let allVC = viewController as? AllTableViewController {
                    allVC.country = country
                    allVC.tableViewLoad()
                }else if let freeVC = viewController as? FreeTableViewController {
                    freeVC.country = country
                    freeVC.tableViewLoad()
                }else if let trevelVC = viewController as? TrevelTableViewController {
                    trevelVC.country = country
                    trevelVC.tableViewLoad()
                }else if let foodVC = viewController as? FoodTableViewController {
                    foodVC.country = country
                    foodVC.tableViewLoad()
                }else if let shoppingVC = viewController as? ShoppingTableViewController {
                    shoppingVC.country = country
                    shoppingVC.tableViewLoad()
                }
            }
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            
        })
    
        alert.addAction(all)
        alert.addAction(korea)
        alert.addAction(japan)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func submitButtonEvent(){
        if isGuest{
            let alert = UIAlertController(title: "Guest can not post", message: "Do you want to go to the login page?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                if let view = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavViewController") as? UINavigationController{
                    self.present(view, animated: true)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }else{
            if let view = self.storyboard?.instantiateViewController(withIdentifier: "SubmitViewController"){
                self.present(view, animated: true, completion: nil)
            }
        }
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PageViewController,
            segue.identifier == "pager"{
            self.pagerView = vc
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCellCategory
        cell.cellLabel.text = item[indexPath.item]
        cell.indexPath = indexPath
        cell.delegate = self

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / CGFloat(item.count), height: collectionView.frame.height)
    }
    
    func tapCell(indexPath: IndexPath) {
        for visibleCell in collectionView.visibleCells {
            if let visibleCell = visibleCell as? CollectionViewCellCategory {
                visibleCell.tapGesture.isEnabled = false
                
                if visibleCell.indexPath?.item == indexPath.item {
                    visibleCell.cellLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.9) /* #134563 */
                } else {
                    visibleCell.cellLabel.textColor = .lightGray
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
                    if let visibleCell = visibleCell as? CollectionViewCellCategory {
                        visibleCell.tapGesture.isEnabled = true
                    }
                }
            }
            self.pagerView.itemWasPressed(index: index)
        }
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

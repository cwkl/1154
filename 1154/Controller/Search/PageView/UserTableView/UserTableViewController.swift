//
//  UserTableViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 14..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth
import InstantSearchClient

class UserTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultView: UIView!
    
    private var submitIdArray: [SubmitIdDateModel] = []
    private var isAddIndicator = false
    private let query = Query()
    private var nbPages = UInt()
    private var page: UInt = 0
    private var searchUser: [AlgoriaUserModel] = []
    
    var pagerView: SearchPageViewController?
    
    var searchText: String? {
        didSet {
            guard let searchText = self.searchText else {return}
            search(searchText: searchText)
            startIndicator()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewOption()
    }
    
    func startIndicator() {
        if !isAddIndicator{
            self.tableView.alpha = 0
            ActivityIndicator.shared.addIndicator(view: self.view)
            ActivityIndicator.shared.start(view: tableView)
            isAddIndicator = true
        }
    }
    
    func search(searchText: String){
        tableView.isHidden = false
        noResultView.isHidden = true
        
        let index = SessionManager.shared.client.index(withName: "user")
        
        query.query = searchText
        //        query.hitsPerPage = 30
        page = 0
        query.page = page
        self.searchUser.removeAll()
        DispatchQueue.global().async {
            
            index.search(self.query, completionHandler: { (content, error) -> Void in
                if let content = content, let hits = content["hits"] as? [AnyObject], !hits.isEmpty {
                    for (hitIndex, hit) in hits.enumerated() {
                        guard let hitData = hit as? [String: AnyObject],
                            let nbPages = content["nbPages"] as? UInt else {return}
                        
                        self.nbPages = nbPages
                        
                        do {
                            let user = try FirebaseDecoder().decode(AlgoriaUserModel.self, from: hitData)
                            self.searchUser.append(user)
                            
                            
                            
                            DispatchQueue.main.async {
                                if hitIndex + 1 == hits.count {
                                    self.tableView.reloadData()
                                }
                            }
                        } catch let error {
                            
                        }
                    }
                } else if let error = error {
                    self.noResultEvent()
                    self.activityIndicatorStop()
                } else {
                    self.noResultEvent()
                    self.activityIndicatorStop()
                }
            })
        }
    }
    
    func noResultEvent(){
        tableView.isHidden = true
        noResultView.isHidden = false
    }
    
    func activityIndicatorStop() {
        ActivityIndicator.shared.stop(view: tableView)
        isAddIndicator = false
    }
    
    func tapCell(userModel: UserModel) {
        if let navView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewNavController") as? UINavigationController{
            if !navView.viewControllers.isEmpty, let pro = navView.viewControllers[0] as? ProfileViewController {
                pro.userModel = userModel
            }
            self.present(navView, animated: true)
        }
    }
    
    func configureViewOption(){
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell{
            if self.searchUser.isEmpty {return UITableViewCell()}
            cell.userTableViewCellDelegate = self
            cell.userId = self.searchUser[indexPath.row].uid
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

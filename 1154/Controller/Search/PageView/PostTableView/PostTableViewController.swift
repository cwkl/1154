//
//  PostTableViewController.swift
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

class PostTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultView: UIView!
    
    private var submitIdArray: [SubmitIdDateModel] = []
    private var isAddIndicator = false
    private let query = Query()
    private var nbPages = UInt()
    private var page: UInt = 0
    private var searchPost: [AlgoriaSubmitModel] = []
    
    var pagerView:SearchPageViewController?
    
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
        
        let index = SessionManager.shared.client.index(withName: "post")
        
        query.query = searchText
//        query.hitsPerPage = 30
        page = 0
        query.page = page
        self.searchPost.removeAll()
        DispatchQueue.global().async {
            index.search(self.query, completionHandler: { (content, error) -> Void in
                if let content = content, let hits = content["hits"] as? [AnyObject], !hits.isEmpty {
                    for (hitIndex, hit) in hits.enumerated() {
                        guard let hitData = hit as? [String: AnyObject],
                            let nbPages = content["nbPages"] as? UInt else {return}
                        
                        self.nbPages = nbPages
                        
                        do {
                            let post = try FirebaseDecoder().decode(AlgoriaSubmitModel.self, from: hitData)
                            self.searchPost.append(post)
                            
                            
                            
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
    
    func tapCell(submitId: String) {
        DispatchQueue.global().async {
            Firestore.firestore().collection("submit").document(submitId).getDocument { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.data(), let data = try? FirestoreDecoder().decode(SubmitModel.self, from: snapshot) else {return}
                    DispatchQueue.main.async {
                        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SubmitContentViewController") as? SubmitContentViewController{
                            view.model = data
                            view.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(view, animated: true)
                        }                        
                    }
                }
            }
        }
    }
    
    func configureViewOption(){
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell{
            if self.searchPost.isEmpty{ return UITableViewCell()}
            cell.postTableViewCellDelegate = self
            cell.titleLabel.text = self.searchPost[indexPath.row].title
            cell.submitId = self.searchPost[indexPath.row].id
            cell.userId = self.searchPost[indexPath.row].uid
            cell.dateLabel.text = SharedFunction.shared.getCurrentLocaleDateFromString(string: self.searchPost[indexPath.row].date, format: "yyyy. MM. dd")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

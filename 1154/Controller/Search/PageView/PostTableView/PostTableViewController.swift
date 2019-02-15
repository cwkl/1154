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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
    }
    
//    override func viewDidLayoutSubviews() {
//        if !isAddIndicator{
//            self.tableView.alpha = 0
//            ActivityIndicator.shared.addIndicator(view: self.view)
//            ActivityIndicator.shared.start(view: tableView)
//            isAddIndicator = true
//        }
//    }
    
    func search(searchText: String){
        let index = SessionManager.shared.client.index(withName: "post")
        
        query.query = searchText
//        query.hitsPerPage = 30
        page = 0
        query.page = page
        
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
                                    
                                }
                            }
                        } catch let error {
                            
                        }
                    }
                } else if let error = error {
                    
                } else {
                    
                }
            })
        }
    }
    
    func activityIndicatorStop() {
        ActivityIndicator.shared.stop(view: tableView)
    }
    
    func tapCell(submitModel: SubmitModel) {
//        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SubmitContentViewController") as? SubmitContentViewController{
//            view.model = submitModel
//            self.navigationController?.pushViewController(view, animated: true)
//        }
    }
    
    func configureViewOption(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell{
            cell.postTableViewCellDelegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

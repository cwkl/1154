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

class PostTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var submitIdArray: [SubmitIdDateModel] = []
    private var isAddIndicator = false
    
    var pagerView:SearchPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
//    override func viewDidLayoutSubviews() {
//        if !isAddIndicator{
//            self.tableView.alpha = 0
//            ActivityIndicator.shared.addIndicator(view: self.view)
//            ActivityIndicator.shared.start(view: tableView)
//            isAddIndicator = true
//        }
//    }
    
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? SearchTableViewCell{
            cell.searchTableViewCellDelegate = self
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

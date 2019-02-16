//
//  LikeNotifiTableViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 17..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class LikeNotifiTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LikeNotifiTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var pagerView: NotificationPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewOption()
    }
    
    func configureViewOption(){
        tableView.register(UINib(nibName: "LikeNotifiTableViewCell", bundle: nil), forCellReuseIdentifier: "LikeNotifiTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    func tapCell(submitId: String) {
        
    }
    
    func activityIndicatorStop() {
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LikeNotifiTableViewCell", for: indexPath) as? LikeNotifiTableViewCell{
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension LikeNotifiTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

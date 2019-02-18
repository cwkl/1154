////
////  CommentNotifiTableViewController.swift
////  1154
////
////  Created by Junhyeok Kwon on 2019. 2. 16..
////  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
////
//
//import UIKit
//
//class CommentNotifiTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentNotifiTableViewCellDelegate {
//
//    @IBOutlet weak var tableView: UITableView!
//    
//    var pagerView: NotificationPageViewController?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        configureViewOption()
//    }
//    
//    func configureViewOption(){
//        tableView.register(UINib(nibName: "CommentNotifiTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentNotifiTableViewCell")
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.reloadData()
//    }
//    
//    func tapCell(submitId: String) {
//        
//    }
//    
//    func activityIndicatorStop() {
//        
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentNotifiTableViewCell", for: indexPath) as? CommentNotifiTableViewCell{
//            
//            return cell
//        }
//        return UITableViewCell()
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
//    
//}
//
//extension CommentNotifiTableViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}

//
//  ShoppingTableViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 12..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

class ShoppingTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var refreshControl : UIRefreshControl?
    var pagerView:PageViewController?
    var array: [SubmitModel] = []
    var country = "all"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        self.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshed), for: .valueChanged)
        
        tableViewLoad()
    }
    
    func tableViewLoad() {
        var whereField: Query?
        if country == "all" {
            whereField = Firestore.firestore().collection("submit").whereField("category", isEqualTo: "shopping")
        }else if country == "korea"{
            whereField = Firestore.firestore().collection("submit").whereField("category", isEqualTo: "shopping").whereField("country", isEqualTo: "korea")
        }else if country == "japan"{
            whereField = Firestore.firestore().collection("submit").whereField("category", isEqualTo: "shopping").whereField("country", isEqualTo: "japan")
        }
        
        guard let field = whereField else {return}
        field.order(by: "time", descending: true).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{return}
            self.array.removeAll()
            
            if error != nil{
                print(error)
            }else{
                for document in snapshot.documents {
                    do{
                        print(snapshot.documents)
                        let model = try? FirebaseDecoder().decode(SubmitModel.self, from: document.data())
                        guard let submitModel = model else{return}
                        self.array.append(submitModel)
                        
                    }catch let error{
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    @objc func refreshed(){
        tableViewLoad()
        guard let pageView = self.pagerView else { return }
        for viewController in pageView.viewControllerList {
            if let allVC = viewController as? AllTableViewController {
                allVC.refresh()
            }else if let trevelVC = viewController as? TrevelTableViewController {
                trevelVC.refresh()
            }else if let foodVC = viewController as? FoodTableViewController {
                foodVC.refresh()
            }else if let freeVC = viewController as? FreeTableViewController {
                freeVC.refresh()
            }
        }
    }
    
    func refresh(){
        tableViewLoad()
    }
}

extension ShoppingTableViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableViewCell
        cell?.userName.text = self.array[indexPath.row].name
        cell?.title.text = self.array[indexPath.row].title
        cell?.commentCount.text = String(self.array[indexPath.row].commentCount)
        cell?.likeCount.text = String(self.array[indexPath.row].likeCount)
        cell?.viewsCount.text = String(self.array[indexPath.row].viewsCount)
        cell?.selectionStyle = .none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

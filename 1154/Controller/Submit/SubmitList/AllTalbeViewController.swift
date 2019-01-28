//
//  AllTalbeViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 10..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase


class AllTableViewController : UIViewController{
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
    
    override func viewWillAppear(_ animated: Bool) {
        refreshed()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SubmitContentViewController") as? SubmitContentViewController{
            view.model = array[indexPath.row]
            view.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
    
    func tableViewLoad() {
        var whereField: Query?
        if country == "all" {
            whereField = Firestore.firestore().collection("submit")
        }else if country == "korea"{
            whereField = Firestore.firestore().collection("submit").whereField("country", isEqualTo: "korea")
        }else if country == "japan"{
            whereField = Firestore.firestore().collection("submit").whereField("country", isEqualTo: "japan")
        }
        
        guard let field = whereField else {return}
        field.order(by: "date", descending: true).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{return}
            self.array.removeAll()
            
            if error != nil{
            }else{
                for document in snapshot.documents {
                    do{
                        let model = try? FirebaseDecoder().decode(SubmitModel.self, from: document.data())
                        guard let submitModel = model else{return}
                        self.array.append(submitModel)
                        
                    }catch let error{
                        print(error)
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
            if let freeVC = viewController as? FreeTableViewController {
                freeVC.refresh()
            }else if let trevelVC = viewController as? TrevelTableViewController {
                trevelVC.refresh()
            }else if let foodVC = viewController as? FoodTableViewController {
                foodVC.refresh()
            }else if let shoppingVC = viewController as? ShoppingTableViewController {
                shoppingVC.refresh()
            }
        }
    }
    
    func refresh(){
        tableViewLoad()
    }
}

extension AllTableViewController: UITableViewDelegate, UITableViewDataSource{
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

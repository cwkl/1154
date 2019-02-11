//
//  BookmarkTableViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 7..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth

class BookmarkTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ListTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private var submitIdArray: [SubmitIdDateModel] = []
    private var isAddIndicator = false
    
    var pagerView:ListPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        if !isAddIndicator{
            self.tableView.alpha = 0
            ActivityIndicator.shared.addIndicator(view: self.view)
            ActivityIndicator.shared.start(view: tableView)
            isAddIndicator = true
            loadLikeSubmitList()
        }
    }
    
    func activityIndicatorStop() {
        ActivityIndicator.shared.stop(view: tableView)
    }
    
    func tapCell(submitModel: SubmitModel) {
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SubmitContentViewController") as? SubmitContentViewController{
            view.model = submitModel
            view.isBookmark = true
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
    
    func loadLikeSubmitList(){
        DispatchQueue.global().async {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Firestore.firestore().collection("users").document(uid).collection("bookmark").order(by: "date", descending: true).getDocuments { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot?.documents else {return}
                    let count = snapshot.count
                    if count == 0{
                        ActivityIndicator.shared.stop(view: self.tableView)
                    }
                    do{
                        for (index, document) in snapshot.enumerated(){
                            guard let data = try? FirestoreDecoder().decode(SubmitIdDateModel.self, from: document.data()) else {return}
                            self.submitIdArray.append(data)
                            
                            if index + 1 == count{
                                self.configureViewOption()
                            }
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func configureViewOption(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return submitIdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ListTableViewCell{
            cell.submitId = self.submitIdArray[indexPath.row].submitId
            cell.listTableViewCellDelegate = self
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

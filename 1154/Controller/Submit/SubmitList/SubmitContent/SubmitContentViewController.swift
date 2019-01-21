//
//  SubmitContentViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 8..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class SubmitContentViewController: UIViewController, PhotoCellDelegate{
    
    func showImageDetail(imageDetailView: UIViewController) {
        self.present(imageDetailView, animated: false, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var commentsCount: Int = 0
    var model: SubmitModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "titleCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        tableView.register(UINib(nibName: "photoCell", bundle: nil), forCellReuseIdentifier: "photoCell")
        tableView.register(UINib(nibName: "contentCell", bundle: nil), forCellReuseIdentifier: "contentCell")
        tableView.register(UINib(nibName: "commentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func backEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SubmitContentViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = model else {return 0}

        if model.imageUrl != nil {
            return commentsCount + 3
        } else {
            return commentsCount + 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = model else {return UITableViewCell()}
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            if model.profileImageUrl == ""{
                cell.profileImageView.image = UIImage(named: "defaultprofile")
            }else{
                
            }
            cell.nameLabel.text = model.name
            cell.titleLabel.text = model.title
            cell.timeLabel.text = model.time
            cell.commentsCountLabel.text = "\(model.commentCount)"
            cell.likesCountLabel.text = "\(model.likeCount)"
            cell.viewsCountLabel.text = "\(model.viewsCount)"
            return cell
        } else {
            if let imageUrl = model.imageUrl {
                if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoCell
                    cell.imageUrl = model.imageUrl
                    cell.photoCellDelegate = self
                    return cell
                } else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! ContentCell
                    cell.contentTextView.text = model.content
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
                    return cell
                }
            } else {
                if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! ContentCell
                    cell.contentTextView.text = model.content
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
                    return cell
                }
            }
        }
    }
}

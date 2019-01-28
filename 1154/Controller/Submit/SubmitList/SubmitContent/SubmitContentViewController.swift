//
//  SubmitContentViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 8..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CodableFirebase
import Kingfisher

class SubmitContentViewController: UIViewController, PhotoCellDelegate, UITextFieldDelegate, CommentCellDelegate{
    
    func showDeleteAlert(submitId: String, commentId: String) {
        let alert: UIAlertController = UIAlertController(title: "", message: "Do you want to delete this comment?", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
        Firestore.firestore().collection("submit").document(submitId).collection("comment").document(commentId).updateData(["delete" : true]) { (error) in
                if error != nil{
                    print(error)
                }else{
                    self.commentDataLoad()
                }
            }
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in})
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func showImageDetail(imageDetailView: UIViewController) {
        self.present(imageDetailView, animated: false, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentMainView: UIView!
    @IBOutlet weak var commentMainViewBottom: NSLayoutConstraint!
    @IBOutlet weak var commentPostView: UIView!
    @IBOutlet weak var commentProfileImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentPostButton: UIButton!
    
    private var userModel: UserModel?
    private var submitModel: SubmitModel?
    private var uid: String?
    private var commentArray: [CommentModel] = []
    private var tap = UITapGestureRecognizer()
    private var spanArray: [TimeInterval] = []
    private var refreshControl : UIRefreshControl?
    var model: SubmitModel?
    private var viewsCount: Int?
    private var likesCount: Int?
    private var commentsCount: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentPostView.layer.borderWidth = 1
        commentPostView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        commentPostView.layer.cornerRadius = commentPostView.frame.height / 2
        
        commentProfileImageView.layer.cornerRadius = commentProfileImageView.frame.width / 2
        commentProfileImageView.clipsToBounds = true
        
        tableView.register(UINib(nibName: "titleCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        tableView.register(UINib(nibName: "photoCell", bundle: nil), forCellReuseIdentifier: "photoCell")
        tableView.register(UINib(nibName: "contentCell", bundle: nil), forCellReuseIdentifier: "contentCell")
        tableView.register(UINib(nibName: "commentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(keyboardHide(_:)))
        tap.isEnabled = false
        tableView.addGestureRecognizer(tap)
        
        commentTextField.delegate = self
        
        commentPostButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        userDataLoad()
        commentDataLoad()
        countWatcher()
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        self.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let viewsCount = self.viewsCount else {return}
        viewsCountUpdate(count: viewsCount + 1)
    }
    
    func countWatcher(){
        guard let id = self.model?.id else {return}
        DispatchQueue.main.async {
            Firestore.firestore().collection("submit").document(id).addSnapshotListener({ (snapshot, error) in
                guard let snapshot = snapshot, let data = snapshot.data() else {return}
                if error != nil{
                }else{
                    do{
                        self.submitModel = try? FirestoreDecoder().decode(SubmitModel.self, from: data)
                        self.viewsCount = self.submitModel?.viewsCount
                        self.likesCount = self.submitModel?.likeCount
                        self.commentsCount = self.submitModel?.commentCount
                    }
                }
            })
        }
    }
    
    func countRefresh(){
        DispatchQueue.main.async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot, let data = snapshot.data() else { return }
                    do{
                        self.model = try? FirestoreDecoder().decode(SubmitModel.self, from: data)
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    @objc func refresh(){
        DispatchQueue.main.async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).getDocument(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot, let data = snapshot.data() else { return }
                    do{
                        self.model = try? FirestoreDecoder().decode(SubmitModel.self, from: data)
                        
                        self.commentDataLoad()
                    }
                }
            })
        }
    }
    
    func userDataLoad(){
        DispatchQueue.global().async {
            self.uid = Auth.auth().currentUser?.uid
            
            Firestore.firestore().collection("users").document(self.uid ?? "").getDocument(completion: { (snapshot, error) in
                if error != nil{
                    
                }else{
                    guard let snapshot = snapshot, let data = snapshot.data() else { return }
                    do{
                        self.userModel = try? FirestoreDecoder().decode(UserModel.self, from: data)
                        if self.userModel?.profileImageUrl != nil{
                            guard let profileImage = self.userModel?.profileImageUrl else {return}
                            self.commentProfileImageView.kf.setImage(with: URL(string: profileImage))
                        }else{
                            self.commentProfileImageView.image = UIImage(named: "defaultprofile")
                        }
                    }
                }
            })
        }
    }
    
    func commentDataLoad(completion:(()->())? = nil){
        DispatchQueue.global().async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).collection("comment").order(by: "date", descending: false).getDocuments(completion: { (snapshot, error) in
                self.commentArray.removeAll()
                
                if error != nil{
                }else{
                    self.commentArray.removeAll()
                    self.spanArray.removeAll()
                    guard let snapshot = snapshot else {return}
                    for document in snapshot.documents{
                        let model = try? FirestoreDecoder().decode(CommentModel.self, from: document.data())
                        guard let commentModel = model else {return}
                        self.commentArray.append(commentModel)
                    }
                    
                    for (index, _) in self.commentArray.enumerated() {
                        let wrritenDate = SharedFunction.shared.dateFromString(string: self.commentArray[index].date)
                        let nowDate = SharedFunction.shared.dateFromString(string: SharedFunction.shared.getToday())
                        let span = nowDate.timeIntervalSince(wrritenDate)
                        self.spanArray.append(span)
                        
                        DispatchQueue.main.async {
                            if index + 1 == self.spanArray.count {
                                self.tableView.reloadData()
                                self.refreshControl?.endRefreshing()
                                completion?()
                            }
                        }
                    }
                }
            })
        }
    }
    
    func viewsCountUpdate(count: Int){
        DispatchQueue.main.async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).updateData(["viewsCount" : count], completion: { (error) in
                if error != nil{
                }else{
                    self.countRefresh()
                }
            })
        }
    }
    
    func likeCountUpdate(count: Int){
        DispatchQueue.main.async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).updateData(["likeCount" : count], completion: { (error) in
                if error != nil{
                }else{
                    self.countRefresh()
                }
            })
        }
    }
    
    func commentCountUpdate(count: Int){
        DispatchQueue.main.async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).updateData(["commentCount" : count], completion: { (error) in
                if error != nil{
                }else{
                    self.countRefresh()
                }
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let text = textField.text?.count else {return}
            if text > 0{
                self.commentPostButton.isEnabled = true
                self.commentPostButton.setTitleColor(UIColor(red: 218/255, green: 66/255, blue: 103/255, alpha: 0.9), for: .normal)
            }else if text == 0{
                self.commentPostButton.isEnabled = false
                self.commentPostButton.setTitleColor(UIColor(red: 218/255, green: 66/255, blue: 103/255, alpha: 0.2), for: .normal)
            }
        }
        return true
    }
    
    @objc func keyboardHide(_ sender: UITapGestureRecognizer){
        commentTextField.resignFirstResponder()
    }

    
    @IBAction func commentPostButtonEvent(_ sender: Any) {
        commentPostButton.isEnabled = false
        self.commentPostButton.setTitleColor(UIColor(red: 218/255, green: 66/255, blue: 103/255, alpha: 0.2), for: .normal)
        self.commentTextField.resignFirstResponder()
        guard let name = userModel?.name,
            let uid = uid,
            let comment = commentTextField.text else {return}

        var to: String? = nil
        let commentId = UUID.init().uuidString
        let commentModel = CommentModel(name: name , uid: uid, date: SharedFunction.shared.getToday(), comment: comment, commentLikeCount: 0, to: to, id: commentId, isSubComment: false, delete: false)
        let data = try? FirestoreEncoder().encode(commentModel)
        guard let id = model?.id, let commentData = data else {return}

        Firestore.firestore().collection("submit").document(id).collection("comment").document(commentId).setData(commentData) { (error) in
            if error != nil{

            }else{
                self.commentTextField.text = ""
                self.commentDataLoad(completion: {
                        self.scrollToBottom()
                })
                self.commentCountUpdate(count: self.commentArray.count + 1)
            }
        }
    }

    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        tap.isEnabled = true
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let window = UIApplication.shared.keyWindow
        guard let bottomPadding = window?.safeAreaInsets.bottom else {return}
        commentMainViewBottom.constant = -(keyboardSize.height - bottomPadding)

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tap.isEnabled = false
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        commentMainViewBottom.constant = 0

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func backEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SubmitContentViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = model else {return 0}

        if model.imageUrl != nil {
            return commentArray.count + 3
        } else {
            return commentArray.count + 2
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
            cell.timeLabel.text = SharedFunction.shared.getCurrentLocaleDateFromString(string: model.date, format: "yyyy.MM.dd  HH:mm")
            cell.commentsCountLabel.text = "\(model.commentCount)"
            cell.likesCountLabel.text = "\(model.likeCount)"
            cell.viewsCountLabel.text = "\(model.viewsCount)"
            cell.uid = self.uid
            cell.submitId = model.id
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
                    cell.contentLabel.text = model.content
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
                    cell.nameLabel.text = commentArray[indexPath.row - 3].name
                    cell.commentCellDelegate = self
                    cell.submitId = model.id
                    cell.commentId = commentArray[indexPath.row - 3].id
                    if uid == commentArray[indexPath.row - 3].uid{
                        cell.deleteButtonView.isHidden = false
                        cell.replyButton.isHidden = true
                    }else{
                        cell.deleteButtonView.isHidden = true
                        cell.replyButton.isHidden = false
                    }
                    
                    if commentArray[indexPath.row - 3].delete{
                        cell.commentLabel.text = "This comment has been deleted."
                        cell.commentLabel.textColor = UIColor.lightGray
                        
                        cell.likeButton.isHidden = true
                        cell.deleteButtonView.isHidden = true
                        cell.replyButton.isHidden = true
                    }else{
                        cell.commentLabel.text = commentArray[indexPath.row - 3].comment
                        cell.commentLabel.textColor = UIColor.black
                        cell.likeButton.isHidden = false
                        cell.deleteButtonView.isHidden = false
                        cell.replyButton.isHidden = false
                    }

                    var date = ""
                    let span = spanArray[indexPath.row - 3]
                    if span > 2592000{
                        date = SharedFunction.shared.getCurrentLocaleDateFromString(string: commentArray[indexPath.row - 3].date, format: "yyyy.MM.dd  HH:mm")
                    }else{
                        if 1 <= span / 604800{
                            let spanToWeek = Int(span / 604800)
                            if spanToWeek > 1{
                                date = "\(spanToWeek) weeks ago"
                            }else{
                                date = "\(spanToWeek) week ago"
                            }
                        }else if 1 <= span / 86400{
                            let spanToDay = Int(span / 86400)
                            if spanToDay > 1{
                                date = "\(spanToDay) days ago"
                            }else{
                                date = "\(spanToDay) day ago"
                            }
                        }else if 1 <= span / 3600{
                            let spanToHour = Int(span / 3600)
                            if spanToHour > 1{
                                date = "\(spanToHour) hours ago"
                            }else{
                                date = "\(spanToHour) hour ago"
                            }
                        }else if 1 <= span / 60{
                            let spanToMin = Int(span / 60)
                            if spanToMin > 1{
                                date = "\(spanToMin) minutes ago"
                            }else{
                                date = "\(spanToMin) minute ago"
                            }
                        }else if span < 60{
                            let spanToSec = Int(span)
                            if spanToSec > 1{
                                date = "\(spanToSec) seconds ago"
                            }else if spanToSec <= 1{
                                date = "1 second ago"
                            }
                        }
                    }
                    
                    cell.timeLabel.text = date
                    cell.likeCountLabel.text = "\(commentArray[indexPath.row - 3].commentLikeCount)"
                    if 0 < commentArray[indexPath.row - 3].commentLikeCount{
                        cell.likeTextLabel.text = "likes"
                    }else{
                        cell.likeTextLabel.text = "like"
                    }
                    return cell
                }
            } else {
                if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! ContentCell
                    cell.contentLabel.text = model.content
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
                    cell.nameLabel.text = commentArray[indexPath.row - 2].name
                    cell.commentCellDelegate = self
                    cell.submitId = model.id
                    cell.commentId = commentArray[indexPath.row - 2].id
                    
                    if uid == commentArray[indexPath.row - 2].uid{
                        cell.deleteButtonView.isHidden = false
                        cell.replyButton.isHidden = true
                    }else{
                        cell.deleteButtonView.isHidden = true
                        cell.replyButton.isHidden = false
                    }
                    
                    if commentArray[indexPath.row - 2].delete{
                        cell.commentLabel.text = "This comment has been deleted."
                        cell.commentLabel.textColor = UIColor.lightGray
                        
                        cell.likeButton.isHidden = true
                        cell.deleteButtonView.isHidden = true
                        cell.replyButton.isHidden = true
                    }else{
                        cell.commentLabel.text = commentArray[indexPath.row - 2].comment
                        cell.commentLabel.textColor = UIColor.black
                        cell.likeButton.isHidden = false
                        cell.deleteButtonView.isHidden = false
                        cell.replyButton.isHidden = false
                    }
                    
                    var date = ""
                    let span = spanArray[indexPath.row - 2]
                    if span > 2592000{
                        date = SharedFunction.shared.getCurrentLocaleDateFromString(string: commentArray[indexPath.row - 3].date, format: "yyyy.MM.dd  HH:mm")
                    }else{
                        if 1 <= span / 604800{
                            let spanToWeek = Int(span / 604800)
                            if spanToWeek > 1{
                                date = "\(spanToWeek) weeks ago"
                            }else{
                                date = "\(spanToWeek) week ago"
                            }
                        }else if 1 <= span / 86400{
                            let spanToDay = Int(span / 86400)
                            if spanToDay > 1{
                                date = "\(spanToDay) days ago"
                            }else{
                                date = "\(spanToDay) day ago"
                            }
                        }else if 1 <= span / 3600{
                            let spanToHour = Int(span / 3600)
                            if spanToHour > 1{
                                date = "\(spanToHour) hours ago"
                            }else{
                                date = "\(spanToHour) hour ago"
                            }
                        }else if 1 <= span / 60{
                            let spanToMin = Int(span / 60)
                            if spanToMin > 1{
                                date = "\(spanToMin) minutes ago"
                            }else{
                                date = "\(spanToMin) minute ago"
                            }
                        }else if span < 60{
                            let spanToSec = Int(span)
                            if spanToSec > 1{
                                date = "\(spanToSec) seconds ago"
                            }else if spanToSec <= 1{
                                date = "1 second ago"
                            }
                        }
                    }
                    
                    cell.timeLabel.text = date
                    cell.likeCountLabel.text = "\(commentArray[indexPath.row - 2].commentLikeCount)"
                    if 0 < commentArray[indexPath.row - 2].commentLikeCount{
                        cell.likeTextLabel.text = "likes"
                    }else{
                        cell.likeTextLabel.text = "like"
                    }
                    return cell
                }
            }
        }
    }
}

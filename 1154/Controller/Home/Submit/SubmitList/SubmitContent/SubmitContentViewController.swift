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

class SubmitContentViewController: UIViewController, PhotoCellDelegate, UITextFieldDelegate, TitleCellDelegate, CommentCellDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentMainView: UIView!
    @IBOutlet weak var commentMainViewBottom: NSLayoutConstraint!
    @IBOutlet weak var commentPostView: UIView!
    @IBOutlet weak var commentProfileImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentPostButton: UIButton!
    @IBOutlet weak var replyingBar: UIView!
    @IBOutlet weak var replyingBarCancel: UIView!
    @IBOutlet weak var replyingBarLabel: UILabel!
    @IBOutlet weak var commentMention: UILabel!
    
    private var userModel: UserModel?
    private var submitModel: SubmitModel?
    private var submitUserModel: UserModel?
    private var uid: String?
    private var commentArray: [CommentModel] = []
    private var mainCommentArray: [CommentModel] = []
    private var subCommentArray: [CommentModel] = []
    private var tap = UITapGestureRecognizer()
    private var spanArray: [TimeInterval] = []
    private var refreshControl : UIRefreshControl?
    private var viewsCount: Int?
    private var likesCount: Int?
    private var commentsCount: Int?
    private var cellHeight = [IndexPath: CGFloat]()
    private var isViews = true
    private var to = ""
    private var parentId: String?
    private var isSubComment = false
    private var isPost = false
    private var postId: String?
    private var isAddIndicator = false
    var isBookmark = false
    var fromProfile = false
    var model: SubmitModel?{
        didSet{
            if isViews{
                
                increaseViews()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitUserDataLoad()
        configureViewOption()
        addGesture()
        tableViewCellRegist()
        addRefresh()
        addKeyboardObserver()
        userDataLoad()
        commentDataLoad()
        countObserver()
        submitLikeObserver()
        commentCountObserver()
        ViewsObserver()
        tableView.alpha = 0
        
        
    }
    
    override func viewDidLayoutSubviews() {
        if !isAddIndicator{
            ActivityIndicator.shared.addIndicator(view: self.view)
            ActivityIndicator.shared.start(view: tableView)
            isAddIndicator = true
        }
    }
    
    func activityIndicatorStop() {
        ActivityIndicator.shared.stop(view: tableView)
    }
    
    func presentSubmitUserProfile() {
        if let navView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewNavController") as? UINavigationController{
            if !navView.viewControllers.isEmpty, let pro = navView.viewControllers[0] as? ProfileViewController {
                pro.userModel = self.submitUserModel
            }
            self.present(navView, animated: true, completion: nil)
        }
    }
    
    
    func setIsLike(isLike: Bool, indexPath: Int) {
        if !commentArray.isEmpty {
            commentArray[indexPath].isLike = isLike
        }
    }
    
    func showReplyingBar(name: String, uid: String, commentId: String){
        isSubComment = true
        self.parentId = commentId
        if uid == self.uid{
            replyingBarLabel.text = "Replying to my comment"
            commentMention.text = ""
        }else{
            replyingBarLabel.text = "Replying to \(name)"
            commentMention.text = "@\(name) "
            to = uid
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        replyingBar.isHidden = false
        commentTextField.becomeFirstResponder()
    }
    
    
    func showDeleteAlert(submitId: String, commentId: String, parentId: String, isSubComment: Bool) {
        let alert: UIAlertController = UIAlertController(title: "", message: "Do you want to delete this comment?", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            DispatchQueue.global().async {
                var reference: DocumentReference?
                if isSubComment{
                    reference = Firestore.firestore().collection("submit").document(submitId).collection("comment").document(parentId).collection("subComment").document(commentId)
                }else{
                    reference = Firestore.firestore().collection("submit").document(submitId).collection("comment").document(commentId)
                }
                guard let documentReference = reference else {return}
                documentReference.updateData(["delete" : true]) { (error) in
                    if error != nil{
                    }else{
                        self.commentDataLoad()
                    }
                }
                Firestore.firestore().collection("commentCount").document(submitId).collection("commentList").document(commentId).delete()
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
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addRefresh(){
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        self.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func addGesture(){
        tap = UITapGestureRecognizer(target: self, action: #selector(keyboardHide(_:)))
        tap.isEnabled = false
        tableView.addGestureRecognizer(tap)
        
        replyingBarCancel.isUserInteractionEnabled = true
        let cancel = UITapGestureRecognizer(target: self, action: #selector(replyingBarCancelEvent))
        replyingBarCancel.addGestureRecognizer(cancel)
    }
    
    func tableViewCellRegist(){
        tableView.register(UINib(nibName: "titleCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        tableView.register(UINib(nibName: "photoCell", bundle: nil), forCellReuseIdentifier: "photoCell")
        tableView.register(UINib(nibName: "contentCell", bundle: nil), forCellReuseIdentifier: "contentCell")
        tableView.register(UINib(nibName: "commentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
    }
    
    func configureViewOption(){
        commentPostView.layer.borderWidth = 1
        commentPostView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        commentPostView.layer.cornerRadius = commentPostView.frame.height / 2
        
        commentProfileImageView.layer.cornerRadius = commentProfileImageView.frame.width / 2
        commentProfileImageView.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = true
        tableView.rowHeight = UITableView.automaticDimension
        
        commentTextField.delegate = self
        commentPostButton.isEnabled = false
    }
    
    func submitUserDataLoad(){
        DispatchQueue.global().async {
            guard let uid = self.model?.uid else {return}
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil{
                }else{
                    do{
                        guard let snapshot = snapshot?.data() else {return}
                        self.submitUserModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot)
                        self.tableView.reloadData()
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc func replyingBarCancelEvent(){
        isSubComment = false
        to = ""
        parentId = nil
        commentMention.text = ""
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        replyingBar.isHidden = true
        commentTextField.resignFirstResponder()
    }
    
    func increaseViews(){
        DispatchQueue.global().async {
            self.isViews = false
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).collection("views").getDocuments { (snapshot, error) in
                if error != nil{
                    print("error")
                }else{
                    let viewsId = UUID.init().uuidString
                    let viewsModel = IdDateModel(id: viewsId, date: SharedFunction.shared.getToday())
                    guard let data = try? FirestoreEncoder().encode(viewsModel) else {return}
                    Firestore.firestore().collection("submit").document(id).collection("views").document(viewsId).setData(data, completion: { (error) in
                        if error != nil{
                        }else{
                        }
                    })
                }
            }
        }
    }
    
    func countObserver(){
        guard let id = self.model?.id else {return}
        DispatchQueue.global().async {
            Firestore.firestore().collection("submit").document(id).addSnapshotListener({ (snapshot, error) in
                guard let snapshot = snapshot, let data = snapshot.data() else {return}
                if error != nil{
                }else{
                    do{
                        self.submitModel = try? FirestoreDecoder().decode(SubmitModel.self, from: data)
                        self.viewsCount = self.submitModel?.viewsCount
                        self.likesCount = self.submitModel?.likeCount
                        self.commentsCount = self.submitModel?.commentCount
                        
                        self.countRefresh()
                    }
                }
            })
        }
    }
    
    func submitLikeObserver(){
        DispatchQueue.global().async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).collection("like").addSnapshotListener({ (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot else {return}
                    Firestore.firestore().collection("submit").document(id).updateData(["likeCount" : snapshot.documents.count])
                }
            })
        }
    }
    
    func commentCountObserver(){
        DispatchQueue.global().async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submitCommentCount").document(id).collection("commentList").addSnapshotListener({ (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot else {return}
                    Firestore.firestore().collection("submit").document(id).updateData(["commentCount" : snapshot.documents.count])
                }
            })
        }
    }
    
    func ViewsObserver(){
        DispatchQueue.global().async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).collection("views").addSnapshotListener({ (snapshot, error) in
                if error != nil{
                }else{
                    guard let snapshot = snapshot else {return}
                    Firestore.firestore().collection("submit").document(id).updateData(["viewsCount" : snapshot.documents.count])
                }
            })
        }
    }
    
    func countRefresh(){
        DispatchQueue.global().async {
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
        DispatchQueue.global().async {
            self.increaseViews()
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
                            self.commentProfileImageView.alpha = 0
                            self.commentProfileImageView.kf.setImage(with: URL(string: profileImage))
                            UIView.animate(withDuration: 0.2, animations: {
                                self.commentProfileImageView.alpha = 1
                            })
                        }else{
                            self.commentProfileImageView.alpha = 0
                            self.commentProfileImageView.image = UIImage(named: "defaultprofile")
                            UIView.animate(withDuration: 0.2, animations: {
                                self.commentProfileImageView.alpha = 1
                            })
                        }
                    }
                }
            })
        }
    }
    
    func commentDataLoad(){
        DispatchQueue.global().async {
            guard let id = self.model?.id else {return}
            Firestore.firestore().collection("submit").document(id).collection("comment").order(by: "date", descending: false).getDocuments(completion: { (snapshot, error) in
                if error != nil{
                }else{
                    self.commentArray.removeAll()
                    self.mainCommentArray.removeAll()
                    self.subCommentArray.removeAll()
                    self.spanArray.removeAll()
                    guard let snapshot = snapshot else {return}
                    if snapshot.isEmpty{
                        self.refreshControl?.endRefreshing()
                        ActivityIndicator.shared.stop(view: self.tableView)
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                    }
                    var count = 0
                    
                    for document in snapshot.documents{
                        guard let model = try? FirestoreDecoder().decode(CommentModel.self, from: document.data()) else {return}
                        self.mainCommentArray.append(model)
                        
                        Firestore.firestore().collection("submit").document(id).collection("comment").document(model.id).collection("subComment").order(by: "date", descending: false).getDocuments(completion: { (snapshot, error) in
                            if error != nil{
                            }else{
                                guard let snapshot = snapshot else { return }
                                
                                var subCommentArrayTemp = [CommentModel]()
                                
                                for document in snapshot.documents{
                                    do {
                                        let model = try? FirestoreDecoder().decode(CommentModel.self, from: document.data())
                                        guard let commentModel = model else {return}

                                        subCommentArrayTemp.append(commentModel)

                                        if snapshot.documents.count == subCommentArrayTemp.count {
                                            count = count + 1
                                            
                                            for subCommentTemp in subCommentArrayTemp {
                                                self.subCommentArray.append(subCommentTemp)
                                            }

                                            if count == self.mainCommentArray.count {
                                                self.commentReplace()
                                            }
                                        }
                                    } catch let error {
                                        print(error.localizedDescription)
                                    }
                                }

                                if snapshot.documents.isEmpty {
                                    count = count + 1

                                    if count == self.mainCommentArray.count {
                                        self.commentReplace()
                                    }
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    func commentReplace(){
        for (index, _) in self.mainCommentArray.enumerated(){
            self.commentArray.append(self.mainCommentArray[index])
            for(subIndex, _) in self.subCommentArray.enumerated(){
                if self.mainCommentArray[index].id == self.subCommentArray[subIndex].parentId{
                    self.commentArray.append(self.subCommentArray[subIndex])
                }
            }
        }
        commentTimeSpan()
    }
    
    func commentTimeSpan(){
        if self.commentArray.count == 0{
            self.refreshControl?.endRefreshing()
        }
        for (index, _) in self.commentArray.enumerated() {
            let wrritenDate = SharedFunction.shared.dateFromString(string: self.commentArray[index].date)
            let nowDate = SharedFunction.shared.dateFromString(string: SharedFunction.shared.getToday())
            let span = nowDate.timeIntervalSince(wrritenDate)
            self.spanArray.append(span)
            
            DispatchQueue.main.async {
                if index + 1 == self.spanArray.count {
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    
                    self.refreshControl?.endRefreshing()
                    if self.isPost{
                        self.scrollToPost()
                        self.isPost = false
                    }
                }
            }
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
        replyingBarCancelEvent()
    }

    func commentCountCollectionUpdate(id: String){
        DispatchQueue.global().async {
            guard let submitId = self.model?.id, let uid = self.uid else {return}
            Firestore.firestore().collection("submitCommentCount").document(submitId).collection("commentList").document(id).setData(["id" : id])
            
            Firestore.firestore().collection("users").document(uid).collection("comment").document(id).setData(["submitId" : submitId])
        }
    }
    
    @IBAction func commentPostButtonEvent(_ sender: Any) {
        commentPostButton.isEnabled = false
        self.commentPostButton.setTitleColor(UIColor(red: 218/255, green: 66/255, blue: 103/255, alpha: 0.2), for: .normal)
        self.commentTextField.resignFirstResponder()
        guard let uid = self.uid,
            let comment = self.commentTextField.text else {return}
        self.commentTextField.text = ""
        DispatchQueue.global().async {
            
            guard let id = self.model?.id else {return}
            let documentReference: DocumentReference?
            let data: [String : Any]?
            var countId: String?
            if !self.isSubComment{
                let commentId = UUID.init().uuidString
                countId = commentId
                documentReference = Firestore.firestore().collection("submit").document(id).collection("comment").document(commentId)
                let commentModel = CommentModel(uid: uid, date: SharedFunction.shared.getToday(), comment: comment, commentLikeCount: 0, to: self.to, id: commentId, isSubComment: self.isSubComment, delete: false, isLike: nil, parentId: self.parentId)
                data = try? FirestoreEncoder().encode(commentModel)
            }else{
                let subCommentId = UUID.init().uuidString
                countId = subCommentId
                guard let parentId = self.parentId else {return}
                documentReference = Firestore.firestore().collection("submit").document(id).collection("comment").document(parentId).collection("subComment").document(subCommentId)
                let commentModel = CommentModel(uid: uid, date: SharedFunction.shared.getToday(), comment: comment, commentLikeCount: 0, to: self.to, id: subCommentId, isSubComment: self.isSubComment, delete: false, isLike: nil, parentId: self.parentId)
                data = try? FirestoreEncoder().encode(commentModel)
            }
            guard let commentCountId = countId else {return}
            self.postId = commentCountId
            self.commentCountCollectionUpdate(id: commentCountId)
            
            guard let reference = documentReference, let commentData = data else {return}
            reference.setData(commentData) { (error) in
                if error != nil{
                }else{
                    if self.replyingBar.isHidden == false {
                        self.replyingBarCancelEvent()
                    }
                    self.commentDataLoad()
                    self.isPost = true
                }
            }
        }
    }

    func scrollToPost(){
        DispatchQueue.main.async {
            var scrollIndex = 0
            for (index, _) in self.commentArray.enumerated(){
                if self.commentArray[index].id == self.postId{
                    scrollIndex = index
                }
            }
            if (self.model?.imageUrl) != nil{
                scrollIndex += 3
            }else{
                scrollIndex += 2
            }
            
            let indexPath = IndexPath(row: scrollIndex, section: 0)
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeight[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.cellHeight[indexPath] {
            return height
        } else {
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = model else {return 0}

        if model.imageUrl != nil {
            return commentArray.count + 3
        } else {
            return commentArray.count + 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = model, let submitUserModel = self.submitUserModel else {return UITableViewCell()}
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            cell.titleCellDelegate = self
            
            
            cell.presentIsBookmark = self.isBookmark
            if self.fromProfile{
                cell.profileImageView.isUserInteractionEnabled = false
                cell.nameLabel.isUserInteractionEnabled = false
            }else{
                cell.profileImageView.isUserInteractionEnabled = true
                cell.nameLabel.isUserInteractionEnabled = true
            }
            
            if submitUserModel.profileImageUrl != nil {
                if let imageUrl = submitUserModel.profileImageUrl{
                    cell.profileImageView.kf.setImage(with: URL(string: imageUrl))
                }
            }else{
                cell.profileImageView.image = UIImage(named: "defaultprofile")
            }
            if model.uid == self.uid{
                cell.likeButtonView.isHidden = true
            }else{
                cell.likeButtonView.isHidden = false
            }
            cell.nameLabel.text = submitUserModel.name
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
                    if !commentArray.isEmpty{
                        cell.commentCellDelegate = self
                        cell.submitId = model.id
                        cell.submitUid = model.uid
                        cell.commentUid = commentArray[indexPath.row - 3].uid
                        cell.indexPath = indexPath.row - 3
                        cell.isSubComment = commentArray[indexPath.row - 3].isSubComment
                        cell.parentId = commentArray[indexPath.row - 3].parentId
                        cell.isLiked = commentArray[indexPath.row - 3].isLike
                        cell.commentId = commentArray[indexPath.row - 3].id
                        cell.to = commentArray[indexPath.row - 3].to
                        if commentArray[indexPath.row - 3].isSubComment{
                            cell.profileImageViewWidth.constant = 20
                            cell.profileImageViewHeight.constant = 20
                            cell.mainViewLeading.constant = +30
                            cell.mentionLabel.isHidden = false
                            if commentArray[indexPath.row - 3].to == ""{
                                cell.mentionLabel.isHidden = true
                            }else if commentArray[indexPath.row - 3].delete{
                                cell.mentionLabel.isHidden = true
                            }
                            
                        }else{
                            cell.profileImageViewWidth.constant = 25
                            cell.profileImageViewHeight.constant = 25
                            cell.mainViewLeading.constant = 0
                            cell.mentionLabel.isHidden = true
                        }
                        
                        if commentArray[indexPath.row - 3].delete{
                            cell.commentLabel.text = "This comment has been deleted."
                            cell.commentLabel.textColor = UIColor.lightGray
                            cell.likeButtonView.isHidden = true
                            cell.deleteButtonView.isHidden = true
                            cell.replyButtonView.isHidden = true
                        }else{
                            cell.commentLabel.text = commentArray[indexPath.row - 3].comment
                            cell.commentLabel.textColor = UIColor.black
                            cell.replyButtonView.isHidden = false
                            if uid == commentArray[indexPath.row - 3].uid{
                                cell.deleteButtonView.isHidden = false
                                cell.likeButtonView.isHidden = true
                            }else{
                                cell.deleteButtonView.isHidden = true
                                cell.likeButtonView.isHidden = false
                            }
                        }
                        
                        var date = ""
                        if !spanArray.isEmpty{
                            let span = spanArray[indexPath.row - 3]
                            if span > 2592000{
                                date = SharedFunction.shared.getCurrentLocaleDateFromString(string: commentArray[indexPath.row - 3].date, format: "yyyy.MM.dd  HH:mm")
                            }else{
                                date = spanCalc(span: span)
                            }
                        }
                        
                        cell.timeLabel.text = date
                        cell.likeCountLabel.text = "\(commentArray[indexPath.row - 3].commentLikeCount)"
                        if 1 < commentArray[indexPath.row - 3].commentLikeCount{
                            cell.likeTextLabel.text = "likes"
                        }else{
                            cell.likeTextLabel.text = "like"
                        }
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
                    if !commentArray.isEmpty{
                        cell.commentCellDelegate = self
                        cell.submitId = model.id
                        cell.submitUid = model.uid
                        cell.commentUid = commentArray[indexPath.row - 2].uid
                        cell.indexPath = indexPath.row - 2
                        cell.isSubComment = commentArray[indexPath.row - 2].isSubComment
                        cell.parentId = commentArray[indexPath.row - 2].parentId
                        cell.isLiked = commentArray[indexPath.row - 2].isLike
                        cell.commentId = commentArray[indexPath.row - 2].id
                        cell.to = commentArray[indexPath.row - 2].to
                        if commentArray[indexPath.row - 2].isSubComment{
                            cell.profileImageViewWidth.constant = 20
                            cell.profileImageViewHeight.constant = 20
                            cell.mainViewLeading.constant = +30
                            cell.mentionLabel.isHidden = false
                            if commentArray[indexPath.row - 2].to == ""{
                                cell.mentionLabel.isHidden = true
                            }else if commentArray[indexPath.row - 2].delete{
                                cell.mentionLabel.isHidden = true
                            }
                        }else{
                            cell.profileImageViewWidth.constant = 25
                            cell.profileImageViewHeight.constant = 25
                            cell.mainViewLeading.constant = 0
                            cell.mentionLabel.isHidden = true
                        }
                        
                        if commentArray[indexPath.row - 2].delete{
                            cell.commentLabel.text = "This comment has been deleted."
                            cell.commentLabel.textColor = UIColor.lightGray
                            cell.likeButtonView.isHidden = true
                            cell.deleteButtonView.isHidden = true
                            cell.replyButtonView.isHidden = true
                        }else{
                            cell.commentLabel.text = commentArray[indexPath.row - 2].comment
                            cell.commentLabel.textColor = UIColor.black
                            cell.replyButtonView.isHidden = false
                            if uid == commentArray[indexPath.row - 2].uid{
                                cell.deleteButtonView.isHidden = false
                                cell.likeButtonView.isHidden = true
                            }else{
                                cell.deleteButtonView.isHidden = true
                                cell.likeButtonView.isHidden = false
                            }
                        }
                        
                        var date = ""
                        if !spanArray.isEmpty{
                            let span = spanArray[indexPath.row - 2]
                            if span > 2592000{
                                date = SharedFunction.shared.getCurrentLocaleDateFromString(string: commentArray[indexPath.row - 2].date, format: "yyyy.MM.dd  HH:mm")
                            }else{
                                date = spanCalc(span: span)
                            }
                        }
                        
                        cell.timeLabel.text = date
                        cell.likeCountLabel.text = "\(commentArray[indexPath.row - 2].commentLikeCount)"
                        if 1 < commentArray[indexPath.row - 2].commentLikeCount{
                            cell.likeTextLabel.text = "likes"
                        }else{
                            cell.likeTextLabel.text = "like"
                        }
                    }
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let commentCell = cell as? CommentCell {
            commentCell.listener?.remove()
        }
    }
    
    func spanCalc(span: TimeInterval) -> String{
        if 1 <= span / 604800{
            let spanToWeek = Int(span / 604800)
            if spanToWeek > 1{
                return "\(spanToWeek) weeks ago"
            }else{
                return "\(spanToWeek) week ago"
            }
        }else if 1 <= span / 86400{
            let spanToDay = Int(span / 86400)
            if spanToDay > 1{
                return "\(spanToDay) days ago"
            }else{
                return "\(spanToDay) day ago"
            }
        }else if 1 <= span / 3600{
            let spanToHour = Int(span / 3600)
            if spanToHour > 1{
                return "\(spanToHour) hours ago"
            }else{
                return "\(spanToHour) hour ago"
            }
        }else if 1 <= span / 60{
            let spanToMin = Int(span / 60)
            if spanToMin > 1{
                return "\(spanToMin) minutes ago"
            }else{
                return "\(spanToMin) minute ago"
            }
        }else if span < 60{
            let spanToSec = Int(span)
            if spanToSec > 1{
                return "\(spanToSec) seconds ago"
            }else if spanToSec <= 1{
                return "1 second ago"
            }
        }
        return ""
    }
}

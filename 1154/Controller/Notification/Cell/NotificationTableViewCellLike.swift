//
//  NotificationTableViewCellLike.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 18..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

protocol NotificationTableViewCellLikeDelegate {
    func refreshEnd()
    func activityIndicatorStop()
    func tapMainCell(submitId: String, type : String, commentId: String)
    func tapProfileCell(uid : String)
}

class NotificationTableViewCellLike: UITableViewCell {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var fromUid: String?
    
    
    var notificationTableViewCellLikeDelegate : NotificationTableViewCellLikeDelegate?
    var submitId: String?
    var type: String?
    var commentId: String?
    var date: String?
    var content: String?
    var uid: String?{
        didSet{
            if let uid = self.uid{
                loadUserData(uid: uid)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViewOption()
        addGesture()
    }
    
    func configureViewOption(){
        mainView.layer.cornerRadius = 5
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }
    
    func addGesture(){
        let tapMainGesture = UITapGestureRecognizer(target: self, action: #selector(tapMainEvent))
        mainView.addGestureRecognizer(tapMainGesture)
        mainView.isUserInteractionEnabled = true
        
        let tapProfileGesgure = UITapGestureRecognizer(target: self, action: #selector(tapProfileEvent))
        profileView.addGestureRecognizer(tapProfileGesgure)
        profileView.isUserInteractionEnabled = true
    }
    
    @objc func tapMainEvent(){
        guard let submitId = self.submitId, let type = self.type, let commentId = self.commentId else {return}
        notificationTableViewCellLikeDelegate?.tapMainCell(submitId: submitId, type: type, commentId: commentId)
    }
    
    @objc func tapProfileEvent(){
        guard let uid = self.fromUid else {return}
        notificationTableViewCellLikeDelegate?.tapProfileCell(uid: uid)
    }
    
    func loadUserData(uid: String){
        guard let date = self.date, let content = self.content else {return}
        DispatchQueue.global().async {
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil {
                }else{
                    do{
                        guard let snapshot = snapshot?.data(),
                            let userModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot) else {return}
                        self.fromUid = userModel.uid
                        let contextText = "\(userModel.name) \(content)" as NSString
                        let range = contextText.range(of: userModel.name)
                        let repliedRange = contextText.range(of: "replied")
                        let likedRange = contextText.range(of: "liked")
                        let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light)]
                        let attrString = NSMutableAttributedString(string: contextText as String, attributes: attrs)
                        let attrsChange = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)]
                        let attrsReplied = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular),NSAttributedString.Key.foregroundColor: UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1) /* #134563 */]
                        let attrsLiked = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular),NSAttributedString.Key.foregroundColor: UIColor(red: 218/255, green: 65/255, blue: 103/255, alpha: 1.0) /* #da4167 */]
                        attrString.addAttributes(attrsChange, range: range)
                        attrString.addAttributes(attrsReplied, range: repliedRange)
                        attrString.addAttributes(attrsLiked, range: likedRange)
                        self.contentLabel.attributedText = attrString
                
                        let notifiDate = SharedFunction.shared.dateFromString(string: date)
                        let nowDate = SharedFunction.shared.dateFromString(string: SharedFunction.shared.getToday())
                        let span = nowDate.timeIntervalSince(notifiDate)
                        self.dateLabel.text = self.spanCalc(span: span)
                        
                        if userModel.profileImageUrl != nil{
                            guard let imageUrl = userModel.profileImageUrl else {return}
                            DispatchQueue.main.async {
                                self.profileImageView.alpha = 0
                                self.profileImageView.kf.setImage(with: URL(string: imageUrl)) { result in
                                    switch result {
                                    case .success( _):
                                        UIView.animate(withDuration: 0.2, animations: {
                                            self.profileImageView.alpha = 1
                                        })
                                        self.notificationTableViewCellLikeDelegate?.refreshEnd()
                                        self.notificationTableViewCellLikeDelegate?.activityIndicatorStop()
                                    case .failure(let error):
                                        print(error)
                                        
                                    }
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.profileImageView.alpha = 0
                                self.profileImageView.image = UIImage(named: "defaultprofile")
                                
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.profileImageView.alpha = 1
                                })
                                self.notificationTableViewCellLikeDelegate?.refreshEnd()
                                self.notificationTableViewCellLikeDelegate?.activityIndicatorStop()
                            }
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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

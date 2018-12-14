//
//  SubmitViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 6..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth

class SubmitViewController: UIViewController {
    @IBOutlet weak var categoryK: UIView!
    @IBOutlet weak var categoryJ: UIView!
    @IBOutlet weak var categoryFree: UIView!
    @IBOutlet weak var categoryTrevel: UIView!
    @IBOutlet weak var categoryFood: UIView!
    @IBOutlet weak var categoryShopping: UIView!
    @IBOutlet weak var submitTitle: UITextField!
    @IBOutlet weak var submitContent: PlaceHolderTextView!
    @IBOutlet weak var submitContentBottom: NSLayoutConstraint!
    private let changedColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1.0)
    private let baseColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    private var country: String = ""
    private var category: String = ""
    private var isLoading : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let category = [categoryK,categoryJ,categoryFree,categoryTrevel,categoryFood,categoryShopping]
        for (index, item) in category.enumerated() {
            item?.layer.cornerRadius = categoryK.frame.height / 2.1
            item?.backgroundColor = baseColor
            item?.isUserInteractionEnabled = true
            item?.tag = index
            item?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapEvent(_:))))
        }
        
        submitTitle.setValue(baseColor, forKeyPath: "_placeholderLabel.textColor")
        submitTitle.becomeFirstResponder()
        submitTitle.layer.borderColor = baseColor.cgColor
        submitContent.layer.cornerRadius = 5
        submitContent.layer.borderWidth = 1
        submitContent.layer.borderColor = baseColor.cgColor
        submitContent.placeHolder = "Content"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            submitContentBottom.constant = 8
            submitContentBottom.constant += (keyboardSize.height)
        }
    }
    
    @objc func tapEvent(_ sender: UITapGestureRecognizer){
        if sender.view?.backgroundColor == baseColor{
            sender.view?.backgroundColor = changedColor
        }
        if sender.view?.tag == 0 {
            categoryJ.backgroundColor = baseColor
            country = "korea"
        }else if sender.view?.tag == 1{
            categoryK.backgroundColor = baseColor
            country = "japan"
        }else if sender.view?.tag == 2{
            categoryTrevel.backgroundColor = baseColor
            categoryFood.backgroundColor = baseColor
            categoryShopping.backgroundColor = baseColor
            category = "free"
        }else if sender.view?.tag == 3{
            categoryFree.backgroundColor = baseColor
            categoryFood.backgroundColor = baseColor
            categoryShopping.backgroundColor = baseColor
            category = "trevel"
        }else if sender.view?.tag == 4{
            categoryFree.backgroundColor = baseColor
            categoryTrevel.backgroundColor = baseColor
            categoryShopping.backgroundColor = baseColor
            category = "food"
        }else if sender.view?.tag == 5{
            categoryFree.backgroundColor = baseColor
            categoryTrevel.backgroundColor = baseColor
            categoryFood.backgroundColor = baseColor
            category = "shopping"
        }
    }
    
    @IBAction func backEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitEvent(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        
        if !isLoading{
            DispatchQueue.global().async {
                self.isLoading = true
                Firestore.firestore().collection("users").document(uid ?? "").getDocument { (snapshot, error) in
                    if error != nil{
                         self.isLoading = false
                    }else{
                        guard let snapshot = snapshot, let data = snapshot.data() else { return }
                        do {
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                            let time = formatter.string(from: Date())
                            
                            let userModel = try? FirestoreDecoder().decode(UserModel.self, from: data)
                            let title = self.submitTitle.text ?? ""
                            let content = self.submitContent.text ?? ""
                            let id = UUID.init().uuidString
                            let name = userModel?.name
                            let submit = SubmitModel(id: id, name: name ?? "", title: title, time: time, content: content, country: self.country ?? "", category: self.category ?? "", commentCount: 0, likeCount: 0, viewsCount: 0)
                            let data = try! FirestoreEncoder().encode(submit)
                            if !title .isEmpty && !content .isEmpty && self.country != "" && self.category != ""{
                                Firestore.firestore().collection("submit").document(id).setData(data, completion: { (err) in
                                    if err != nil{
                                    }else{
                                        self.dismiss(animated: true, completion: nil)
                                        self.isLoading = false
                                        
                                    }
                                })
                            }
                        }catch let error {
                         self.isLoading = false
                        }
                    }
                }
            }
        }
        
    }
}

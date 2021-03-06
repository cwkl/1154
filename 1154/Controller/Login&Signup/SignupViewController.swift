//
//  SignupViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 11. 27..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import CodableFirebase
import InstantSearchClient

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var signup_edtEmail: UITextField!
    @IBOutlet weak var signup_edtName: UITextField!
    @IBOutlet weak var signup_edtPassword: UITextField!
    @IBOutlet weak var signup_signup: UIButton!
    @IBOutlet weak var signup_cancle: UIButton!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    private var isAddIndicator = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        signup_signup.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        signup_cancle.addTarget(self, action: #selector(cancleEvent), for: .touchUpInside)
        signup_signup.layer.cornerRadius = 5
        signup_cancle.layer.cornerRadius = 5
        
        signup_edtName.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        if scrollViewBottom.constant == 0{
            scrollViewBottom.constant -= keyboardSize.height
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded()
        })
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollViewBottom.constant != 0{
                scrollViewBottom.constant = 0
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @objc func cancleEvent(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func viewTapped(){
        signup_edtEmail.resignFirstResponder()
        signup_edtName.resignFirstResponder()
        signup_edtPassword.resignFirstResponder()
    }
    
    private func pushDataAlgolia(data: [String: AnyObject]) {
        
        var index: Index?
        
        index = SessionManager.shared.client.index(withName: "user")
        
        var newData = data
        if let objectId = data["uid"] {
            newData.updateValue(objectId, forKey: "objectID")
        }
        
        DispatchQueue.global().async {
            index?.addObject(newData, completionHandler: { (content, error) -> Void in
                if error == nil {
                    print("Object IDs: \(content!)")
                }
            })
        }
    }
    
    func startIndicator() {
        if !isAddIndicator{
            UIView.animate(withDuration: 0.5) {
                self.mainView.alpha = 0
            }
            ActivityIndicator.shared.addIndicator(view: self.view)
            ActivityIndicator.shared.start(view: mainView)
            isAddIndicator = true
        }
    }
    
    func activityIndicatorStop() {
        ActivityIndicator.shared.stop(view: mainView)
        isAddIndicator = false
    }
    
    @objc func signupEvent(){
        startIndicator()
        signup_edtName.resignFirstResponder()
        signup_edtEmail.resignFirstResponder()
        signup_edtPassword.resignFirstResponder()
        let db = Firestore.firestore()
        let email = signup_edtEmail.text!
        let name = signup_edtName.text!
        let password = signup_edtPassword.text!
        Auth.auth().createUser(withEmail: email, password: password){ (user, err) in
            if err != nil{
                self.activityIndicatorStop()
                let alert = UIAlertController(title: "Invalid ID and password", message: nil, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        
            guard let uid = Auth.auth().currentUser?.uid, let fcmToken = UserDefaults.standard.string(forKey: "FCM_TOKEN") else {return}
            
            let userModel = UserModel(email: email, name: name, uid: uid, profileImageUrl: nil, startDate: SharedFunction.shared.getToday(), region: nil, fcmToken: fcmToken, notificationExist: false)
            guard let data = try? FirestoreEncoder().encode(userModel) else {return}
            db.collection("users").document(uid).setData(data, completion: { (err) in
                if err != nil{
                }else{
                    self.pushDataAlgolia(data: data as [String : AnyObject])
                }
            })
        }
    }
}

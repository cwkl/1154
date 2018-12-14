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

class SignupViewController: UIViewController {
    @IBOutlet weak var signup_edtEmail: UITextField!
    @IBOutlet weak var signup_edtName: UITextField!
    @IBOutlet weak var signup_edtPassword: UITextField!
    @IBOutlet weak var signup_signup: UIButton!
    @IBOutlet weak var signup_cancle: UIButton!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        signup_signup.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        signup_cancle.addTarget(self, action: #selector(cancleEvent), for: .touchUpInside)
        signup_signup.layer.cornerRadius = 5
        signup_cancle.layer.cornerRadius = 5
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollViewBottom.constant == 0{
                scrollViewBottom.constant -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollViewBottom.constant != 0{
                scrollViewBottom.constant = 0
            }
        }
    }
    
    @objc func cancleEvent(){
        self.dismiss(animated: true)
    }
    
    @objc func viewTapped(){
        signup_edtEmail.resignFirstResponder()
        signup_edtName.resignFirstResponder()
        signup_edtPassword.resignFirstResponder()
    }
    
    @objc func signupEvent(){
        let db = Firestore.firestore()
        let email = signup_edtEmail.text!
        let name = signup_edtName.text!
        let password = signup_edtPassword.text!
        Auth.auth().createUser(withEmail: email, password: password){ (user, err) in
            if err != nil{
                return
            }
        
            let uid = Auth.auth().currentUser?.uid
            db.collection("users").document(uid!).setData(["email": email, "name": name], completion: { (err) in
                if err != nil{
                }else{
                    if let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as? UITabBarController{
                        self.present(view , animated: true, completion: nil)
                    }
                }
            })
        }
    }
}
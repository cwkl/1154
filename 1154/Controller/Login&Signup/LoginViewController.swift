//
//  LoginViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 11. 26..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var login_edtId: UITextField!
    @IBOutlet weak var login_edtPassword: UITextField!
    @IBOutlet weak var login_loginBtn: UIButton!
    @IBOutlet weak var login_signupBtn: UIButton!
    @IBOutlet weak var login_cancelBtn: UIButton!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        login_signupBtn.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        login_loginBtn.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        login_cancelBtn.addTarget(self, action: #selector(backEvent), for: .touchUpInside)
        
        login_signupBtn.layer.cornerRadius = 5
        login_loginBtn.layer.cornerRadius = 5
        login_cancelBtn.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        Auth.auth().addStateDidChangeListener { (Auth, User) in
            if User != nil{
                NotificationManager.postMainUserReload()
                NotificationManager.postSideUserReload()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func backEvent(){
        NotificationManager.postMainUserReload()
        NotificationManager.postSideUserReload()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func loginEvent(){
        guard let loginEdtIdText = login_edtId.text,
            let loginEdtPasswordText = login_edtPassword.text else { return }
        
        if !loginEdtIdText.isEmpty && !loginEdtPasswordText.isEmpty {
            Auth.auth().signIn(withEmail: login_edtId.text!, password: login_edtPassword.text!) { (result, err) in
                if err != nil{
                    let alert = UIAlertController(title: "Invalid ID and password", message: nil, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
        
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        scrollViewBottom.constant = keyboardSize.height
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded()
            self.scrollView.contentOffset.y = 100
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollViewBottom.constant != 0 {
                scrollViewBottom.constant = 0
                self.scrollView.contentOffset.y = 0
            }
        }
    }
    
    @objc func viewTapped(){
        login_edtId.resignFirstResponder()
        login_edtPassword.resignFirstResponder()
    }
    
    @objc func presentSignup(){
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController{
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
}

//
//  SearchViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 11..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import SideMenuSwift
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class SearchViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var barProfileImageView: UIImageView!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelButtonView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    private var keyboardHideGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userDateLoad()
        configureViewOption()
        addGesture()
        notificationReceive()
    }
    
    func configureViewOption(){
        barProfileImageView.layer.cornerRadius = barProfileImageView.frame.height / 2
        barProfileImageView.layer.masksToBounds = true
        textFieldView.layer.cornerRadius = textFieldView.frame.height / 2
        textField.delegate = self
        self.cancelButton.isEnabled = false
    }
    
    func addGesture(){
        let barImageGesture = UITapGestureRecognizer(target: self, action: #selector(barImageButtonEvent))
        barProfileImageView.addGestureRecognizer(barImageGesture)
        barProfileImageView.isUserInteractionEnabled = true
        
        keyboardHideGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardHide))
        self.keyboardHideGesture.isEnabled = false
        self.view.addGestureRecognizer(self.keyboardHideGesture)
        
    }
    
    func notificationReceive(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationManager.receive(mainUserReload: self, selector: #selector(mainUserLoadNotificaiton))
    }
    
    @objc func keyboardHide(){
        textField.resignFirstResponder()
    }
    
    @objc func mainUserLoadNotificaiton(){
        userDateLoad()
    }
    
    @objc func barImageButtonEvent(){
        self.sideMenuController?.revealMenu()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardHideGesture.isEnabled = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyboardHideGesture.isEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let textCount = textField.text?.count else {return}
            if textCount > 0{
                self.cancelButton.setTitleColor(UIColor(red: 218/255, green: 65/255, blue: 103/255, alpha: 1.0), for: .normal)
                self.cancelButton.isEnabled = true
            }else{
                self.cancelButton.setTitleColor(UIColor(red: 218/255, green: 65/255, blue: 103/255, alpha: 0.2), for: .normal)
                self.cancelButton.isEnabled = false
            }
        }
        return true
    }
    
    func userDateLoad(){
        DispatchQueue.global().async {
            guard let uid = Auth.auth().currentUser?.uid
                else {
                    DispatchQueue.main.async {
                        self.barProfileImageView.image = UIImage(named: "defaultprofile")
                    }
                    return
            }
            
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil {
                }else{
                    do{
                        guard let snapshot = snapshot?.data(),
                            let userModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot) else {return}
                        
                        if userModel.profileImageUrl != nil{
                            guard let imageUrl = userModel.profileImageUrl else {return}
                            DispatchQueue.main.async {
                                self.barProfileImageView.alpha = 0
                                self.barProfileImageView.kf.setImage(with: URL(string: imageUrl)) { result in
                                    switch result {
                                    case .success( _):
                                        UIView.animate(withDuration: 0.2, animations: {
                                            self.barProfileImageView.alpha = 1
                                        })
                                    case .failure(let error):
                                        print(error)
                                        
                                    }
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.barProfileImageView.alpha = 0
                                self.barProfileImageView.image = UIImage(named: "defaultprofile")
                                
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.barProfileImageView.alpha = 1
                                })
                            }
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    @IBAction func cancelButtonEvent(_ sender: Any) {
        textField.text = ""
        self.cancelButton.setTitleColor(UIColor(red: 218/255, green: 65/255, blue: 103/255, alpha: 0.2), for: .normal)
        self.cancelButton.isEnabled = false
    }
}

//
//  ProfileViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 3..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import SideMenuSwift
import FirebaseFirestore
import FirebaseAuth
import CodableFirebase
import Gallery
import FirebaseStorage

class ProfileEditViewController: UIViewController, GalleryControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var saveButtonView: UIView!
    @IBOutlet weak var saveButtonLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    private var selectedImage: UIImage?
    private var uid: String?
    private var country: String?
    private var profileImageUrl: String?
    private var photoDataChanged = false
    private var regionDataChanged = false
    private var mainViewGestrue = UITapGestureRecognizer()
    
    var userModel: UserModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        buttonGestureAdd()
        configureViewOption()
        notificationAddObserver()
        setUserData()
    }
    
    func notificationAddObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        mainViewGestrue.isEnabled = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        mainViewGestrue.isEnabled = false
    }
    
    func buttonGestureAdd(){
        let saveGesture = UITapGestureRecognizer(target: self, action: #selector(saveTouchEvent))
        saveButtonView.addGestureRecognizer(saveGesture)
        
        let regionGestrue = UITapGestureRecognizer(target: self, action: #selector(regionTouchEvent))
        regionLabel.addGestureRecognizer(regionGestrue)
        regionLabel.isUserInteractionEnabled = true
        
        let cameraGesture = UITapGestureRecognizer(target: self, action: #selector(cameraTouchEvent))
        cameraButton.addGestureRecognizer(cameraGesture)
        cameraButton.isUserInteractionEnabled = true
        
        mainViewGestrue = UITapGestureRecognizer(target: self, action: #selector(mainViewTouchEvent))
        mainViewGestrue.isEnabled = false
        mainView.addGestureRecognizer(mainViewGestrue)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let text = textField.text, let textCount = textField.text?.count else {return}
            if  self.photoDataChanged || self.regionDataChanged{
                if textCount == 0{
                    self.saveButtonView.isUserInteractionEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }else{
                    self.saveButtonView.isUserInteractionEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }
            }else if !self.photoDataChanged && !self.regionDataChanged{
                if text != self.userModel?.name && textCount != 0{
                    self.saveButtonView.isUserInteractionEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }else{
                    self.saveButtonView.isUserInteractionEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }
            }
        }
        
        let maxLength = 10
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @objc func mainViewTouchEvent(){
        nameTextField.resignFirstResponder()
    }
    
    @objc func saveTouchEvent(){
        saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2) /* #134563 */
        nameCheck()
    }
    
    func nameCheck(){
        if photoDataChanged || regionDataChanged{
            self.userProfileImageUpload()
        }else{
            guard let name = nameTextField.text else {return}
            Firestore.firestore().collection("users").whereField("name", isEqualTo: name).getDocuments { (snapshot, error) in
                if error != nil{
                }else{
                    if snapshot?.count == 0{
                        self.userProfileImageUpload()
                    }else{
                        self.userNameExistAlert()
                    }
                }
            }
        }
    }
    
    func userNameExistAlert(){
        let alert: UIAlertController = UIAlertController(title: "", message: "This name already exists.", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
        })
        
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func userProfileImageUpload(){
        if nameTextField.text != nil{
            DispatchQueue.global().async {
                if self.selectedImage != nil{
                    guard let imageId = self.uid,
                        let resizeImage = self.selectedImage?.resize(size: CGSize(width: 500, height: 500)),
                        let imageJPGE = resizeImage.jpegData(compressionQuality: 0.1) else{return}
                    
                    Storage.storage().reference().child("users/profileImage").child(imageId).putData(imageJPGE, metadata: nil) { (data, error) in
                        if error != nil{
                        }else{
                            Storage.storage().reference().child("users/profileImage").child(imageId).downloadURL(completion: { (url, error) in
                                if error != nil{
                                }else{
                                    guard let url = url?.absoluteString else{return}
                                    DispatchQueue.main.async {
                                        self.userDataUpdate(url: url)
                                    }
                                }
                            })
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.userDataUpdate(url: self.profileImageUrl)
                    }
                }
            }
        }
    }
    
    func userDataUpdate(url: String?){
        guard let uid = self.uid,
            let email = self.userModel?.email,
            let startDate = self.userModel?.startDate,
            let name = self.nameTextField.text else {return}
        
        DispatchQueue.global().async {
            let userModel = UserModel(email: email,
                                      name:  name,
                                      uid: uid,
                                      profileImageUrl: url,
                                      startDate: startDate,
                                      region: self.country)
            guard let data = try? FirestoreEncoder().encode(userModel) else {return}
            Firestore.firestore().collection("users").document(uid).updateData(data) { (error) in
                if error != nil{
                }else{
                    if let view = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuController"){
                        self.present(view, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func regionTouchEvent(){
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertController.Style.actionSheet)
        
        let korea: UIAlertAction = UIAlertAction(title: "Korea", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.regionLabel.text = "Korea"
            self.country = "Korea"
            if self.userModel?.region == "Japan"{
                if self.nameTextField.text?.count != 0{
                    self.saveButtonView.isUserInteractionEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }
                self.regionDataChanged = true
            }else{
                if !self.photoDataChanged{
                    self.saveButtonView.isUserInteractionEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }
                self.regionDataChanged = false
            }
            
            if self.userModel?.region == nil{
                self.saveButtonView.isUserInteractionEnabled = true
                self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                self.regionDataChanged = true
            }
        })
    
        let japan: UIAlertAction = UIAlertAction(title: "Japan", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.regionLabel.text = "Japan"
            self.country = "Japan"
            if self.userModel?.region == "Korea"{
                if self.nameTextField.text?.count != 0{
                    self.saveButtonView.isUserInteractionEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }
                self.regionDataChanged = true
            }else{
                if !self.photoDataChanged{
                    self.saveButtonView.isUserInteractionEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }
                self.regionDataChanged = false
            }
            
            if self.userModel?.region == nil{
                self.saveButtonView.isUserInteractionEnabled = true
                self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                self.regionDataChanged = true
            }
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            
        })
        
    
        alert.addAction(korea)
        alert.addAction(japan)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func cameraTouchEvent(){
        let gallery = GalleryController()
        gallery.delegate = self
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
        Gallery.Config.initialTab = .imageTab
        Gallery.Config.Camera.imageLimit = 1
        present(gallery, animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        Image.resolve(images: images) { (uiImages) in
            for uiImage in uiImages {
                guard let uiImage = uiImage else { return }
                self.selectedImage = uiImage
                if self.selectedImage != nil{
                    self.profileImageView.image = self.selectedImage
                }
            }
            self.photoDataChanged = true
            self.saveButtonView.isUserInteractionEnabled = true
            self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
            self.nameTextField.text = self.userModel?.name
            controller.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func setUserData(){
        if let userModel = self.userModel{
            idLabel.text = userModel.email
            nameTextField.text = userModel.name
            
            if userModel.region == "Korea"{
                regionLabel.text = userModel.region
            }else if userModel.region == "Japan"{
                regionLabel.text = userModel.region
            }
            
            if userModel.profileImageUrl != nil{
                guard let imageUrl = userModel.profileImageUrl else {return}
                profileImageUrl = imageUrl
                profileImageView.kf.setImage(with: URL(string: imageUrl))
            }else{
                profileImageView.image = UIImage(named: "defaultprofile")
            }
        }
    }
    
    
    
    func configureViewOption(){
        saveButtonView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        saveButtonView.layer.borderWidth = 1
        saveButtonView.layer.cornerRadius = 5
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        
        cameraButton.layer.cornerRadius = cameraButton.frame.height / 2
        cameraButton.layer.masksToBounds = true
        cameraButton.layer.borderWidth = 2
        cameraButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        
        saveButtonView.isUserInteractionEnabled = false
        saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
        
        
        
        nameTextField.delegate = self
    }

    @IBAction func backButtonEvent(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
}

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
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    private var selectedImage: UIImage?
    private var uid: String?
    private var userModel: UserModel?
    private var country: String?
    private var profileImageUrl: String?
    private var photoDataChanged = false
    private var regionDataChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        configureViewOption()
        loadMyUserData()
        buttonGestureAdd()
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
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let text = textField.text, let textCount = textField.text?.count else {return}
            if  self.photoDataChanged || self.regionDataChanged{
                if textCount == 0{
                    self.saveButtonLabel.isEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }else{
                    self.saveButtonLabel.isEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }
            }else if !self.photoDataChanged && !self.regionDataChanged{
                if text != self.userModel?.name && textCount != 0{
                    self.saveButtonLabel.isEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }else{
                    self.saveButtonLabel.isEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }
            }
        }
        return true
    }
    
    @objc func saveTouchEvent(){
        saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2) /* #134563 */
        if nameTextField.text != nil{
            DispatchQueue.global().async {
                if self.selectedImage != nil{
                    let imageId = UUID.init().uuidString
                    guard let resizeImage = self.selectedImage?.resize(size: CGSize(width: 500, height: 500)) else{return}
                    guard let imageJPGE = resizeImage.jpegData(compressionQuality: 0.1) else{return}
                    
                    Storage.storage().reference().child("users/profileImage").child(imageId).putData(imageJPGE, metadata: nil) { (data, error) in
                        if error != nil{
                        }else{
                            Storage.storage().reference().child("users/profileImage").child(imageId).downloadURL(completion: { (url, error) in
                                if error != nil{
                                }else{
                                    guard let url = url?.absoluteString else{return}
                                    self.userDataUpdate(url: url)
                                }
                            })
                        }
                    }
                }else{
                    self.userDataUpdate(url: self.profileImageUrl)
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
            self.regionLabel.text = "KOREA"
            self.country = "korea"
            if self.userModel?.region == "japan"{
                if self.nameTextField.text?.count != 0{
                    self.saveButtonLabel.isEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }
                self.regionDataChanged = true
            }else{
                if !self.photoDataChanged{
                    self.saveButtonLabel.isEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }
                self.regionDataChanged = false
            }
        })
    
        let japan: UIAlertAction = UIAlertAction(title: "Japan", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.regionLabel.text = "JAPAN"
            self.country = "japan"
            if self.userModel?.region == "korea"{
                if self.nameTextField.text?.count != 0{
                    self.saveButtonLabel.isEnabled = true
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
                }
                self.regionDataChanged = true
            }else{
                if !self.photoDataChanged{
                    self.saveButtonLabel.isEnabled = false
                    self.saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
                }
                self.regionDataChanged = false
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
            self.saveButtonLabel.isEnabled = true
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
    
    func loadMyUserData(){
        DispatchQueue.global().async {
            guard let uid = self.uid else {return}
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                if error != nil{
                }else{
                    do{
                        guard let snapshot = snapshot?.data() else {return}
                        self.userModel = try? FirestoreDecoder().decode(UserModel.self, from: snapshot)
                        
                        self.idLabel.text = self.userModel?.name
                        self.nameTextField.text = self.userModel?.name
                        self.accountLabel.text = self.userModel?.email
                        if self.userModel?.region == "korea"{
                            self.regionLabel.text = "KOREA"
                        }else if self.userModel?.region == "japan"{
                            self.regionLabel.text = "JAPAN"
                        }
                        
                        guard let date = self.userModel?.startDate else {return}
                        self.startLabel.text = SharedFunction.shared.getCurrentLocaleDateFromString(string: date, format: "yyyy. MM. dd")
                        if self.userModel?.profileImageUrl != nil{
                            guard let imageUrl = self.userModel?.profileImageUrl else {return}
                            self.profileImageUrl = imageUrl
                            self.profileImageView.kf.setImage(with: URL(string: imageUrl))
                        }else{
                            self.profileImageView.image = UIImage(named: "defaultprofile")
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                }
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
        
        saveButtonLabel.isEnabled = false
        saveButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
        
        nameTextField.delegate = self
    }

    @IBAction func backButtonEvent(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
}

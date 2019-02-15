//
//  SubmitViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 6..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import FirebaseStorage
import CodableFirebase
import FirebaseAuth
import FirebaseFirestore
import Photos
import Gallery
import InstantSearchClient

class SubmitViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GalleryControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var categoryK: UIView!
    @IBOutlet weak var categoryJ: UIView!
    @IBOutlet weak var categoryFree: UIView!
    @IBOutlet weak var categoryTrevel: UIView!
    @IBOutlet weak var categoryFood: UIView!
    @IBOutlet weak var categoryShopping: UIView!
    @IBOutlet weak var submitTitle: UITextField!
    @IBOutlet weak var submitMiddleView: UIView!
    @IBOutlet weak var submitContent: PlaceHolderTextView!
    @IBOutlet weak var submitPhotoCollectionView: UICollectionView!
    @IBOutlet weak var submitViewBottom: NSLayoutConstraint!
    @IBOutlet weak var submitCameraCollectionView: UICollectionView!
    @IBOutlet weak var submitScrollView: UIScrollView!
    @IBOutlet weak var submitPhotoView: UIView!
    @IBOutlet weak var postButtonView: UIView!
    @IBOutlet weak var postButtonLabel: UILabel!
    @IBOutlet weak var downButtonVIew: UIView!
    
    
    private let changedColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.9) /* #134563 */
    private let baseColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    private var country: String = ""
    private var category: String = ""
    private var isLoading : Bool = false
    private var images = [UIImage]()
    private var image: UIImage?
    private var selectedImage = [UIImage]()
    private var selectedIndex = [Int]()
    private var count: Int = 0
    private var uid: String?
    private var name: String?
    private var profileImageUrl: String?
    private var postGesture = UITapGestureRecognizer()
    private var countryExist = false
    private var categoryExist = false
    private var titleExist = false
    private var contentExist = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewOption()
        addGesture()
        fetchPhotos()
        userDataLoad()
        cameraPermission()
    }
    
    func configureViewOption(){
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
        submitMiddleView.layer.cornerRadius = 5
        submitMiddleView.layer.borderWidth = 1
        submitMiddleView.layer.borderColor = baseColor.cgColor
        submitContent.placeHolder = " Content"
        
        postButtonView.layer.cornerRadius = 5
        postButtonView.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0).cgColor
        postButtonView.layer.borderWidth = 1
        
        submitScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        submitPhotoCollectionView.delegate = self
        submitPhotoCollectionView.dataSource = self
        submitCameraCollectionView.delegate = self
        submitCameraCollectionView.dataSource = self
        submitTitle.delegate = self
        submitContent.delegate = self
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let text = textField.text, let textCount = textField.text?.count else {return}
            if textCount > 0{
                self.titleExist = true
                self.postButtonJudge()
            }else{
                self.titleExist = false
                self.postButtonJudge()
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text, let textCount = textView.text?.count else {return}
        if textCount > 0{
            self.contentExist = true
            self.postButtonJudge()
        }else{
            self.contentExist = false
            self.postButtonJudge()
        }
    }
    
    func postButtonJudge(){
        if self.countryExist && self.categoryExist && self.titleExist && self.contentExist{
            postGesture.isEnabled = true
            postButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1)
        }else{
            postGesture.isEnabled = false
            postButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
        }
        
    }
    
    func addGesture(){
        postGesture = UITapGestureRecognizer(target: self, action: #selector(submitPostEvent))
        postGesture.isEnabled = false
        postButtonView.addGestureRecognizer(postGesture)
        postButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)
        let downGestrue = UITapGestureRecognizer(target: self, action: #selector(downButtonEvent))
        downButtonVIew.addGestureRecognizer(downGestrue)
    }
    
    func cameraPermission(){
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in if response {} else { } }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return selectedImage.count
        }else {
            return images.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! CollectionViewCellPhoto
            if !selectedImage.isEmpty{
                photoCell.imageView.image = selectedImage[indexPath.row]
                photoCell.imageView.layer.masksToBounds = true
                photoCell.imageView.contentMode = .scaleAspectFill
                photoCell.cancelButton.tag = indexPath.item
            }else{
            }
            return photoCell
        }else {
        let cameraCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCell", for: indexPath) as! CollectionViewCellCamera
            if indexPath.row == 0 {
                cameraCell.imageView.image = UIImage(named: "plus")
                cameraCell.imageView.contentMode = .center
                cameraCell.imageView.layer.masksToBounds = true
            }else{
                cameraCell.imageView.image = images[indexPath.row - 1]
                cameraCell.imageView.contentMode = .scaleAspectFill
                cameraCell.imageView.layer.masksToBounds = true
            }
            cameraCell.indexPath = indexPath
            return cameraCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.allowsMultipleSelection = true
        if collectionView.tag == 0 {

        }else if collectionView.tag == 1{
            if indexPath.row == 0 {
                camera()
                collectionView.deselectItem(at: indexPath, animated: false)
            }else{
                if selectedImage.count < 4{
                    image = images[indexPath.row - 1]
                    guard let image = self.image else{return}
                    submitPhotoView.isHidden = false
                    selectedImage.append(image)
                    selectedIndex.append(indexPath.row)
                    submitPhotoCollectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let bottom = self.submitScrollView.contentSize.height - self.submitScrollView.frame.height + 60
                        if bottom > 0{
                            let bottomOffset = CGPoint(x: 0, y: bottom)
                            self.submitScrollView.setContentOffset(bottomOffset, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            for (index, item) in selectedIndex.enumerated(){
                if item == indexPath.row{
                    selectedIndex.remove(at: index)
                    selectedImage.remove(at: index)
                    submitPhotoCollectionView.reloadData()
                    if selectedImage.isEmpty{
                        submitPhotoView.isHidden = true
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.item == 0{
            return true
        }else if selectedImage.count > 3 {
            return false
        }else{
            return true
        }
    }
    
    @IBAction func submitPhotoCancel(_ sender: Any) {
        if let button = sender as? UIButton {
            selectedImage.remove(at: button.tag)
            let index = IndexPath(item: selectedIndex[button.tag], section: 0)
            print(index)
            selectedIndex.remove(at: button.tag)
            
            
            submitCameraCollectionView.deselectItem(at: index, animated: false)
            submitPhotoCollectionView.reloadData()
            if selectedImage.isEmpty{
                submitPhotoView.isHidden = true
            }
        }
    }

    func camera(){
        selectedImage.removeAll()
        selectedIndex.removeAll()
        let gallery = GalleryController()
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
        Gallery.Config.initialTab = .imageTab
        
        gallery.delegate = self
        Gallery.Config.Camera.imageLimit = 4
        present(gallery, animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        fetchPhotos()
        selectedImage.removeAll()
        Image.resolve(images: images) { (uiImages) in
            for uiImage in uiImages {
                guard let uiImage = uiImage else { return }
                
                self.selectedImage.append(uiImage)
            }
            self.submitPhotoView.isHidden = false
            self.submitPhotoCollectionView.reloadData()
            controller.dismiss(animated: true, completion: nil)
            self.submitTitle.becomeFirstResponder()
        }
        selectedIndex.removeAll()
        for index in 0...self.images.count + 1 {
            self.submitCameraCollectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: false)
        }
        for image in images{
            self.selectedIndex.append(image.index + 1)
            if image.index + 1 < self.images.count + 1{
                self.submitCameraCollectionView.selectItem(at: IndexPath(item: image.index + 1, section: 0), animated: false, scrollPosition: .top)
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        fetchPhotos()
        submitPhotoView.isHidden = true
        controller.dismiss(animated: true, completion: nil)
        submitTitle.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            submitViewBottom.constant = 8
            submitViewBottom.constant += (keyboardSize.height)
        }
    }
    
    @objc func tapEvent(_ sender: UITapGestureRecognizer){
        if sender.view?.backgroundColor == baseColor{
            sender.view?.backgroundColor = changedColor
        }
        if sender.view?.tag == 0 {
            categoryJ.backgroundColor = baseColor
            country = "korea"
            self.countryExist = true
            self.postButtonJudge()
        }else if sender.view?.tag == 1{
            categoryK.backgroundColor = baseColor
            country = "japan"
            self.countryExist = true
            self.postButtonJudge()
        }else if sender.view?.tag == 2{
            categoryTrevel.backgroundColor = baseColor
            categoryFood.backgroundColor = baseColor
            categoryShopping.backgroundColor = baseColor
            category = "free"
            self.categoryExist = true
            self.postButtonJudge()
        }else if sender.view?.tag == 3{
            categoryFree.backgroundColor = baseColor
            categoryFood.backgroundColor = baseColor
            categoryShopping.backgroundColor = baseColor
            category = "trevel"
            self.categoryExist = true
            self.postButtonJudge()
        }else if sender.view?.tag == 4{
            categoryFree.backgroundColor = baseColor
            categoryTrevel.backgroundColor = baseColor
            categoryShopping.backgroundColor = baseColor
            category = "food"
            self.categoryExist = true
            self.postButtonJudge()
        }else if sender.view?.tag == 5{
            categoryFree.backgroundColor = baseColor
            categoryTrevel.backgroundColor = baseColor
            categoryFood.backgroundColor = baseColor
            category = "shopping"
            self.categoryExist = true
            self.postButtonJudge()
        }
    }
    
    func fetchPhotos () {
        DispatchQueue.global().async {
            self.images.removeAll()
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
            fetchOptions.fetchLimit = 10
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            
            if fetchResult.count > 0 {
                let totalImageCountNeeded = 10 // <-- The number of images to fetch
                self.fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
            }
        }
    }

    func fetchPhotoAtIndex(_ index:Int,_ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        DispatchQueue.global().async {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            
            PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: CGSize(width: 1024, height: 768), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                if let image = image {
                    self.images += [image]
                }
                
                if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                    self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
                } else {
                    DispatchQueue.main.async {
                        self.submitCameraCollectionView?.reloadData()
                    }
                }
            })
        }
    }
    
    func userDataLoad(){
        uid = Auth.auth().currentUser?.uid
        
        if !isLoading{
            DispatchQueue.global().async {
                self.isLoading = true
                guard let id = self.uid else {return}
                Firestore.firestore().collection("users").document(id).getDocument { (snapshot, error) in
                    if error != nil{
                        self.isLoading = false
                    }else{
                        guard let snapshot = snapshot, let data = snapshot.data() else { return }
                        do {
                            let userModel = try? FirestoreDecoder().decode(UserModel.self, from: data)
                            self.name = userModel?.name
                            self.profileImageUrl = userModel?.profileImageUrl
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    @objc func downButtonEvent(){
        self.submitTitle.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func pushDataAlgolia(data: [String: AnyObject]) {
        
        var index: Index?
        
        index = SessionManager.shared.client.index(withName: "post")
        
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
        
    @objc func submitPostEvent() {
        if !isLoading{
            guard let uid = self.uid,
                let title = self.submitTitle.text,
                let content = self.submitContent.text else {return}
            let date = SharedFunction.shared.getToday()
            let id = UUID.init().uuidString
            self.isLoading = true
            
            DispatchQueue.global().async {
                if !title.isEmpty && !content.isEmpty && self.country != "" && self.category != "" {
                    DispatchQueue.main.async {
                        self.postButtonLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.2)                        
                    }
                    if !self.selectedImage.isEmpty{
                        var imagesDic = [Int: String]()
                        for (index, item) in self.selectedImage.enumerated(){
                            let imageId = UUID.init().uuidString
                            guard let resizeImage = item.resize(size: CGSize(width: 500, height: 500)) else{return}
                            guard let imageJPGE = resizeImage.jpegData(compressionQuality: 0.1) else{return}
                            
                            Storage.storage().reference().child("submit/images").child(imageId).putData(imageJPGE, metadata: nil, completion: { (data, err) in
                                if err != nil {
                                }else{
                                    Storage.storage().reference().child("submit/images").child(imageId).downloadURL(completion: { (url, err) in
                                        if err != nil{
                                        }else{
                                            guard let url = url?.absoluteString else{return}
                                            imagesDic[index] = url
                                            let sortUrls = imagesDic.sorted(by: {$0.0 < $1.0})
                                            var imageUrls = [String]()
                                            for sortUrl in sortUrls {
                                                imageUrls.append(sortUrl.value)
                                                if self.selectedImage.count == imageUrls.count{
                                                    let submit = SubmitModel(id: id, uid: uid, title: title, date: date, content: content, country: self.country , category: self.category , imageUrl: imageUrls, commentCount: 0, likeCount: 0, viewsCount: 0)
                                                    let data = try! FirestoreEncoder().encode(submit)
                                                    Firestore.firestore().collection("submit").document(id).setData(data, completion: { (err) in
                                                        if err != nil{
                                                        }else{
                                                            self.dismiss(animated: true, completion: nil)
                                                            self.isLoading = false
                                                            
                                                            self.pushDataAlgolia(data: data as [String : AnyObject])
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                    })
                                }
                            })
                        }
                        
                    }else {
                        let submit = SubmitModel(id: id, uid: uid, title: title, date: date, content: content, country: self.country, category: self.category, imageUrl: nil, commentCount: 0, likeCount: 0, viewsCount: 0)
                        let data = try! FirestoreEncoder().encode(submit)
                        Firestore.firestore().collection("submit").document(id).setData(data, completion: { (err) in
                            if err != nil{
                            }else{
                                self.dismiss(animated: true, completion: nil)
                                self.isLoading = false
                                
                                self.pushDataAlgolia(data: data as [String : AnyObject])
                            }
                        })
                    }
                }else{
                    self.isLoading = false
                }
            }
        }
    }
}

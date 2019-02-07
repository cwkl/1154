//
//  ListViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 3..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuView: UIView!
    
    private let item = ["Like", "Bookmark"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewOption()
    }
    
    func configureViewOption(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return CGSize(width: UIScreen.main.bounds.width / CGFloat(item.count), height: collectionView.frame.height)
    }
    
    @IBAction func backButtonEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

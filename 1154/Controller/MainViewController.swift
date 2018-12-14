//
//  MainViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 11. 30..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionViewCellDeligate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var submitButton: UIImageView!

    
    private var pagerView:PageViewController = PageViewController()
    private var bar = UIView()
    private var leftConstraints: NSLayoutConstraint?
    private let item = ["All","Free","Trevel","Food","Shopping"]
    var isAnimating = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let bar = UIView()
        menuView.addSubview(bar)
        self.bar = bar
        bar.backgroundColor = UIColor.red
        bar.translatesAutoresizingMaskIntoConstraints = false
        leftConstraints = bar.leadingAnchor.constraint(equalTo: menuView.leadingAnchor)
        leftConstraints?.isActive = true
        bar.bottomAnchor.constraint(equalTo: menuView.bottomAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        bar.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / CGFloat(item.count)).isActive = true
        
        pagerView.bar = bar
        pagerView.leftConstraints = leftConstraints
        
        collectionView.backgroundColor = UIColor.white
        
        let underLine = UIView()
        self.view.addSubview(underLine)
        underLine.translatesAutoresizingMaskIntoConstraints = false
        underLine.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        underLine.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        underLine.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        underLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        underLine.backgroundColor = UIColor.lightGray
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(submitButtonEvent))
        submitButton.isUserInteractionEnabled  = true
        submitButton.addGestureRecognizer(tapGesture)
        
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        
        pagerView.collectionView = self.collectionView
    }
    
    @objc func submitButtonEvent(){
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "submitNav") as? UINavigationController{
            self.present(view, animated: true, completion: nil)
        }
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PageViewController,
            segue.identifier == "pager"{
            self.pagerView = vc
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.cellLabel.text = item[indexPath.item]
        cell.indexPath = indexPath
        cell.delegate = self

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / CGFloat(item.count), height: collectionView.frame.height)
    }
    
    func tapCell(indexPath: IndexPath) {
        for visibleCell in collectionView.visibleCells {
            if let visibleCell = visibleCell as? CollectionViewCell {
                visibleCell.tapGesture.isEnabled = false
                
                if visibleCell.indexPath?.item == indexPath.item {
                    visibleCell.cellLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1.0) /* #134563 */
                } else {
                    visibleCell.cellLabel.textColor = .lightGray
                }
            }
        }
        
        if !isAnimating {
            isAnimating = true
            let index = indexPath.row
            let x = (UIScreen.main.bounds.width / CGFloat(item.count)) * CGFloat(index)
            leftConstraints?.constant = x

            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (complete) in
                self.isAnimating = false
                
                
                for visibleCell in self.collectionView.visibleCells {
                    if let visibleCell = visibleCell as? CollectionViewCell {
                        visibleCell.tapGesture.isEnabled = true
                    }
                }
            }
            self.pagerView.itemWasPressed(index: index)
        }
    }
}
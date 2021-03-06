////
////  NotificationPageViewController.swift
////  1154
////
////  Created by Junhyeok Kwon on 2019. 2. 16..
////  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
////
//
//import UIKit
//
//class NotificationPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
//    
//    var pageIndex = 0
//    var flag = true
//    var bar: UIView?
//    var leftConstraints: NSLayoutConstraint?
//    var collectionView : UICollectionView?
//    
//    lazy var viewControllerList: [UIViewController] = {
//        
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let page1 = storyBoard.instantiateViewController(withIdentifier: "LikeNotifiTableViewController")
//        page1.view.tag = 0
//        if let like = page1 as? LikeNotifiTableViewController {
//            like.pagerView = self
//        }
//        let page2 = storyBoard.instantiateViewController(withIdentifier: "CommentNotifiTableViewController")
//        page2.view.tag = 1
//        if let comment = page2 as? CommentNotifiTableViewController {
//            comment.pagerView = self
//        }
//        
//        return [page1, page2]
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.dataSource = self
//        self.delegate = self
//        setupScrollView()
//        
//        if let firstViewContoller = viewControllerList.first{
//            self.setViewControllers([firstViewContoller], direction: .forward, animated: true, completion: nil)
//        }
//    }
//    
//    func itemWasPressed(index : Int){
//        
//        flag = false
//        if pageIndex < index{
//            setViewControllers([viewControllerList[index]], direction: .forward, animated: true, completion: nil)
//            
//        }else{
//            setViewControllers([viewControllerList[index]], direction: .reverse, animated: true, completion: nil)
//            
//        }
//        pageIndex = index
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        
//        guard let index = viewControllerList.index(of: viewController) else{return nil}
//        
//        let previousIndex = index - 1
//        
//        guard previousIndex >= 0  else {return nil}
//        
//        return viewControllerList[previousIndex]
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        
//        guard let index = viewControllerList.index(of: viewController) else{return nil}
//        
//        let nextIndex = index + 1
//        
//        guard viewControllerList.count != nextIndex  else {return nil}
//        
//        return viewControllerList[nextIndex]
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        
//        guard let collectionView = self.collectionView, completed else { return }
//        
//        pageIndex = pageViewController.viewControllers!.first!.view.tag
//        
//        for visibleCell in collectionView.visibleCells {
//            if let visibleCell = visibleCell as? NotificationCollectionViewCell {
//                if visibleCell.indexPath?.item == pageIndex {
//                    visibleCell.categoryLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.9) /* #134563 */
//                } else {
//                    visibleCell.categoryLabel.textColor = .lightGray
//                }
//            }
//        }
//    }
//    
//    private func setupScrollView() {
//        let scrollView = view.subviews.compactMap { $0 as? UIScrollView }.first
//        scrollView?.scrollsToTop = false
//        scrollView?.delegate = self
//        scrollView?.backgroundColor = UIColor.white
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if flag{
//            let scrollX = scrollView.contentOffset.x - UIScreen.main.bounds.width
//            
//            let barX = scrollX / CGFloat(viewControllerList.count)
//            if scrollX != 0.0{
//                let moveX = (CGFloat(pageIndex) * UIScreen.main.bounds.width / CGFloat(viewControllerList.count)) + barX
//                leftConstraints?.constant = CGFloat(moveX)
//            }
//        }
//    }
//    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        flag = true
//    }
//}

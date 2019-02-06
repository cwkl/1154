//
//  PageViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 3..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    var pageIndex = 0
    var flag = true
    var bar: UIView?
    var leftConstraints: NSLayoutConstraint?
    var collectionView : UICollectionView?
    
    lazy var viewControllerList: [UIViewController] = {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let page1 = storyBoard.instantiateViewController(withIdentifier: "page1")
        page1.view.tag = 0
        if let all = page1 as? AllTableViewController {
            all.pagerView = self
        }
        let page2 = storyBoard.instantiateViewController(withIdentifier: "page2")
        page2.view.tag = 1
        if let free = page2 as? FreeTableViewController {
            free.pagerView = self
        }
        let page3 = storyBoard.instantiateViewController(withIdentifier: "page3")
        page3.view.tag = 2
        if let trevel = page3 as? TrevelTableViewController {
            trevel.pagerView = self
        }
        let page4 = storyBoard.instantiateViewController(withIdentifier: "page4")
        page4.view.tag = 3
        if let food = page4 as? FoodTableViewController {
            food.pagerView = self
        }
        let page5 = storyBoard.instantiateViewController(withIdentifier: "page5")
        page5.view.tag = 4
        if let shopping = page5 as? ShoppingTableViewController {
            shopping.pagerView = self
        }
        
        return [page1, page2, page3, page4, page5]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        setupScrollView()
        
        if let firstViewContoller = viewControllerList.first{
            self.setViewControllers([firstViewContoller], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func itemWasPressed(index : Int){
        
        flag = false
        if pageIndex < index{
            setViewControllers([viewControllerList[index]], direction: .forward, animated: true, completion: nil)
            
        }else{
            setViewControllers([viewControllerList[index]], direction: .reverse, animated: true, completion: nil)
            
        }
        pageIndex = index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = viewControllerList.index(of: viewController) else{return nil}
        
        let previousIndex = index - 1
        
        guard previousIndex >= 0  else {return nil}
        
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = viewControllerList.index(of: viewController) else{return nil}
        
        let nextIndex = index + 1
        
        guard viewControllerList.count != nextIndex  else {return nil}
        
        return viewControllerList[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let collectionView = self.collectionView, completed else { return }

        pageIndex = pageViewController.viewControllers!.first!.view.tag
        
        for visibleCell in collectionView.visibleCells {
            if let visibleCell = visibleCell as? CollectionViewCellCategory {
                if visibleCell.indexPath?.item == pageIndex {
                    visibleCell.cellLabel.textColor = UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 0.9) /* #134563 */
                } else {
                    visibleCell.cellLabel.textColor = .lightGray
                }
            }
        }
//        collectionView?.selectItem(at: IndexPath(row: pageIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
    
    private func setupScrollView() {
        let scrollView = view.subviews.compactMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        scrollView?.backgroundColor = UIColor.white
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if flag{
            let scrollX = scrollView.contentOffset.x - UIScreen.main.bounds.width

            let barX = scrollX / CGFloat(viewControllerList.count)
            if scrollX != 0.0{
                let moveX = (CGFloat(pageIndex) * UIScreen.main.bounds.width / CGFloat(viewControllerList.count)) + barX
                leftConstraints?.constant = CGFloat(moveX)
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            flag = true
    }
}

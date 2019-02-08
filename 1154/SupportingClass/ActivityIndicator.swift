//
//  ActivityIndicator.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 8..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class ActivityIndicator{
    
    static let shared = ActivityIndicator()
    
    var activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor(red: 19/255, green: 69/255, blue: 99/255, alpha: 1) /* #134563 */)
    
    func addIndicator(view : UIView){
        view.addSubview(activityIndicator)
    }
    
    func start(view : UIView){
       
        activityIndicator.center = view.center

        if !(activityIndicator.isAnimating){
            activityIndicator.startAnimating()
        }
    }
    
    func stop(view : UIView){
        activityIndicator.removeFromSuperview()
        UIView.animate(withDuration: 0.2) {
            view.alpha = 1.0
        }
    }
}
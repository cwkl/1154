//
//  PlaceHolderTextView.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 7..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit

public class PlaceHolderTextView: UITextView {
    
    lazy var placeHolderLabel: UILabel = UILabel()
    var placeHolderColor: UIColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    var placeHolder: NSString = ""
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if(self.placeHolder.length > 0) {
            self.placeHolderLabel.frame = CGRect(x: 5.0, y: 8.0, width: self.bounds.size.width  - 16.0, height: 0.0)
            self.placeHolderLabel.lineBreakMode = .byWordWrapping
            self.placeHolderLabel.numberOfLines = 0
            self.placeHolderLabel.font = self.font
            self.placeHolderLabel.backgroundColor = .clear
            self.placeHolderLabel.textColor = self.placeHolderColor
            self.placeHolderLabel.alpha = 0.0
            self.placeHolderLabel.tag = 1
            
            self.placeHolderLabel.text = self.placeHolder as String
            self.placeHolderLabel.sizeToFit()
            self.addSubview(placeHolderLabel)
        }
        
        self.sendSubviewToBack(placeHolderLabel)
        
        if self.text.utf16.count == 0 && self.placeHolder.length > 0 {
            self.viewWithTag(1)?.alpha = 1
        }
    }
    
    @objc public func textChanged(notification:NSNotification?) -> (Void) {
        if self.placeHolder.length == 0 {
            return
        }
        
        if self.text.utf16.count == 0 {
            self.viewWithTag(1)?.alpha = 1
        } else {
            self.viewWithTag(1)?.alpha = 0
        }
    }
    
    func showPlaceHolder() {
        self.viewWithTag(1)?.alpha = 1
    }
}

//
//  UISearchBar.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 14..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

extension UISearchBar {
    var textField: UITextField? {
        return value(forKey: "_searchField") as? UITextField
    }
    
    func disableBlur() {
        backgroundImage = UIImage()
        isTranslucent = true
    }
    
    var cancelButton: UIButton? {
        return value(forKey: "_cancelButton") as? UIButton
    }
}

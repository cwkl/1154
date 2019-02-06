//
//  ListViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 3..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func backButtonEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

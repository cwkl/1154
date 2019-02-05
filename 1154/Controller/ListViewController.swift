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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonEvent(_ sender: Any) {
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuController"){
            self.present(view , animated: true, completion: nil)
        }
    }
    
}

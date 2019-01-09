//
//  SubmitContentViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 8..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import UIKit

class SubmitContentViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userAccountLabel: UILabel!
    @IBOutlet weak var submitTitleLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    private var bar = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bar = UIView()
        mainView.addSubview(bar)
        self.bar = bar
        bar.backgroundColor = UIColor.lightGray
        bar.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        

    }
    @IBAction func backEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

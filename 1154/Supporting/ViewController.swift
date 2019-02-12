//
//  ViewController.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 11. 26..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {
    
    var box = UIImageView()
    var remoteConfig: RemoteConfig!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
        
        self.view.addSubview(box)
        box.snp.makeConstraints{(make) in
            make.center.equalTo(self.view)
            make.height.equalTo(70)
            make.width.equalTo(70)
            }
//        box.image = UIImage(named: "")
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func displayWelcome(){
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if (caps) {
            let alert = UIAlertController(title: "!!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in exit(0)}))
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginVC, animated: false, completion: nil)
        }
    }
}

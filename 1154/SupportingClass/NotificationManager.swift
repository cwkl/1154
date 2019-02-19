//
//  NotificationManager.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 12..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation

class NotificationManager: NSObject {
    
    //MARK: base remove
    static func remove(_ observer:Any) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    //MARK: base post
    private static func post(notificationName:NSNotification.Name, object:Any?, userInfo:[AnyHashable: Any]?) {
        NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
    }
    private static func post(name:String, object:Any?, userInfo:[AnyHashable: Any]? = nil) {
        self.post(notificationName: NSNotification.Name(name), object: object, userInfo: userInfo)
    }
    
    //MARK: base receive
    private static func receive(notificationName:NSNotification.Name, observer:Any, selector:Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: nil)
    }
    private static func receive(name:String, observer:Any, selector:Selector) {
        self.receive(notificationName:NSNotification.Name(name), observer:observer, selector:selector)
    }
    
    //MARK: Keyboard
    static func receive(keyboardDidChangeFrame observer:Any, selector:Selector) {
        let name = UIResponder.keyboardDidChangeFrameNotification
        self.receive(notificationName: name, observer: observer, selector: selector)
    }
    static func receive(keyboardDidHide observer:Any, selector:Selector) {
        let name = UIResponder.keyboardDidHideNotification
        self.receive(notificationName: name, observer: observer, selector: selector)
    }
    static func receive(keyboardWillChangeFrame observer:Any, selector:Selector) {
        let name = UIResponder.keyboardWillChangeFrameNotification
        self.receive(notificationName: name, observer: observer, selector: selector)
    }
    static func receive(keyboardWillHide observer:Any, selector:Selector) {
        let name = UIResponder.keyboardWillHideNotification
        self.receive(notificationName: name, observer: observer, selector: selector)
    }
    static func receive(keyboardWillShow observer:Any, selector:Selector) {
        let name = UIResponder.keyboardWillShowNotification
        self.receive(notificationName: name, observer: observer, selector: selector)
    }
    
    //MARK: SplashEnd
    private static let N_SPLASH_END = "N_SPLASH_END"
    static func postSplashEnd() { self.post(name: N_SPLASH_END, object: nil, userInfo:nil) }
    static func receive(splashEnd observer:Any, selector:Selector) { receive(name: N_SPLASH_END, observer: observer, selector: selector) }
    static func removeSplashEnd(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: N_SPLASH_END), object: nil)
    }
    
    //MARK: After Profile edit Reload
    private static let N_MAIN_USER_RELOAD = "N_MAIN_USER_RELOAD"
    static func postMainUserReload() { self.post(name: N_MAIN_USER_RELOAD, object: nil, userInfo:nil) }
    static func receive(mainUserReload observer:Any, selector:Selector) { receive(name: N_MAIN_USER_RELOAD, observer: observer, selector: selector) }
    static func removeMainUserReload(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: N_MAIN_USER_RELOAD), object: nil)
    }
    private static let N_SIDE_USER_RELOAD = "N_SIDE_USER_RELOAD"
    static func postSideUserReload() { self.post(name: N_SIDE_USER_RELOAD, object: nil, userInfo:nil) }
    static func receive(sideUserReload observer:Any, selector:Selector) { receive(name: N_SIDE_USER_RELOAD, observer: observer, selector: selector) }
    static func removeSideUserReload(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: N_SIDE_USER_RELOAD), object: nil)
    }
    
    private static let N_PUSH_NOTIFICATION_CLICK = "N_PUSH_NOTIFICATION_CLICK"
    static func postPushNotification() { self.post(name: N_PUSH_NOTIFICATION_CLICK, object: nil, userInfo:nil) }
    static func receive(pushNotification observer:Any, selector:Selector) { receive(name: N_PUSH_NOTIFICATION_CLICK, observer: observer, selector: selector) }
    static func removepushNotification(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: N_PUSH_NOTIFICATION_CLICK), object: nil)
    }
    
}


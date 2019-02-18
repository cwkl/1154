//
//  NotificationModel.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 18..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation

struct NotificationModel: Codable {
    
    let type: String
    let id: String
    let uid: String
    let content: String
    let date: String
    let name: String
    let submitId: String
}

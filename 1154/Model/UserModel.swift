//
//  UserModel.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 10..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import Foundation

struct UserModel: Codable {
    
    let email: String
    let name: String
    let uid: String
    let profileImageUrl: String?
    let startDate: String
    let region: String?
}

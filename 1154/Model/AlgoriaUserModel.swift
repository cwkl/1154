//
//  AlgoriaUserModel.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation

struct AlgoriaUserModel: Codable {
    
    let email: String
    let name: String
    let uid: String
    let objectID: String
    let profileImageUrl: String?
    let startDate: String
    let region: String?
}

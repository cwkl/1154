//
//  SubmitModel.swift
//  1154
//
//  Created by Junhyeok Kwon on 2018. 12. 7..
//  Copyright © 2018년 Junhyeok Kwon. All rights reserved.
//

import Foundation

struct SubmitModel: Codable {
    
    let id: String
    let uid: String
    let title: String
    let date: String
    let content: String
    let country: String
    let category: String
    let imageUrl: [String]?
    let commentCount: Int
    let likeCount: Int
    let viewsCount: Int
    
}

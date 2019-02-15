//
//  AlgoriaSubmitModel.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation

struct AlgoriaSubmitModel: Codable {
    
    let id: String
    let objectID: String
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

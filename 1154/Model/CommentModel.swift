//
//  CommentModel.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 22..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation

struct CommentModel: Codable {
    
    let name: String
    let uid: String?
    let date: String
    let comment: String
    let commentLikeCount: Int
    let to: String?
    let id: String
    let isSubComment: Bool
    let delete: Bool
}

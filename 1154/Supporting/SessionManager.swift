//
//  SessionManager.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 2. 15..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation
import InstantSearchClient

class SessionManager {
    static let shared = SessionManager()
    
    let client = Client(appID: "MKY47D9TK1", apiKey: "c912a45d6c9375c9645ac45b9222deaa")
}

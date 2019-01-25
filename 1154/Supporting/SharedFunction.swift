//
//  GetToday.swift
//  1154
//
//  Created by Junhyeok Kwon on 2019. 1. 22..
//  Copyright © 2019년 Junhyeok Kwon. All rights reserved.
//

import Foundation

class SharedFunction{
    static let shared = SharedFunction()
    
    func getToday(format:String = "yyyy/MM/dd HH:mm:ss.SSS") -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter.string(from: now as Date)
    }
    
    func getCurrentLocaleDateFromString(string: String, format: String = "yyyy/MM/dd HH:mm:ss.SSS") -> String {
        let date = dateFromString(string: string)
        let currentformatter = DateFormatter()
        currentformatter.timeZone = TimeZone.current
        currentformatter.locale = Locale.current
        currentformatter.dateFormat = format
        return currentformatter.string(from: date)
    }
    
    func dateFromString(string: String, format: String = "yyyy/MM/dd HH:mm:ss.SSS") -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        if let date = formatter.date(from: string) {
            return date
        } else {
            return Date()
        }
    }
}

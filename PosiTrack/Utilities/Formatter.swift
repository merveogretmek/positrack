//
//  Formatter.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import Foundation

struct Formatter {
    // e.g., "March 3"
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
    
    // e.g., "3"
    static let dayOfMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    // e.g., "Mon", "Tue", etc.
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}

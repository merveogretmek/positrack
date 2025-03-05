//
//  FocusPreset.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import Foundation

enum FocusPreset: String, CaseIterable, Identifiable {
    case pomodoro = "Pomodoro"
    case shortFocus = "Short Focus"
    case longFocus = "Long Focus"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var duration: TimeInterval {
        switch self {
        case .pomodoro:
            return 25 * 60
        case .shortFocus:
            return 15 * 60
        case .longFocus:
            return 50 * 60
        case .custom:
            return 25 * 60
        }
    }
}

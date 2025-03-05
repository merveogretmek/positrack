//
//  Task.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import Foundation

enum TaskPriority: String, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var id: String { rawValue }
}

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var description: String = ""
    var dueDate: Date? = nil
    var priority: TaskPriority = .medium
    var isCompleted: Bool = false
}

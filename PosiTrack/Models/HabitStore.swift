//
//  HabitStore.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import Foundation
import Combine

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
}

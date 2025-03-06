import Foundation

struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var isNew: Bool = false
    var progress: Double
    var goal: Double
    var unit: String
    var streak: Int
    var reminder: Bool
}


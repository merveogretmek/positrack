import Foundation

enum HabitFrequency: String, Codable, CaseIterable, Identifiable {
    case daily, weekly
    var id: String { self.rawValue }
}

struct Habit: Identifiable, Codable {
    let id = UUID()
    let creationDate: Date          // When the habit was added
    var name: String
    var isNew: Bool = false
    // Daily progress value (resets each day)
    var progress: Double = 0.0
    var goal: Double
    var unit: String
    var streak: Int = 0
    var reminder: Bool
    var frequency: HabitFrequency   // .daily or .weekly
    
    // Tracks the day the habit was completed (i.e. goal met)
    var lastCompletionDate: Date? = nil
    // Tracks the day when progress was last updated
    var lastProgressDate: Date? = nil
    
    /// Determines whether the habit should display on the given date.
    func shouldDisplay(on date: Date) -> Bool {
        // Do not show the habit if the selected date is before the habit’s creation.
        guard date >= creationDate else { return false }
        
        switch frequency {
        case .daily:
            // Daily habits show on every day after creation.
            return true
        case .weekly:
            // Weekly habits appear on the creation day and then every 7 days.
            let daysDifference = Calendar.current.dateComponents([.day], from: creationDate, to: date).day ?? 0
            return daysDifference % 7 == 0
        }
    }
}

import Foundation

enum HabitFrequency: Codable, Identifiable {
    case daily
    case weekly
    case custom(Int)  // Custom frequency: every N days

    var id: String {
        switch self {
        case .daily:
            return "daily"
        case .weekly:
            return "weekly"
        case .custom(let days):
            return "custom_\(days)"
        }
    }
    
    var description: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .custom(let days):
            return "Every \(days) days"
        }
    }
    
    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case type, days
    }
    enum FrequencyType: String, Codable {
        case daily, weekly, custom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(FrequencyType.self, forKey: .type)
        switch type {
        case .daily:
            self = .daily
        case .weekly:
            self = .weekly
        case .custom:
            let days = try container.decode(Int.self, forKey: .days)
            self = .custom(days)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .daily:
            try container.encode(FrequencyType.daily, forKey: .type)
        case .weekly:
            try container.encode(FrequencyType.weekly, forKey: .type)
        case .custom(let days):
            try container.encode(FrequencyType.custom, forKey: .type)
            try container.encode(days, forKey: .days)
        }
    }
}

struct Habit: Identifiable, Codable {
    let id = UUID()
    let creationDate: Date          // When the habit was added
    var name: String
    var isNew: Bool = false
    // Store daily progress keyed by a date string (e.g., "2025-03-07")
    var dailyProgress: [String: Double] = [:]
    var goal: Double
    var unit: String
    var reminder: Bool
    var frequency: HabitFrequency   // .daily, .weekly, or .custom(Int)
    
    // Optionally track the last update dates.
    var lastCompletionDate: Date? = nil
    var lastProgressDate: Date? = nil
    
    /// Returns a date key (string) for the provided date.
    func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// Returns the progress logged on a given date.
    func progress(on date: Date) -> Double {
        let key = dateKey(for: date)
        return dailyProgress[key] ?? 0.0
    }
    
    /// Determines whether the habit should display on the given date.
    func shouldDisplay(on date: Date) -> Bool {
        guard date >= creationDate else { return false }
        let daysDifference = Calendar.current.dateComponents([.day], from: creationDate, to: date).day ?? 0
        
        switch frequency {
        case .daily:
            return true
        case .weekly:
            return daysDifference % 7 == 0
        case .custom(let customDays):
            return daysDifference % customDays == 0
        }
    }
}

// MARK: - Computed Streak Extension
extension Habit {
    /// Computes the current streak of consecutive days (ending with the given date)
    /// on which the habit was complete (i.e. progress >= goal).
    /// If the given day isn’t complete, the streak is 0.
    func computedStreak(upTo date: Date = Date()) -> Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: date)
        while true {
            let key = dateKey(for: currentDate)
            if let progress = dailyProgress[key], progress >= goal {
                streak += 1
            } else {
                break
            }
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDate
        }
        return streak
    }
}

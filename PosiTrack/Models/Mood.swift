import Foundation

// MARK: - Mood Categories
enum MoodCategory: String, CaseIterable, Codable {
    case happy = "Happy"
    case sad = "Sad"
    case anxious = "Anxious"
    case angry = "Angry"
    case calm = "Calm"
    case energetic = "Energetic"
    case tired = "Tired"
    case excited = "Excited"
    
    var symbol: String {
        switch self {
        case .happy: return "sun.max.fill"
        case .sad: return "cloud.rain.fill"
        case .anxious: return "tornado"
        case .angry: return "flame.fill"
        case .calm: return "leaf.fill"
        case .energetic: return "bolt.fill"
        case .tired: return "moon.zzz.fill"
        case .excited: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .happy: return "FFD700"
        case .sad: return "4169E1"
        case .anxious: return "FF6347"
        case .angry: return "DC143C"
        case .calm: return "90EE90"
        case .energetic: return "FF4500"
        case .tired: return "808080"
        case .excited: return "FF1493"
        }
    }
    
    var subcategories: [String] {
        switch self {
        case .happy:
            return ["Joyful", "Content", "Grateful", "Optimistic", "Cheerful", "Blissful"]
        case .sad:
            return ["Melancholic", "Disappointed", "Heartbroken", "Lonely", "Gloomy", "Sorrowful"]
        case .anxious:
            return ["Worried", "Nervous", "Stressed", "Panicked", "Restless", "Overwhelmed"]
        case .angry:
            return ["Frustrated", "Irritated", "Furious", "Annoyed", "Resentful", "Outraged"]
        case .calm:
            return ["Peaceful", "Relaxed", "Serene", "Tranquil", "Balanced", "Zen"]
        case .energetic:
            return ["Vibrant", "Dynamic", "Motivated", "Enthusiastic", "Powerful", "Invigorated"]
        case .tired:
            return ["Exhausted", "Drained", "Sleepy", "Weary", "Fatigued", "Lethargic"]
        case .excited:
            return ["Thrilled", "Elated", "Ecstatic", "Eager", "Pumped", "Animated"]
        }
    }
}

// MARK: - Mood Context
enum MoodTrigger: String, CaseIterable, Codable {
    case work = "Work"
    case relationships = "Relationships"
    case health = "Health"
    case family = "Family"
    case finances = "Finances"
    case weather = "Weather"
    case exercise = "Exercise"
    case food = "Food"
    case sleep = "Sleep"
    case social = "Social"
    case personal = "Personal"
    case other = "Other"
}

enum MoodLocation: String, CaseIterable, Codable {
    case home = "Home"
    case work = "Work"
    case school = "School"
    case outdoors = "Outdoors"
    case gym = "Gym"
    case restaurant = "Restaurant"
    case transport = "Transport"
    case social = "Social Place"
    case other = "Other"
}

// MARK: - Main Mood Model
struct MoodEntry: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let category: MoodCategory
    let subcategory: String
    let intensity: Int // 1-5 scale
    let notes: String
    let triggers: [MoodTrigger]
    let location: MoodLocation?
    let activities: [String]
    
    init(category: MoodCategory, subcategory: String, intensity: Int, notes: String = "", triggers: [MoodTrigger] = [], location: MoodLocation? = nil, activities: [String] = []) {
        self.timestamp = Date()
        self.category = category
        self.subcategory = subcategory
        self.intensity = intensity
        self.notes = notes
        self.triggers = triggers
        self.location = location
        self.activities = activities
    }
}

// MARK: - Mood Statistics
struct MoodStats {
    let averageIntensity: Double
    let mostCommonCategory: MoodCategory?
    let mostCommonTrigger: MoodTrigger?
    let totalEntries: Int
    let weeklyTrend: [Double] // Last 7 days average
}
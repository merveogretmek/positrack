import Foundation
import SwiftUI

class MoodStore: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let moodEntriesKey = "MoodEntries"
    
    init() {
        loadMoodEntries()
    }
    
    // MARK: - Data Management
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
        moodEntries.sort { $0.timestamp > $1.timestamp }
        saveMoodEntries()
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        moodEntries.removeAll { $0.id == entry.id }
        saveMoodEntries()
    }
    
    func updateMoodEntry(_ entry: MoodEntry) {
        if let index = moodEntries.firstIndex(where: { $0.id == entry.id }) {
            moodEntries[index] = entry
            moodEntries.sort { $0.timestamp > $1.timestamp }
            saveMoodEntries()
        }
    }
    
    // MARK: - Persistence
    private func saveMoodEntries() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            userDefaults.set(encoded, forKey: moodEntriesKey)
        }
    }
    
    private func loadMoodEntries() {
        if let data = userDefaults.data(forKey: moodEntriesKey),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moodEntries = decoded.sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    // MARK: - Analytics
    func getMoodStats(for period: StatsPeriod = .week) -> MoodStats {
        let filteredEntries = getEntriesForPeriod(period)
        
        let averageIntensity = filteredEntries.isEmpty ? 0.0 : 
            Double(filteredEntries.reduce(0) { $0 + $1.intensity }) / Double(filteredEntries.count)
        
        let categoryCount = Dictionary(grouping: filteredEntries) { $0.category }
            .mapValues { $0.count }
        let mostCommonCategory = categoryCount.max { $0.value < $1.value }?.key
        
        let triggerCount = Dictionary(grouping: filteredEntries.flatMap { $0.triggers }) { $0 }
            .mapValues { $0.count }
        let mostCommonTrigger = triggerCount.max { $0.value < $1.value }?.key
        
        let weeklyTrend = getWeeklyTrend()
        
        return MoodStats(
            averageIntensity: averageIntensity,
            mostCommonCategory: mostCommonCategory,
            mostCommonTrigger: mostCommonTrigger,
            totalEntries: filteredEntries.count,
            weeklyTrend: weeklyTrend
        )
    }
    
    private func getEntriesForPeriod(_ period: StatsPeriod) -> [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .day:
            return moodEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return moodEntries.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return moodEntries.filter { $0.timestamp >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return moodEntries.filter { $0.timestamp >= yearAgo }
        }
    }
    
    private func getWeeklyTrend() -> [Double] {
        let calendar = Calendar.current
        let now = Date()
        var weeklyTrend: [Double] = []
        
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayEntries = moodEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: day) }
                let average = dayEntries.isEmpty ? 0.0 : 
                    Double(dayEntries.reduce(0) { $0 + $1.intensity }) / Double(dayEntries.count)
                weeklyTrend.append(average)
            }
        }
        
        return weeklyTrend.reversed()
    }
    
    // MARK: - Filtering
    func getEntriesForToday() -> [MoodEntry] {
        let calendar = Calendar.current
        return moodEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: Date()) }
    }
    
    func getEntriesByCategory(_ category: MoodCategory) -> [MoodEntry] {
        return moodEntries.filter { $0.category == category }
    }
    
    func getEntriesByIntensity(min: Int, max: Int) -> [MoodEntry] {
        return moodEntries.filter { $0.intensity >= min && $0.intensity <= max }
    }
}

enum StatsPeriod: String, CaseIterable {
    case day = "Today"
    case week = "This Week"
    case month = "This Month"
    case year = "This Year"
}
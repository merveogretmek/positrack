import SwiftUI

@main
struct MyHabitTrackerApp: App {
    @StateObject private var habitStore = HabitStore()
    @StateObject private var taskStore = TaskStore()
    @StateObject private var moodStore = MoodStore()
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Theme appearance is now handled by ThemeManager
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitStore)
                .environmentObject(taskStore)
                .environmentObject(moodStore)
                .environmentObject(themeManager)
        }
    }
}


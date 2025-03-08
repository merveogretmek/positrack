import SwiftUI
import Charts

// MARK: - Stats View (Parent)
struct StatsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var taskStore: TaskStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. Habit Performance Section
                    HabitPerformanceSection(habits: habitStore.habits)
                }
                .padding()
            }
            .background(Color(hex: "31363F").ignoresSafeArea())
            .navigationTitle("Stats")
        }
    }
}

// MARK: - Habit Performance Section
struct HabitPerformanceSection: View {
    let habits: [Habit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Performance")
                .font(.headline)
                .foregroundColor(Color(hex: "EEEEEE"))
            
            // Display current and longest streak for each habit.
            ForEach(habits) { habit in
                VStack(alignment: .leading) {
                    Text("• \(habit.name)")
                        .foregroundColor(Color(hex: "EEEEEE"))
                    Text("Current Streak: \(habit.computedStreak(upTo: Date()))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "222831")))
    }
}

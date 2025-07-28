import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var moodStore: MoodStore
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedPeriod: StatsPeriod = .week
    @State private var selectedTab: AnalyticsTab = .overview
    
    enum AnalyticsTab: String, CaseIterable {
        case overview = "Overview"
        case habits = "Habits"
        case tasks = "Tasks"
        case mood = "Mood"
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .habits: return "brain.fill"
            case .tasks: return "list.bullet.clipboard.fill"
            case .mood: return "heart.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Period Selector
                    periodSelector
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Tab Selector
                    tabSelector
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedTab {
                            case .overview:
                                overviewContent
                            case .habits:
                                habitsContent
                            case .tasks:
                                tasksContent
                            case .mood:
                                moodContent
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Analytics")
        }
    }
    
    private var periodSelector: some View {
        HStack {
            Text("Time Period")
                .font(.headline)
                .foregroundColor(themeManager.textColor)
            
            Spacer()
            
            Menu {
                ForEach(StatsPeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                    }) {
                        HStack {
                            Text(period.rawValue)
                            if selectedPeriod == period {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedPeriod.rawValue)
                        .foregroundColor(themeManager.textColor)
                    Image(systemName: "chevron.down")
                        .foregroundColor(themeManager.textColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(themeManager.secondaryBackgroundColor)
                .cornerRadius(20)
            }
        }
    }
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.caption)
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedTab == tab ? themeManager.textColor : themeManager.secondaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            selectedTab == tab ? 
                            themeManager.accentColor : 
                            themeManager.secondaryBackgroundColor
                        )
                        .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Quick Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                OverviewStatCard(
                    title: "Active Habits",
                    value: "\(habitStore.habits.count)",
                    icon: "brain.fill",
                    color: "4ECDC4"
                )
                
                OverviewStatCard(
                    title: "Pending Tasks",
                    value: "\(taskStore.tasks.filter { !$0.isCompleted }.count)",
                    icon: "list.bullet.clipboard",
                    color: "FF6B6B"
                )
                
                OverviewStatCard(
                    title: "Mood Entries",
                    value: "\(moodStore.moodEntries.count)",
                    icon: "heart.circle.fill",
                    color: "836FFF"
                )
                
                OverviewStatCard(
                    title: "Completion Rate",
                    value: "\(Int(getOverallCompletionRate()))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: "FFD700"
                )
            }
            
            // Weekly Activity Chart Placeholder
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Activity")
                    .font(.headline)
                    .foregroundColor(themeManager.textColor)
                
                // Simple activity visualization
                HStack(spacing: 8) {
                    ForEach(0..<7) { day in
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(themeManager.accentColor.opacity(Double.random(in: 0.2...1.0)))
                                .frame(width: 20, height: CGFloat.random(in: 20...60))
                                .cornerRadius(4)
                            
                            Text(getDayLetter(day))
                                .font(.caption2)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.secondaryBackgroundColor)
                .cornerRadius(12)
            }
        }
    }
    
    private var habitsContent: some View {
        VStack(spacing: 16) {
            // Habit completion stats
            ForEach(habitStore.habits.prefix(5)) { habit in
                HabitAnalyticsCard(habit: habit)
            }
            
            if habitStore.habits.isEmpty {
                EmptyAnalyticsView(
                    icon: "brain.fill",
                    title: "No Habits Yet",
                    message: "Start tracking habits to see analytics here"
                )
            }
        }
    }
    
    private var tasksContent: some View {
        VStack(spacing: 16) {
            let completedTasks = taskStore.tasks.filter { $0.isCompleted }.count
            let totalTasks = taskStore.tasks.count
            
            if totalTasks > 0 {
                TaskAnalyticsCard(
                    completedTasks: completedTasks,
                    totalTasks: totalTasks,
                    overdueTasks: getOverdueTasks()
                )
            } else {
                EmptyAnalyticsView(
                    icon: "list.bullet.clipboard.fill",
                    title: "No Tasks Yet",
                    message: "Create tasks to see analytics here"
                )
            }
        }
    }
    
    private var moodContent: some View {
        VStack(spacing: 16) {
            let moodStats = moodStore.getMoodStats(for: selectedPeriod)
            
            if moodStats.totalEntries > 0 {
                MoodAnalyticsCard(stats: moodStats)
            } else {
                EmptyAnalyticsView(
                    icon: "heart.circle.fill",
                    title: "No Mood Entries",
                    message: "Log your moods to see analytics here"
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getOverallCompletionRate() -> Double {
        let totalTasks = taskStore.tasks.count
        guard totalTasks > 0 else { return 0 }
        let completedTasks = taskStore.tasks.filter { $0.isCompleted }.count
        return (Double(completedTasks) / Double(totalTasks)) * 100
    }
    
    private func getOverdueTasks() -> Int {
        return taskStore.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < Date() && !task.isCompleted
        }.count
    }
    
    private func getDayLetter(_ day: Int) -> String {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        return days[day]
    }
}

// MARK: - Supporting Views
struct OverviewStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.textColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}

struct HabitAnalyticsCard: View {
    let habit: Habit
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(themeManager.textColor)
                Spacer()
                Text("\(habit.goal, specifier: "%.0f") \(habit.unit)")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            // Progress bar placeholder
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(themeManager.secondaryBackgroundColor)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(themeManager.accentColor)
                        .frame(width: geometry.size.width * 0.7, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}

struct TaskAnalyticsCard: View {
    let completedTasks: Int
    let totalTasks: Int
    let overdueTasks: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Task Progress")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    Text("\(completedTasks) of \(totalTasks) completed")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                Spacer()
                
                if overdueTasks > 0 {
                    VStack {
                        Text("\(overdueTasks)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Overdue")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            ProgressView(value: Double(completedTasks), total: Double(totalTasks))
                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.accentColor))
        }
        .padding()
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}

struct MoodAnalyticsCard: View {
    let stats: MoodStats
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Overview")
                .font(.headline)
                .foregroundColor(themeManager.textColor)
            
            HStack(spacing: 20) {
                VStack {
                    Text(String(format: "%.1f", stats.averageIntensity))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textColor)
                    Text("Avg Intensity")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                if let mostCommon = stats.mostCommonCategory {
                    VStack {
                        Image(systemName: mostCommon.symbol)
                            .font(.title2)
                            .foregroundColor(Color(hex: mostCommon.color))
                        Text(mostCommon.rawValue)
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}

struct EmptyAnalyticsView: View {
    let icon: String
    let title: String
    let message: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(themeManager.secondaryTextColor)
            
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.textColor)
            
            Text(message)
                .font(.body)
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}
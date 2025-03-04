import SwiftUI

extension Color {
    init(hex: String) {
        // Remove unwanted characters and convert to uppercase
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit), e.g., "F80"
            (a, r, g, b) = (255, (int >> 8) * 17,
                                   (int >> 4 & 0xF) * 17,
                                   (int & 0xF) * 17)
        case 6: // RGB (24-bit), e.g., "FF5733"
            (a, r, g, b) = (255, int >> 16,
                                   int >> 8 & 0xFF,
                                   int & 0xFF)
        case 8: // ARGB (32-bit), e.g., "CCFF5733"
            (a, r, g, b) = (int >> 24,
                                   int >> 16 & 0xFF,
                                   int >> 8 & 0xFF,
                                   int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

@main
struct MyHabitTrackerApp: App {
    
    init() {
            // Set unselected tab icon color to white
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
            // Optionally, set the tab bar background to match your app's background color
            UITabBar.appearance().barTintColor = UIColor(
                red: 49/255,
                green: 54/255,
                blue: 63/255,
                alpha: 1.0
            )
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            // MARK: - Habits
            HabitsView()
                .tabItem {
                    Image(systemName: "brain.fill")
                    Text("Habits")
                }
            
            // MARK: - Tasks
            TasksView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Tasks")
                }
            
            // MARK: - Focus
            FocusView()
                .tabItem {
                    Image(systemName: "eye")
                    Text("Focus")
                }
            
            // MARK: - Mood
            MoodView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Mood")
                }
            
            // MARK: - Settings
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(Color(hex: "836FFF"))
    }
}

// MARK: - Habits View
struct HabitsView: View {
    @State private var selectedDate: Date = Date()
    @State private var habits: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                VStack {
                    // Display the top selected date (e.g., "March 3")
                    Text(Formatter.displayDate.string(from: selectedDate))
                        .font(.custom("Varela Round", size: 34))
                        .padding(.top)
                        .foregroundColor(.white)
                    
                    // Horizontal scroll of dates.
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(getWeekDates(for: selectedDate), id: \.self) { date in
                                VStack(spacing: 4) {
                                    Text(Formatter.dayOfMonth.string(from: date))
                                        .frame(width: 40, height: 40)
                                        .font(.custom("Varela Round", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(isSameDay(date, selectedDate) ? .white : .primary)
                                        .background(
                                            Circle()
                                                .fill(isSameDay(date, selectedDate) ? Color(hex: "836FFF") : Color.clear)
                                        )
                                    
                                    Text(Formatter.dayOfWeek.string(from: date))
                                        .font(.custom("Varela Round", size: 16))
                                        .foregroundColor(.gray)
                                }
                                .onTapGesture {
                                    selectedDate = date
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Display habits if available or a placeholder message.
                    if habits.isEmpty {
                        Spacer()
                        Text("You don't have any habits yet.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    } else {
                        List(habits, id: \.self) { habit in
                            Text(habit)
                        }
                    }
                    
                    // Button to add a new habit
                    Button(action: {
                        // Handle creating a new habit
                    }) {
                        Text("Add a new habit")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex:"836FFF"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Utility Methods
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func getWeekDates(for referenceDate: Date) -> [Date] {
        let calendar = Calendar.current
        let offsets = -3...3
        return offsets.compactMap {
            calendar.date(byAdding: .day, value: $0, to: referenceDate)
        }
    }
}

// MARK: - Tasks View Placeholder
struct TasksView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                Text("Tasks Placeholder")
                    .foregroundColor(.white)
                    .navigationTitle("Tasks")
            }
        }
    }
}

// MARK: - Focus View Placeholder
struct FocusView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                Text("Focus Placeholder")
                    .foregroundColor(.white)
                    .navigationTitle("Focus")
            }
        }
    }
}

// MARK: - Mood View Placeholder
struct MoodView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                Text("Mood Placeholder")
                    .foregroundColor(.white)
                    .navigationTitle("Mood")
            }
        }
    }
}

// MARK: - Settings View Placeholder
struct SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                Text("Settings Placeholder")
                    .foregroundColor(.white)
                    .navigationTitle("Settings")
            }
        }
    }
}
    
    // MARK: - Utility Methods

    /// Check if two Date objects fall on the same calendar day.
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    /// Return an array of dates from -3 days to +3 days around the reference date.
    /// You can expand this range if you'd like to allow more scrolling.
    func getWeekDates(for referenceDate: Date) -> [Date] {
        let calendar = Calendar.current
        let offsets = -3...3
        return offsets.compactMap {
            calendar.date(byAdding: .day, value: $0, to: referenceDate)
        }
    }

// MARK: - Date Formatters
struct Formatter {
    // e.g. "March 3"
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()

    // e.g. "3"
    static let dayOfMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    // e.g. "Mon", "Tue", etc.
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

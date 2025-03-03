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
                    Image(systemName: "square.grid.2x2")
                    Text("Habits")
                }
            
            // MARK: - Tasks
            Text("Tasks")
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Tasks")
                }
            
            // MARK: - Focus
            Text("Focus")
                .tabItem {
                    Image(systemName: "eye")
                    Text("Focus")
                }
            
            // MARK: - Mood
            Text("Mood")
                .tabItem {
                    Image(systemName: "smiley")
                    Text("Mood")
                }
            
            // MARK: - Settings
            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

// MARK: - Habits View
struct HabitsView: View {
    // The date that is currently selected.
    @State private var selectedDate: Date = Date()

    // A placeholder array to demonstrate habit listings.
    @State private var habits: [String] = []

    var body: some View {
        NavigationView {
            VStack {
                // Display the top selected date (e.g., "March 3").
                Text(Formatter.displayDate.string(from: selectedDate))
                    .font(.title)
                    .padding(.top)

                // Horizontal scroll of dates.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Generate the dates for a 7-day range around the selected date.
                        ForEach(getWeekDates(for: selectedDate), id: \.self) { date in
                            VStack(spacing: 4) {
                                // Day of month in a circle if selected.
                                Text(Formatter.dayOfMonth.string(from: date))
                                    .frame(width: 40, height: 40)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSameDay(date, selectedDate) ? .white : .primary)
                                    .background(
                                        Circle()
                                            .fill(isSameDay(date, selectedDate) ? Color.blue : Color.clear)
                                    )

                                // Day of the week abbreviation (Mon, Tue, etc.)
                                Text(Formatter.dayOfWeek.string(from: date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .onTapGesture {
                                // Update the selected date
                                selectedDate = date
                            }
                        }
                    }
                    // This modifier makes the HStack expand to the available width and centers its content.
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)

                // If there are habits, display them. Otherwise, show a placeholder message.
                if habits.isEmpty {
                    Spacer()
                    Text("You don't have any habits yet.\nTap \"Add a new habit\" to add your first habit.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                } else {
                    // Display habits in a List or other custom layout
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
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
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

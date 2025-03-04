import SwiftUI

// MARK: - Extensions and Utilities

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17,
                                   (int >> 4 & 0xF) * 17,
                                   (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16,
                                   int >> 8 & 0xFF,
                                   int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - Habit Model and Data Source

struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var isNew: Bool = false
}

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
}

// MARK: - Task Model and Data Source

enum TaskPriority: String, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var id: String { rawValue }
}

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var description: String = ""
    var dueDate: Date? = nil
    var priority: TaskPriority = .medium
    var isCompleted: Bool = false
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
}

// MARK: - Main App

@main
struct MyHabitTrackerApp: App {
    @StateObject private var habitStore = HabitStore()
    @StateObject private var taskStore = TaskStore()
    
    init() {
        // Set unselected tab icon color to EEEEEE (hex)
        UITabBar.appearance().unselectedItemTintColor = UIColor(
            red: 238/255,
            green: 238/255,
            blue: 238/255,
            alpha: 1.0
        )
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
                .environmentObject(habitStore)
                .environmentObject(taskStore)
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    var body: some View {
        TabView {
            // Habits tab
            HabitsView()
                .tabItem {
                    Image(systemName: "brain.fill")
                    Text("Habits")
                }
            // Tasks tab
            TasksView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Tasks")
                }
            // Focus tab
            FocusView()
                .tabItem {
                    Image(systemName: "eye")
                    Text("Focus")
                }
            // Mood tab
            MoodView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Mood")
                }
            // Settings tab
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
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedDate: Date = Date()
    @State private var showNewHabitSheet: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                
                VStack {
                    // Top selected date
                    Text(Formatter.displayDate.string(from: selectedDate))
                        .font(.custom("Varela Round", size: 34))
                        .padding(.top)
                        .foregroundColor(Color(hex: "EEEEEE"))
                    
                    // Horizontal scroll of dates
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(getWeekDates(for: selectedDate), id: \.self) { date in
                                VStack(spacing: 4) {
                                    Text(Formatter.dayOfMonth.string(from: date))
                                        .frame(width: 40, height: 40)
                                        .font(.custom("Varela Round", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(
                                            isSameDay(date, selectedDate)
                                                ? Color(hex: "EEEEEE")
                                                : .primary
                                        )
                                        .background(
                                            Circle()
                                                .fill(
                                                    isSameDay(date, selectedDate)
                                                        ? Color(hex: "836FFF")
                                                        : Color.clear
                                                )
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
                    
                    // List of habits or placeholder
                    if habitStore.habits.isEmpty {
                        Spacer()
                        Text("You don't have any habits yet.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    } else {
                        List {
                            ForEach(habitStore.habits) { habit in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(hex: "EEEEEE"))
                                    Text(habit.name)
                                        .foregroundColor(Color(hex: "222831"))
                                        .padding()
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(Color(hex: "31363F"))
                    }
                    
                    // Button to add a new habit
                    Button(action: {
                        showNewHabitSheet = true
                    }) {
                        Text("Add a new habit")
                            .foregroundColor(Color(hex: "EEEEEE"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "836FFF"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showNewHabitSheet) {
            NewHabitView()
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

// MARK: - New Habit View

struct NewHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitStore: HabitStore
    @State private var habitName: String = ""
    @State private var goal: String = ""
    @State private var frequencySelection: Int = 0  // 0: Daily, 1: Weekly, 2: Custom
    @State private var timePreference: Date = Date()
    @State private var remindersOn: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Name")) {
                    TextField("e.g., Drink 8 glasses of water", text: $habitName)
                }
                Section(header: Text("Goal (Optional)")) {
                    TextField("Enter your daily goal", text: $goal)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Frequency")) {
                    Picker("Frequency", selection: $frequencySelection) {
                        Text("Daily").tag(0)
                        Text("Weekly").tag(1)
                        Text("Custom").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Schedule")) {
                    DatePicker("Select Time", selection: $timePreference, displayedComponents: .hourAndMinute)
                }
                Section(header: Text("Reminders")) {
                    Toggle("Enable Reminders", isOn: $remindersOn)
                }
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Add a New Habit", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter a habit name"
                    } else {
                        let newHabit = Habit(name: habitName, isNew: true)
                        habitStore.habits.append(newHabit)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

// MARK: - Tasks View

struct TasksView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var showingNewTask = false
    @State private var selectedFilter = "All"
    
    let filters = ["All", "Today", "Overdue", "Completed"]
    
    var filteredTasks: [Task] {
        switch selectedFilter {
        case "Today":
            let today = Calendar.current.startOfDay(for: Date())
            return taskStore.tasks.filter {
                guard let due = $0.dueDate else { return false }
                return Calendar.current.isDate(due, inSameDayAs: today)
            }
        case "Overdue":
            return taskStore.tasks.filter {
                if let due = $0.dueDate {
                    return due < Date() && !$0.isCompleted
                }
                return false
            }
        case "Completed":
            return taskStore.tasks.filter { $0.isCompleted }
        default:
            return taskStore.tasks
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F").ignoresSafeArea()
                VStack {
                    // Filter Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(filters, id: \.self) { filter in
                                Text(filter)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(selectedFilter == filter ? Color(hex: "836FFF") : Color.clear)
                                    .foregroundColor(selectedFilter == filter ? Color(hex: "EEEEEE") : .gray)
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        selectedFilter = filter
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Task List
                    if filteredTasks.isEmpty {
                        Spacer()
                        Text("No tasks available.")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredTasks) { task in
                                TaskRow(task: task)
                                    .listRowBackground(Color(hex: "31363F"))
                                    .onTapGesture {
                                        // Optionally open task details here.
                                    }
                            }
                            .onDelete(perform: deleteTask)
                        }
                        .listStyle(PlainListStyle())
                        .background(Color(hex: "31363F"))
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingNewTask = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color(hex: "836FFF"))
                        }
                    }
                }
                .sheet(isPresented: $showingNewTask) {
                    NewTaskView()
                        .environmentObject(taskStore)
                }
            }
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        taskStore.tasks.remove(atOffsets: offsets)
    }
}

// MARK: - Task Row

struct TaskRow: View {
    @EnvironmentObject var taskStore: TaskStore
    var task: Task
    
    var body: some View {
        HStack {
            Button(action: {
                toggleCompletion()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            VStack(alignment: .leading) {
                Text(task.title)
                    .fontWeight(task.isCompleted ? .light : .bold)
                    .strikethrough(task.isCompleted, color: Color(hex: "EEEEEE"))
                    .foregroundColor(Color(hex: "EEEEEE"))
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: taskDateFormatter)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "EEEEEE"))
                }
            }
            Spacer()
            Text(task.priority.rawValue)
                .font(.caption)
                .padding(4)
                .background(priorityColor(task.priority))
                .cornerRadius(4)
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
        .background(Color(hex: "31363F"))
    }
    
    func toggleCompletion() {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            taskStore.tasks[index].isCompleted.toggle()
        }
    }
    
    func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return Color.red
        case .medium: return Color.orange
        case .low: return Color.blue
        }
    }
}

let taskDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - New Task View

struct NewTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskStore: TaskStore
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var setDueDate: Bool = false
    @State private var selectedPriority: TaskPriority = .medium
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Title")) {
                    TextField("Enter task title", text: $title)
                }
                Section(header: Text("Description (Optional)")) {
                    TextField("Enter description", text: $description)
                }
                Section {
                    Toggle("Set Due Date", isOn: $setDueDate)
                    if setDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveTask()
            })
        }
    }
    
    func saveTask() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a task title"
            return
        }
        
        var newTask = Task(title: title, description: description, priority: selectedPriority)
        if setDueDate {
            newTask.dueDate = dueDate
        }
        taskStore.tasks.append(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Focus View

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

// MARK: - Mood View

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

// MARK: - Settings View

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

// MARK: - Date Formatters

struct Formatter {
    // e.g., "March 3"
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
    
    // e.g., "3"
    static let dayOfMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    // e.g., "Mon", "Tue", etc.
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HabitStore())
            .environmentObject(TaskStore())
    }
}

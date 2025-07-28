import SwiftUI

struct DataExportView: View {
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var moodStore: MoodStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFormat: ExportFormat = .json
    @State private var selectedData: Set<DataType> = [.habits, .tasks, .mood]
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        
        var icon: String {
            switch self {
            case .json: return "doc.text.fill"
            case .csv: return "tablecells.fill"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .csv: return "csv"
            }
        }
    }
    
    enum DataType: String, CaseIterable {
        case habits = "Habits"
        case tasks = "Tasks"  
        case mood = "Mood Entries"
        
        var icon: String {
            switch self {
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
                
                Form {
                    // Export Format Section
                    Section(header: sectionHeader("Export Format")) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            HStack {
                                Image(systemName: format.icon)
                                    .foregroundColor(themeManager.accentColor)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading) {
                                    Text(format.rawValue)
                                        .foregroundColor(themeManager.textColor)
                                    Text("Export as \(format.rawValue) file")
                                        .font(.caption)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                if selectedFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(themeManager.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedFormat = format
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    
                    // Data Selection Section
                    Section(header: sectionHeader("Select Data to Export")) {
                        ForEach(DataType.allCases, id: \.self) { dataType in
                            HStack {
                                Image(systemName: dataType.icon)
                                    .foregroundColor(themeManager.accentColor)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading) {
                                    Text(dataType.rawValue)
                                        .foregroundColor(themeManager.textColor)
                                    Text(getDataCount(for: dataType))
                                        .font(.caption)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { selectedData.contains(dataType) },
                                    set: { isOn in
                                        if isOn {
                                            selectedData.insert(dataType)
                                        } else {
                                            selectedData.remove(dataType)
                                        }
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    
                    // Export Info Section
                    Section(header: sectionHeader("Export Information")) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(themeManager.accentColor)
                                Text("What's included in your export:")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                            }
                            
                            if selectedData.contains(.habits) {
                                exportInfoRow(
                                    icon: "brain.fill",
                                    title: "Habits",
                                    description: "All habit data including progress, goals, and settings"
                                )
                            }
                            
                            if selectedData.contains(.tasks) {
                                exportInfoRow(
                                    icon: "list.bullet.clipboard.fill",
                                    title: "Tasks",
                                    description: "All tasks with completion status, due dates, and priorities"
                                )
                            }
                            
                            if selectedData.contains(.mood) {
                                exportInfoRow(
                                    icon: "heart.circle.fill",
                                    title: "Mood Entries",
                                    description: "All mood logs with categories, notes, and timestamps"
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                }
                .scrollContentBackground(.hidden)
                .background(themeManager.backgroundColor)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Export") {
                    exportData()
                }
                .foregroundColor(themeManager.accentColor)
                .disabled(selectedData.isEmpty)
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(themeManager.textColor)
    }
    
    private func exportInfoRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(themeManager.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textColor)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
    }
    
    private func getDataCount(for dataType: DataType) -> String {
        switch dataType {
        case .habits:
            let count = habitStore.habits.count
            return "\(count) habit\(count != 1 ? "s" : "")"
        case .tasks:
            let count = taskStore.tasks.count
            return "\(count) task\(count != 1 ? "s" : "")"
        case .mood:
            let count = moodStore.moodEntries.count
            return "\(count) entr\(count != 1 ? "ies" : "y")"
        }
    }
    
    private func exportData() {
        var exportData: [String: Any] = [:]
        
        // Add metadata
        exportData["export_date"] = ISO8601DateFormatter().string(from: Date())
        exportData["app_version"] = "1.0.0"
        exportData["format"] = selectedFormat.rawValue
        
        // Add selected data
        if selectedData.contains(.habits) {
            exportData["habits"] = habitStore.habits.map { habit in
                [
                    "id": habit.id.uuidString,
                    "name": habit.name,
                    "creation_date": ISO8601DateFormatter().string(from: habit.creationDate),
                    "goal": habit.goal,
                    "unit": habit.unit,
                    "frequency": habit.frequency.description,
                    "reminder": habit.reminder,
                    "daily_progress": habit.dailyProgress
                ]
            }
        }
        
        if selectedData.contains(.tasks) {
            exportData["tasks"] = taskStore.tasks.map { task in
                var taskData: [String: Any] = [
                    "id": task.id.uuidString,
                    "title": task.title,
                    "description": task.description,
                    "is_completed": task.isCompleted,
                    "priority": task.priority.rawValue
                ]
                
                if let dueDate = task.dueDate {
                    taskData["due_date"] = ISO8601DateFormatter().string(from: dueDate)
                }
                
                return taskData
            }
        }
        
        if selectedData.contains(.mood) {
            exportData["mood_entries"] = moodStore.moodEntries.map { entry in
                [
                    "id": entry.id.uuidString,
                    "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                    "category": entry.category.rawValue,
                    "subcategory": entry.subcategory,
                    "intensity": entry.intensity,
                    "notes": entry.notes,
                    "triggers": entry.triggers.map { $0.rawValue },
                    "location": entry.location?.rawValue ?? "",
                    "activities": entry.activities
                ]
            }
        }
        
        // Generate file
        switch selectedFormat {
        case .json:
            exportJSON(data: exportData)
        case .csv:
            exportCSV(data: exportData)
        }
    }
    
    private func exportJSON(data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let fileName = "positrack_export_\(Date().timeIntervalSince1970).json"
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            
            try jsonData.write(to: url)
            exportURL = url
            showingShareSheet = true
        } catch {
            print("Export error: \(error)")
        }
    }
    
    private func exportCSV(data: [String: Any]) {
        // Simplified CSV export - would need more complex implementation for full CSV support
        var csvContent = "PosiTrack Data Export\n"
        csvContent += "Export Date: \(ISO8601DateFormatter().string(from: Date()))\n\n"
        
        // Add basic CSV data (simplified version)
        if let habits = data["habits"] as? [[String: Any]] {
            csvContent += "Habits:\n"
            csvContent += "Name,Goal,Unit,Creation Date\n"
            for habit in habits {
                csvContent += "\(habit["name"] ?? ""),\(habit["goal"] ?? ""),\(habit["unit"] ?? ""),\(habit["creation_date"] ?? "")\n"
            }
            csvContent += "\n"
        }
        
        if let tasks = data["tasks"] as? [[String: Any]] {
            csvContent += "Tasks:\n"
            csvContent += "Title,Description,Priority,Completed,Due Date\n"
            for task in tasks {
                csvContent += "\(task["title"] ?? ""),\(task["description"] ?? ""),\(task["priority"] ?? ""),\(task["is_completed"] ?? ""),\(task["due_date"] ?? "")\n"
            }
            csvContent += "\n"
        }
        
        let fileName = "positrack_export_\(Date().timeIntervalSince1970).csv"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
            showingShareSheet = true
        } catch {
            print("CSV Export error: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


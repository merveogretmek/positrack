//
//  NewTaskView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct NewTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var setDueDate: Bool = false
    @State private var selectedPriority: TaskPriority = .medium
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                Form {
                    Section(header: Text("Task Title").foregroundColor(themeManager.textColor)) {
                        ZStack(alignment: .leading) {
                            if title.isEmpty {
                                Text("Enter task title")
                                    .foregroundColor(themeManager.textColor)
                            }
                            TextField("", text: $title)
                                .foregroundColor(themeManager.textColor)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    
                    Section(header: Text("Description (Optional)").foregroundColor(themeManager.textColor)) {
                        ZStack(alignment: .leading) {
                            if description.isEmpty {
                                Text("Enter description")
                                    .foregroundColor(themeManager.textColor)
                            }
                            TextField("", text: $description)
                                .foregroundColor(themeManager.textColor)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    Section(header: Text("Due Date").foregroundColor(themeManager.textColor)) {
                        Toggle("Set Due Date", isOn: $setDueDate)
                            .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                            .foregroundColor(themeManager.textColor)
                        if setDueDate {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .foregroundColor(themeManager.textColor)
                                .environment(\.colorScheme, .dark)
                        }
                    }
                    .listRowBackground(themeManager.backgroundColor)
                    Section(header: Text("Priority").foregroundColor(themeManager.textColor)) {
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(TaskPriority.allCases) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onAppear {
                            let normalAttributes: [NSAttributedString.Key: Any] = [
                                .foregroundColor: UIColor(themeManager.textColor)
                            ]
                            let selectedAttributes: [NSAttributedString.Key: Any] = [
                                .foregroundColor: UIColor(themeManager.textColor)
                            ]
                            UISegmentedControl.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
                            UISegmentedControl.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
                            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(themeManager.accentColor)
                        }
                    }
                    .listRowBackground(themeManager.backgroundColor)
                    
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        .listRowBackground(themeManager.backgroundColor)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(themeManager.backgroundColor)
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

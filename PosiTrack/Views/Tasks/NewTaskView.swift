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
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var setDueDate: Bool = false
    @State private var selectedPriority: TaskPriority = .medium
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F").ignoresSafeArea()
                Form {
                    Section(header: Text("Task Title").foregroundColor(Color(hex: "EEEEEE"))) {
                        ZStack(alignment: .leading) {
                            if title.isEmpty {
                                Text("Enter task title")
                                    .foregroundColor(Color(hex: "EEEEEE"))
                            }
                            TextField("", text: $title)
                                .foregroundColor(Color(hex: "EEEEEE"))
                        }
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    Section(header: Text("Description (Optional)").foregroundColor(Color(hex: "EEEEEE"))) {
                        ZStack(alignment: .leading) {
                            if description.isEmpty {
                                Text("Enter description")
                                    .foregroundColor(Color(hex: "EEEEEE"))
                            }
                            TextField("", text: $description)
                                .foregroundColor(Color(hex: "EEEEEE"))
                        }
                    }
                    .listRowBackground(Color(hex: "222831"))
                    Section(header: Text("Due Date").foregroundColor(Color(hex: "EEEEEE"))) {
                        Toggle("Set Due Date", isOn: $setDueDate)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "836FFF")))
                            .foregroundColor(Color(hex: "EEEEEE"))
                        if setDueDate {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .foregroundColor(Color(hex: "EEEEEE"))
                                .environment(\.colorScheme, .dark)
                        }
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    Section(header: Text("Priority").foregroundColor(Color(hex: "EEEEEE"))) {
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(TaskPriority.allCases) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onAppear {
                            let normalAttributes: [NSAttributedString.Key: Any] = [
                                .foregroundColor: UIColor(Color(hex: "EEEEEE"))
                            ]
                            let selectedAttributes: [NSAttributedString.Key: Any] = [
                                .foregroundColor: UIColor(Color(hex: "EEEEEE"))
                            ]
                            UISegmentedControl.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
                            UISegmentedControl.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
                            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color(hex: "836FFF"))
                        }
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        .listRowBackground(Color(hex: "31363F"))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(hex: "31363F"))
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

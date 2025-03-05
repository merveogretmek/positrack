//
//  TasksView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var showingNewTask = false
    @State private var selectedFilter = "All"
    @State private var selectedPriorityFilter = "All"  // Priority

    let filters = ["All", "Today", "Overdue", "Completed"]
    let priorityFilters = ["All", "High", "Medium", "Low"]

    var filteredTasks: [Task] {
        var tasks: [Task]
        switch selectedFilter {
        case "Today":
            let today = Calendar.current.startOfDay(for: Date())
            tasks = taskStore.tasks.filter {
                guard let due = $0.dueDate else { return false }
                return Calendar.current.isDate(due, inSameDayAs: today)
            }
        case "Overdue":
            tasks = taskStore.tasks.filter {
                if let due = $0.dueDate {
                    return due < Date() && !$0.isCompleted
                }
                return false
            }
        case "Completed":
            tasks = taskStore.tasks.filter { $0.isCompleted }
        default:
            tasks = taskStore.tasks
        }

        // Priority filter
        if selectedPriorityFilter != "All" {
            tasks = tasks.filter { $0.priority.rawValue == selectedPriorityFilter }
        }
        return tasks
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F").ignoresSafeArea()
                VStack(alignment: .leading) {
                    // Time-based filter bar
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

                    // Priority filter dropdown
                    HStack {
                        Text("Filter by Priority:")
                            .foregroundColor(Color(hex: "EEEEEE"))
                        Menu {
                            ForEach(priorityFilters, id: \.self) { filter in
                                Button(action: {
                                    selectedPriorityFilter = filter
                                }) {
                                    Text(filter)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedPriorityFilter)
                                Image(systemName: "chevron.down")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(hex: "836FFF"))
                            .foregroundColor(Color(hex: "EEEEEE"))
                            .cornerRadius(20)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Task list or placeholder
                    if filteredTasks.isEmpty {
                        Spacer()
                        Text("No tasks available.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredTasks) { task in
                                TaskRow(task: task)
                                    .listRowBackground(Color(hex: "31363F"))
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

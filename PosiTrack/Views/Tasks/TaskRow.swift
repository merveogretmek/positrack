//
//  TaskRow.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

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
                    let isOverdue = dueDate < Date() && !task.isCompleted
                    Text("Due: \(dueDate, formatter: taskDateFormatter)")
                        .font(.caption)
                        .foregroundColor(isOverdue ? .red: Color(hex: "EEEEEE"))
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

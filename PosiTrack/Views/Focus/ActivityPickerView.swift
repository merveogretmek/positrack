//
//  ActivityPickerView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

enum ActiveFocusSheet: Identifiable {
    case settings
    case activityPicker
    
    var id: Int { hashValue }
}

struct ActivityPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitStore: HabitStore
    var onSelect: (String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    onSelect("General Focus")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("General Focus")
                }
                ForEach(habitStore.habits) { habit in
                    Button(action: {
                        onSelect(habit.name)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(habit.name)
                    }
                }
            }
            .navigationTitle("Select Activity")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

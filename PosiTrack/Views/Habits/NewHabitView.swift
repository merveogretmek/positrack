//
//  NewHabitView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

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
            ZStack {
                // Set the overall background color
                Color(hex: "31363F")
                    .ignoresSafeArea()
                
                Form {
                    Section(header:
                        Text("Habit Name")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        CustomTextField(placeholder: "e.g., Drink 8 glasses of water", text: $habitName)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    Section(header:
                        Text("Goal (Optional)")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        CustomTextField(placeholder: "Enter your daily goal", text: $goal)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    Section(header:
                        Text("Frequency")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        Picker("Frequency", selection: $frequencySelection) {
                            Text("Daily").tag(0)
                            Text("Weekly").tag(1)
                            Text("Custom").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onAppear {
                            let purpleColor = UIColor(Color(hex: "836FFF"))
                            UISegmentedControl.appearance().selectedSegmentTintColor = purpleColor
                            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color(hex: "EEEEEE"))], for: .normal)
                            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color(hex: "EEEEEE"))], for: .selected)
                        }
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    Section(header: Text("Schedule")
                                .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        DatePicker(selection: $timePreference, displayedComponents: .hourAndMinute) {
                            Text("Select Time")
                                .foregroundColor(Color(hex: "EEEEEE"))
                        }
                        .environment(\.colorScheme, .dark)
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    Section(header:
                        Text("Reminders")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        Toggle("Enable Reminders", isOn: $remindersOn)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "836FFF")))
                            .foregroundColor(Color(hex: "EEEEEE"))
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
                // Hide the default form background so our custom background shows
                .scrollContentBackground(.hidden)
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

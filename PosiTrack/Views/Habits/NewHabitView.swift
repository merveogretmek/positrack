import SwiftUI

struct NewHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitStore: HabitStore
    
    @State private var habitName: String = ""
    @State private var unit: String = ""
    @State private var goal: String = ""
    @State private var frequencySelection: Int = 0  // 0: Daily, 1: Weekly, 2: Custom
    @State private var timePreference: Date = Date()
    @State private var remindersOn: Bool = false
    @State private var errorMessage: String = ""
    
    // Custom frequency in days
    @State private var customFrequency: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Set the overall background color
                Color(hex: "31363F")
                    .ignoresSafeArea()
                
                Form {
                    // MARK: - Habit Name
                    Section(header:
                        Text("Habit Name")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        CustomTextField(placeholder: "e.g., Drink water", text: $habitName)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // MARK: - Goal
                    Section(header:
                        Text("Goal")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        CustomTextField(placeholder: "Enter an amount", text: $goal)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // MARK: - Unit
                    Section(header:
                        Text("Unit")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        CustomTextField(placeholder: "e.g., Hours, dollars, miles/kms", text: $unit)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // MARK: - Frequency
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
                            UISegmentedControl.appearance().setTitleTextAttributes(
                                [.foregroundColor: UIColor(Color(hex: "EEEEEE"))],
                                for: .normal
                            )
                            UISegmentedControl.appearance().setTitleTextAttributes(
                                [.foregroundColor: UIColor(Color(hex: "EEEEEE"))],
                                for: .selected
                            )
                        }
                        
                        // Show a small row for Custom input
                        if frequencySelection == 2 {
                            HStack(spacing: 8) {
                                Text("Days:")
                                    .foregroundColor(Color(hex: "EEEEEE"))
                                
                                TextField(" ", text: $customFrequency)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)
                                
                                Button("Set") {
                                    // Optional: Validate or store `customFrequency` right here
                                    if let days = Int(customFrequency), days > 0 {
                                        // Valid number entered
                                    } else {
                                        // Reset or show error
                                        customFrequency = ""
                                    }
                                }
                                .foregroundColor(Color(hex: "836FFF"))
                            }
                            // Center the entire row
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    // MARK: - Schedule
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
                    
                    // MARK: - Reminders
                    Section(header:
                        Text("Reminders")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    ) {
                        Toggle("Enable Reminders", isOn: $remindersOn)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "836FFF")))
                            .foregroundColor(Color(hex: "EEEEEE"))
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    // MARK: - Error
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        .listRowBackground(Color(hex: "31363F"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitle("Add a New Habit", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // Basic validation
                    if habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter a habit name"
                        return
                    }
                    
                    // If custom frequency is selected, ensure it's not empty
                    if frequencySelection == 2 && customFrequency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter a custom frequency in days"
                        return
                    }
                    
                    // Convert goal string to a valid number
                    guard let goalValue = Double(goal), goalValue > 0 else {
                        errorMessage = "Please enter a valid number for the goal"
                        return
                    }
                    
                    if unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter the unit"
                        return
                    }
                    
                    
                    // Create and append new habit with default progress 0
                    let newHabit = Habit(name: habitName, isNew: true, progress: 0.0, goal: goalValue, unit: unit)
                    habitStore.habits.append(newHabit)
                    
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

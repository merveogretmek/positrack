import SwiftUI

struct EditHabitView: View {
    @Binding var habit: Habit
    @Environment(\.presentationMode) var presentationMode

    @State private var habitName: String = ""
    @State private var goal: String = ""
    @State private var unit: String = ""
    @State private var frequencySelection: Int = 0  // 0: Daily, 1: Weekly, 2: Custom
    @State private var timePreference: Date = Date()
    @State private var remindersOn: Bool = false
    @State private var customFrequency: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        ZStack {
            Color(hex: "31363F")
                .ignoresSafeArea()
            
            Form {
                // MARK: - Habit Name
                Section(header: Text("Habit Name")
                            .foregroundColor(Color(hex: "EEEEEE"))) {
                    CustomTextField(placeholder: "e.g., Drink water", text: $habitName)
                }
                .listRowBackground(Color(hex: "222831"))
                
                // MARK: - Goal
                Section(header: Text("Goal")
                            .foregroundColor(Color(hex: "EEEEEE"))) {
                    CustomTextField(placeholder: "Enter an amount", text: $goal)
                }
                .listRowBackground(Color(hex: "222831"))
                
                // MARK: - Unit
                Section(header: Text("Unit")
                            .foregroundColor(Color(hex: "EEEEEE"))) {
                    CustomTextField(placeholder: "e.g., Hours, dollars, miles/kms", text: $unit)
                }
                .listRowBackground(Color(hex: "222831"))
                
                // MARK: - Frequency
                Section(header: Text("Frequency")
                            .foregroundColor(Color(hex: "EEEEEE"))) {
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
                    
                    if frequencySelection == 2 {
                        HStack(spacing: 8) {
                            Text("Days:")
                                .foregroundColor(Color(hex: "EEEEEE"))
                            
                            TextField(" ", text: $customFrequency)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                            
                            Button("Set") {
                                if let days = Int(customFrequency), days > 0 {
                                    // Valid custom frequency entered.
                                } else {
                                    customFrequency = ""
                                }
                            }
                            .foregroundColor(Color(hex: "836FFF"))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listRowBackground(Color(hex: "31363F"))
                
                // MARK: - Schedule
                Section(header: Text("Schedule")
                            .foregroundColor(Color(hex: "EEEEEE"))) {
                    DatePicker(selection: $timePreference, displayedComponents: .hourAndMinute) {
                        Text("Select Time")
                            .foregroundColor(Color(hex: "EEEEEE"))
                    }
                    .environment(\.colorScheme, .dark)
                }
                .listRowBackground(Color(hex: "31363F"))
                
                // MARK: - Reminders
                Section(header: Text("Reminders")
                            .foregroundColor(Color(hex: "EEEEEE"))) {
                    Toggle("Enable Reminders", isOn: $remindersOn)
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "836FFF")))
                        .foregroundColor(Color(hex: "EEEEEE"))
                }
                .listRowBackground(Color(hex: "31363F"))
                
                // MARK: - Error Message
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
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Validate input
                    if habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter a habit name"
                        return
                    }
                    
                    if frequencySelection == 2 && customFrequency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter a custom frequency in days"
                        return
                    }
                    
                    guard let goalValue = Double(goal), goalValue > 0 else {
                        errorMessage = "Please enter a valid number for the goal"
                        return
                    }
                    
                    if unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter the unit"
                        return
                    }
                    
                    // Update habit values.
                    habit.name = habitName
                    habit.goal = goalValue
                    habit.unit = unit
                    habit.reminder = remindersOn
                    
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear {
            // Prepopulate with current habit values.
            habitName = habit.name
            goal = String(habit.goal)
            unit = habit.unit
            remindersOn = habit.reminder
            
            // Set defaults for fields not stored in Habit.
            frequencySelection = 0  // Default to Daily; adjust if needed.
            customFrequency = ""
            timePreference = Date() // Update if your Habit model stores this value.
        }
    }
}

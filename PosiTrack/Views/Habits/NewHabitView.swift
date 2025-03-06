import SwiftUI

struct NewHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitStore: HabitStore

    var startDate: Date

    @State private var habitName: String = ""
    @State private var unit: String = ""
    @State private var goal: String = ""
    @State private var frequencySelection: Int = 0  // 0: Daily, 1: Weekly
    @State private var timePreference: Date = Date()
    @State private var remindersOn: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            ZStack {
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
            .navigationBarTitle("Add a New Habit", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // Validate required fields.
                    if habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter a habit name"
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
                    
                    // Determine the frequency.
                    let selectedFrequency: HabitFrequency = frequencySelection == 0 ? .daily : .weekly
                    
                    // Create the new habit using the provided start date.
                    let newHabit = Habit(
                        creationDate: startDate,
                        name: habitName,
                        isNew: true,
                        progress: 0.0,
                        goal: goalValue,
                        unit: unit,
                        streak: 0,
                        reminder: remindersOn,
                        frequency: selectedFrequency
                    )
                    
                    habitStore.habits.append(newHabit)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

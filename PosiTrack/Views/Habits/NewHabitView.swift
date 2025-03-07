import SwiftUI

struct NewHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitStore: HabitStore
    var startDate: Date

    @State private var habitName: String = ""
    @State private var unit: String = ""
    @State private var goal: String = ""
    // 0: Daily, 1: Weekly, 2: Custom
    @State private var frequencySelection: Int = 0
    @State private var customFrequencyDays: String = ""
    @State private var timePreference: Date = Date()
    @State private var remindersOn: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()

                Form {
                    // Habit Name Section
                    Section(header: Text("Habit Name").foregroundColor(Color(hex: "EEEEEE"))) {
                        CustomTextField(placeholder: "e.g., Drink water", text: $habitName)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // Goal Section
                    Section(header: Text("Goal").foregroundColor(Color(hex: "EEEEEE"))) {
                        CustomTextField(placeholder: "Enter an amount", text: $goal)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // Unit Section
                    Section(header: Text("Unit").foregroundColor(Color(hex: "EEEEEE"))) {
                        CustomTextField(placeholder: "e.g., Hours, dollars, miles/kms", text: $unit)
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // Frequency Section
                    Section(header: Text("Frequency").foregroundColor(Color(hex: "EEEEEE"))) {
                        Picker("Frequency", selection: $frequencySelection) {
                            Text("Daily").tag(0)
                            Text("Weekly").tag(1)
                            Text("Custom").tag(2)
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
                    
                    // Show custom frequency input if Custom is selected.
                    if frequencySelection == 2 {
                        Section(header: Text("Custom Frequency (days)").foregroundColor(Color(hex: "EEEEEE"))) {
                            CustomTextField(placeholder: "e.g., 3", text: $customFrequencyDays)
                        }
                        .listRowBackground(Color(hex: "222831"))
                    }
                    
                    // Schedule Section
                    Section(header: Text("Schedule").foregroundColor(Color(hex: "EEEEEE"))) {
                        DatePicker(selection: $timePreference, displayedComponents: .hourAndMinute) {
                            Text("Select Time").foregroundColor(Color(hex: "EEEEEE"))
                        }
                        .environment(\.colorScheme, .dark)
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    // Reminders Section
                    Section(header: Text("Reminders").foregroundColor(Color(hex: "EEEEEE"))) {
                        Toggle("Enable Reminders", isOn: $remindersOn)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "836FFF")))
                            .foregroundColor(Color(hex: "EEEEEE"))
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    // Error Message Section
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
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                }),
                trailing: Button(action: {
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
                    
                    // Determine the frequency based on selection.
                    let frequency: HabitFrequency
                    switch frequencySelection {
                    case 0:
                        frequency = .daily
                    case 1:
                        frequency = .weekly
                    case 2:
                        guard let customDays = Int(customFrequencyDays), customDays > 0 else {
                            errorMessage = "Please enter a valid number for the custom frequency"
                            return
                        }
                        frequency = .custom(customDays)
                    default:
                        frequency = .daily
                    }
                    
                    // Create the new habit using the provided start date.
                    let newHabit = Habit(
                        creationDate: startDate,
                        name: habitName,
                        isNew: true,
                        dailyProgress: [:],
                        goal: goalValue,
                        unit: unit,
                        reminder: remindersOn,
                        frequency: frequency
                    )
                    
                    habitStore.habits.append(newHabit)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Save")
                })
            )
        }
    }
}

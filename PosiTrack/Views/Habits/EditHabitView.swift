import SwiftUI

struct EditHabitView: View {
    @Binding var habit: Habit
    @Environment(\.presentationMode) var presentationMode

    @State private var habitName: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Name")) {
                    TextField("Enter habit name", text: $habitName)
                }
            }
            .navigationBarTitle("Edit Habit", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                // Update the habit and dismiss
                habit.name = habitName
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // Prepopulate the text field with the habit’s current name
                habitName = habit.name
            }
        }
    }
}

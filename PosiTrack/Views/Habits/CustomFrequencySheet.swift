import SwiftUI

// Custom sheet for entering custom frequency in days
struct CustomFrequencySheet: View {
    @Binding var customFrequency: String
    @Binding var isPresented: Bool
    @State private var daysInput: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Frequency in Days")) {
                    TextField("Days", text: $daysInput)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Custom Frequency")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    if let days = Int(daysInput), days > 0 {
                        customFrequency = daysInput
                        isPresented = false
                    }
                }
            )
        }
    }
}


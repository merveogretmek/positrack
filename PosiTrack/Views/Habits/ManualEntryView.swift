import SwiftUI

struct ManualEntryView: View {
    @Binding var habit: Habit
    @Binding var manualAmount: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter the amount to add:")
                    .font(.headline)
                TextField("Amount", text: $manualAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .padding()
                    Spacer()
                    Button("Add") {
                        if let amount = Double(manualAmount) {
                            habit.progress += amount
                        }
                        manualAmount = ""
                        isPresented = false
                    }
                    .padding()
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Add Value")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

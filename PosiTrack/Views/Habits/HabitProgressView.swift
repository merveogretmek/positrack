import SwiftUI

struct HabitProgressView: View {
    @Binding var habit: Habit
    @State private var manualAmount: String = ""
    @State private var showingPopup: Bool = false
    
    // Compute progress as a fraction of the goal
    var progressPercentage: Double {
        min(habit.progress / habit.goal, 1.0)
    }
    
    // Choose gradient colors based on the progress
    var gradientColors: [Color] {
        progressPercentage > 0.5 ?
            [Color(hex: "9B59B6"), Color(hex: "836FFF")] :
            [Color(hex: "836FFF"), Color(hex: "8E44AD")]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Round progress bar with custom inner content
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)
                    
                    // Progress circle with gradient stroke
                    Circle()
                        .trim(from: 0, to: CGFloat(progressPercentage))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: gradientColors),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                        )
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.easeInOut, value: habit.progress)
                    
                    // Inner content: progress text and inline plus button for +1 increment
                    HStack(spacing: 8) {
                        Text("\(Int(habit.progress)) / \(Int(habit.goal)) \(habit.unit)")
                            .font(.headline)
                            .bold()
                        Button(action: {
                            habit.progress += 1
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .frame(width: 200, height: 200)
                .padding(.top, 50)
                
                // Control buttons under the progress circle:
                // - Plus button to bring up the manual entry popup.
                // - Reset button with a round arrow icon.
                HStack(spacing: 50) {
                    Button(action: {
                        showingPopup = true
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.largeTitle)
                    }
                    
                    Button(action: {
                        habit.progress = 0
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .font(.largeTitle)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Habit Progress")
            .sheet(isPresented: $showingPopup) {
                ManualEntryView(habit: $habit, manualAmount: $manualAmount, isPresented: $showingPopup)
            }
        }
    }
}

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

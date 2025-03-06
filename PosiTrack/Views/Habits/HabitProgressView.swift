import SwiftUI

struct HabitProgressView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var habit: Habit
    @State private var manualAmount: String = ""
    @State private var isManualEntryVisible: Bool = false

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
        ZStack {
            // Overall background color
            Color(hex: "31363F")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress circle
                ZStack {
                    // Background circle: thin and less opaque
                    Circle()
                        .stroke(Color(hex: "EEEEEE").opacity(0.5), lineWidth: 5)
                    
                    // Progress circle with gradient stroke
                    Circle()
                        .trim(from: 0, to: CGFloat(progressPercentage))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: gradientColors),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                        )
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.easeInOut, value: habit.progress)
                    
                    // Inner content: big percentage, progress text and a smaller inline plus button
                    VStack(spacing: 8) {
                        // Big percentage text in the center
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(hex: "EEEEEE"))
                        
                        // Progress text below percentage (e.g. "0 / 10000 unit")
                        Text("\(Int(habit.progress)) / \(Int(habit.goal)) \(habit.unit)")
                            .font(.headline)
                            .foregroundColor(Color(hex: "EEEEEE"))
                        
                        // Smaller inline plus button that adds 1 unit
                        Button(action: {
                            habit.progress += 1
                        }) {
                            Image(systemName: "plus")
                                .font(.body)
                                .foregroundColor(Color(hex: "EEEEEE"))
                                .padding(6)
                                .background(Circle().fill(Color(hex: "836FFF")))
                        }
                    }
                }
                .frame(width: 350, height: 350)
                .padding(.top, 50)
                
                // Control buttons: plus and reset buttons
                HStack(spacing: 30) {
                    // Left Plus Button toggles manual entry field visibility
                    Button(action: {
                        withAnimation {
                            isManualEntryVisible.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(Color(hex: "EEEEEE"))
                            .padding(8)
                            .background(Circle().fill(Color(hex: "836FFF")))
                    }
                    
                    // Right Reset Button
                    Button(action: {
                        habit.progress = 0
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(Color(hex: "EEEEEE"))
                            .padding(8)
                            .background(Circle().fill(Color(hex: "836FFF")))
                    }
                }
                .padding(.horizontal)
                
                // Manual entry field appears below the buttons
                if isManualEntryVisible {
                    HStack(spacing: 8) {
                        TextField("Enter amount", text: $manualAmount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(Color(hex: "222831")) // dark grey text
                            .padding()
                            .background(Color(hex: "EEEEEE"))  // text field background color
                            .cornerRadius(8)
                            .frame(width: 200) // Adjust width as needed
                        
                        Button("Add") {
                            if let amount = Double(manualAmount) {
                                habit.progress += amount
                            }
                            manualAmount = ""
                            withAnimation {
                                isManualEntryVisible = false
                            }
                        }
                        .padding(8)
                        .background(Capsule().fill(Color(hex: "836FFF")))
                        .foregroundColor(Color(hex: "EEEEEE"))
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        // Hide the default back button and add a custom one in the toolbar
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Left back button remains unchanged
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(habit.name)
                    }
                    .foregroundColor(Color(hex: "EEEEEE"))
                }
            }
            // Right edit button using a pencil icon
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: EditHabitView(habit: $habit)) {
                    Image(systemName: "pencil")
                        .foregroundColor(Color(hex: "EEEEEE"))
                }
            }
        }
    }
}

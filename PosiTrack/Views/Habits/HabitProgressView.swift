import SwiftUI

struct HabitProgressView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var habit: Habit
    // Optional deletion closure provided by the parent view
    var onDelete: (() -> Void)?
    
    @State private var manualAmount: String = ""
    @State private var isManualEntryVisible: Bool = false

    // Compute progress as a fraction of the daily goal.
    var progressPercentage: Double {
        min(habit.progress / habit.goal, 1.0)
    }
    
    // Choose gradient colors based on the progress.
    var gradientColors: [Color] {
        progressPercentage > 0.5 ?
            [Color(hex: "9B59B6"), Color(hex: "836FFF")] :
            [Color(hex: "836FFF"), Color(hex: "8E44AD")]
    }
    
    var body: some View {
        ZStack {
            Color(hex: "31363F")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress circle with inner content (percentage, progress text, plus button).
                ZStack {
                    Circle()
                        .stroke(Color(hex: "EEEEEE").opacity(0.5), lineWidth: 5)
                    
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
                    
                    VStack(spacing: 8) {
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(hex: "EEEEEE"))
                        
                        Text("\(Int(habit.progress)) / \(Int(habit.goal)) \(habit.unit)")
                            .font(.headline)
                            .foregroundColor(Color(hex: "EEEEEE"))
                        
                        Button(action: {
                            addProgress(amount: 1)
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
                
                // Control buttons for manual plus and reset.
                HStack(spacing: 30) {
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
                    
                    Button(action: {
                        // Reset the progress for today.
                        habit.progress = 0
                        habit.lastProgressDate = nil
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(Color(hex: "EEEEEE"))
                            .padding(8)
                            .background(Circle().fill(Color(hex: "836FFF")))
                    }
                }
                .padding(.horizontal)
                
                // Manual entry field.
                if isManualEntryVisible {
                    HStack(spacing: 8) {
                        TextField("Enter amount", text: $manualAmount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(Color(hex: "222831"))
                            .padding()
                            .background(Color(hex: "EEEEEE"))
                            .cornerRadius(8)
                            .frame(width: 200)
                        
                        Button("Add") {
                            if let amount = Double(manualAmount) {
                                addProgress(amount: amount)
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Left back button.
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
            // Right More button with a Menu containing Edit and Delete options.
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    NavigationLink(destination: EditHabitView(habit: $habit)) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        onDelete?()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(hex: "EEEEEE"))
                }
            }
        }
    }
    
    /// Adds progress by a given amount while ensuring daily reset.
    /// - On a new day, resets the progress and checks if yesterday was completed.
    /// - If yesterday wasn’t completed, resets the streak.
    /// - When the daily goal is reached, marks the day as completed and updates the streak.
    private func addProgress(amount: Double) {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
        
        // If this is a new day (progress not updated today), reset today's progress.
        if let lastProgress = habit.lastProgressDate {
            if !Calendar.current.isDate(lastProgress, inSameDayAs: today) {
                habit.progress = 0
                // Reset streak if yesterday wasn’t completed.
                if let lastCompleted = habit.lastCompletionDate,
                   !Calendar.current.isDate(lastCompleted, inSameDayAs: yesterday ?? today) {
                    habit.streak = 0
                } else if habit.lastCompletionDate == nil {
                    habit.streak = 0
                }
            }
        } else {
            // First time adding progress.
            habit.progress = 0
        }
        
        // Update the progress update timestamp.
        habit.lastProgressDate = Date()
        
        // Add the specified amount.
        habit.progress += amount
        
        // Check if the daily goal is reached.
        if habit.progress >= habit.goal {
            habit.progress = habit.goal  // Cap progress at the goal.
            // Only update the streak if not already completed today.
            if habit.lastCompletionDate == nil || !Calendar.current.isDate(habit.lastCompletionDate!, inSameDayAs: today) {
                // If yesterday was completed, streak continues; otherwise, reset to 1.
                if let lastCompleted = habit.lastCompletionDate,
                   Calendar.current.isDate(lastCompleted, inSameDayAs: yesterday ?? today) {
                    habit.streak += 1
                } else {
                    habit.streak = 1
                }
                habit.lastCompletionDate = today
            }
        }
    }
}

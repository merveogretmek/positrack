import SwiftUI

struct HabitProgressView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitStore: HabitStore
    @Binding var habit: Habit
    // Pass in the selected date from the parent view.
    var selectedDate: Date
    var onDelete: (() -> Void)?

    @State private var manualAmount: String = ""
    @State private var isManualEntryVisible: Bool = false
    @State private var isEditing = false  // For triggering the edit view

    // Retrieve progress for the selected date from the habit’s dictionary.
    var currentProgress: Double {
        let key = habit.dateKey(for: selectedDate)
        return habit.dailyProgress[key] ?? 0.0
    }
    
    var progressPercentage: Double {
        min(currentProgress / habit.goal, 1.0)
    }
    
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
                // Progress circle for the selected date.
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
                        .animation(.easeInOut, value: currentProgress)
                    
                    VStack(spacing: 8) {
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(hex: "EEEEEE"))
                        
                        Text("\(Int(currentProgress)) / \(Int(habit.goal)) \(habit.unit)")
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
                
                // Control buttons for manual entry and reset.
                HStack(spacing: 30) {
                    Button(action: {
                        withAnimation { isManualEntryVisible.toggle() }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(Color(hex: "EEEEEE"))
                            .padding(8)
                            .background(Circle().fill(Color(hex: "836FFF")))
                    }
                    
                    Button(action: {
                        resetProgress()
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
                            withAnimation { isManualEntryVisible = false }
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
            // Back button.
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(habit.name)
                    }
                    .foregroundColor(Color(hex: "EEEEEE"))
                }
            }
            // Edit and Delete actions.
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { isEditing = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { deleteHabit() }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(hex: "EEEEEE"))
                }
            }
        }
        // Hidden NavigationLink for the edit view.
        .background(
            NavigationLink(destination: EditHabitView(habit: $habit), isActive: $isEditing) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    /// Adds progress for the selected date.
    private func addProgress(amount: Double) {
        let key = habit.dateKey(for: selectedDate)
        let current = habit.dailyProgress[key] ?? 0.0
        habit.dailyProgress[key] = current + amount
    }
    
    /// Resets progress for the selected date.
    private func resetProgress() {
        let key = habit.dateKey(for: selectedDate)
        habit.dailyProgress[key] = 0.0
    }
    
    /// Deletes the habit from the store and dismisses the view.
    private func deleteHabit() {
        if let onDelete = onDelete {
            onDelete()
        } else if let index = habitStore.habits.firstIndex(where: { $0.id == habit.id }) {
            habitStore.habits.remove(at: index)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

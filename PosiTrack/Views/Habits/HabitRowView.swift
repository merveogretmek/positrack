import SwiftUI

struct HabitRowView: View {
    var habit: Habit
    var color: Color  // New property to receive the color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // First Line: Habit name and streak days
            HStack {
                Text(habit.name)
                    .font(.custom("Varela Round", size: 18))
                    .bold()
                    .foregroundColor(Color(hex: "222831"))
                Spacer()
                Text("\(habit.streak) days")
                    .font(.custom("Varela Round", size: 18))
                    .bold()
                    .foregroundColor(Color(hex: "222831"))
            }
            
            // Second Line: Progress/Goal and Unit, and reminder symbol if enabled
            HStack {
                Text("\(Int(habit.progress))/\(Int(habit.goal))")
                    .font(.custom("Varela Round", size: 16))
                    .bold()
                    .foregroundColor(Color(hex: "222831"))
                Text(habit.unit)
                    .font(.custom("Varela Round", size: 16))
                    .foregroundColor(Color(hex: "222831"))
                Spacer()
                if habit.reminder {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color(hex: "836FFF"))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color)  // Use the passed-in color for the background
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

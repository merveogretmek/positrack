import SwiftUI

struct HabitRowView: View {
    var habit: Habit
    var color: Color
    var selectedDate: Date  // The date for which progress and streak are shown

    // Use the computed streak for the selected date.
    var streak: Int {
        habit.computedStreak(upTo: selectedDate)
    }
    
    // Determine the flame color based on the computed streak.
    var flameColor: Color {
        if streak == 0 {
            return Color.gray
        } else if streak < 10 {
            return Color.yellow
        } else if streak < 50 {
            return Color.orange
        } else {
            return Color.red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // First line: Habit name and streak (flame icon + number).
            HStack {
                Text(habit.name)
                    .font(.custom("Varela Round", size: 18))
                    .bold()
                    .foregroundColor(Color(hex: "222831"))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(flameColor)
                    Text("\(streak)")
                        .font(.custom("Varela Round", size: 18))
                        .bold()
                        .foregroundColor(Color(hex: "222831"))
                }
            }
            
            // Second line: Progress/goal and unit, with reminder icon if enabled.
            HStack {
                Text("\(Int(habit.progress(on: selectedDate)))/\(Int(habit.goal))")
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
                .fill(color)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedDate: Date = Date()
    @State private var showNewHabitSheet: Bool = false
    
    // Define a palette of four colors.
    // (Feel free to adjust these hex codes as desired.)
    let colorPalette: [Color] = [
        Color(hex: "ADB2D4"), // light purple
        Color(hex: "C7D9DD"), // light blue
        Color(hex: "D5E5D5"), // light green
        Color(hex: "FCE7C8"), // light orange
        Color(hex: "FFB4A2"), // pink orange
        Color(hex: "C8AAAA"), // light brown
        Color(hex: "D7D3BF"), // light khaki
        Color(hex: "D4F6FF"), // baby blue
        Color(hex: "C9E9D2"), // bright green
        Color(hex: "FFEFEF"), // light pink
        Color(hex: "FF8080"), // pink red
        Color(hex: "95BDFF")  // bright blue
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                
                VStack {
                    // Top selected date
                    Text(Formatter.displayDate.string(from: selectedDate))
                        .font(.custom("Varela Round", size: 34))
                        .padding(.top)
                        .foregroundColor(Color(hex: "EEEEEE"))
                    
                    // Horizontal scroll of dates
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(getWeekDates(for: selectedDate), id: \.self) { date in
                                VStack(spacing: 4) {
                                    Text(Formatter.dayOfMonth.string(from: date))
                                        .frame(width: 40, height: 40)
                                        .font(.custom("Varela Round", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(
                                            isSameDay(date, selectedDate)
                                                ? Color(hex: "EEEEEE")
                                                : .primary
                                        )
                                        .background(
                                            Circle()
                                                .fill(
                                                    isSameDay(date, selectedDate)
                                                        ? Color(hex: "836FFF")
                                                        : Color.clear
                                                )
                                        )
                                    
                                    Text(Formatter.dayOfWeek.string(from: date))
                                        .font(.custom("Varela Round", size: 16))
                                        .foregroundColor(.gray)
                                }
                                .onTapGesture {
                                    selectedDate = date
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // List of habits or placeholder
                    if habitStore.habits.isEmpty {
                        Spacer()
                        Text("You don't have any habits yet.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                // Iterate over the indices so we can assign a color based on order.
                                ForEach(habitStore.habits.indices, id: \.self) { index in
                                    NavigationLink(destination: HabitProgressView(habit: $habitStore.habits[index])) {
                                        HabitRowView(
                                            habit: habitStore.habits[index],
                                            color: colorPalette[index % colorPalette.count]
                                        )
                                    }
                                }
                            }
                        }
                        .background(Color(hex: "31363F"))
                    }
                }
            }
            // Remove the navigation bar title
            .navigationBarTitle("")
            .navigationBarItems(trailing:
                Button(action: {
                    showNewHabitSheet = true
                }) {
                    Image(systemName: "plus")
                }
            )
        }
        .sheet(isPresented: $showNewHabitSheet) {
            NewHabitView()
        }
    }
    
    // MARK: - Utility Methods
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func getWeekDates(for referenceDate: Date) -> [Date] {
        let calendar = Calendar.current
        let offsets = -3...3
        return offsets.compactMap {
            calendar.date(byAdding: .day, value: $0, to: referenceDate)
        }
    }
}

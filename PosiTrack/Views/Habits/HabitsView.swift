import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedDate: Date = Date()
    @State private var showNewHabitSheet: Bool = false
    
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
                                ForEach($habitStore.habits) { $habit in
                                    NavigationLink(destination: HabitProgressView(habit: $habit)) {
                                        HStack {
                                            Text(habit.name)
                                                .foregroundColor(Color(hex: "222831"))
                                                .padding()
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "EEEEEE"))
                                        )
                                        // Add your horizontal padding here
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                    }
                                }
                            }
                        }
                        .background(Color(hex: "31363F"))

                    }
                }
            }
            // Use a navigation bar title and add a plus button on the top right
            .navigationBarTitle("") // Remove the date from the navigation bar title
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

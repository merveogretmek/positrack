import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedDate: Date = Date()
    @State private var showNewHabitSheet: Bool = false

    // Define your color palette.
    let colorPalette: [Color] = [
        Color(hex: "ADB2D4"),
        Color(hex: "C7D9DD"),
        Color(hex: "D5E5D5"),
        Color(hex: "FCE7C8"),
        Color(hex: "FFB4A2"),
        Color(hex: "C8AAAA"),
        Color(hex: "D7D3BF"),
        Color(hex: "D4F6FF"),
        Color(hex: "C9E9D2"),
        Color(hex: "FFEFEF"),
        Color(hex: "FF8080"),
        Color(hex: "95BDFF")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()

                VStack {
                    // Top selected date display.
                    Text(Formatter.displayDate.string(from: selectedDate))
                        .font(.custom("Varela Round", size: 34))
                        .padding(.top)
                        .foregroundColor(themeManager.textColor)
                    
                    // Horizontal scroll of dates.
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
                                                ? themeManager.textColor
                                                : .primary
                                        )
                                        .background(
                                            Circle()
                                                .fill(
                                                    isSameDay(date, selectedDate)
                                                        ? themeManager.accentColor
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
                    
                    // Filter habits that should display on the selected date.
                    let displayedIndices = habitStore.habits.indices.filter { habitStore.habits[$0].shouldDisplay(on: selectedDate) }
                    
                    if displayedIndices.isEmpty {
                        Spacer()
                        Text("You don't have any habits for this day.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                // Pass the selected date to the progress view.
                                ForEach(Array(displayedIndices.enumerated()), id: \.element) { (offset, index) in
                                    NavigationLink(destination: HabitProgressView(habit: $habitStore.habits[index], selectedDate: selectedDate)) {
                                        HabitRowView(
                                            habit: habitStore.habits[index],
                                            color: colorPalette[offset % colorPalette.count],
                                            selectedDate: selectedDate  // Pass the selected date here
                                        )
                                    }
                                }
                            }
                        }
                        .background(themeManager.backgroundColor)
                    }
                }
            }
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
            NewHabitView(startDate: selectedDate)
                .environmentObject(themeManager)
        }
    }
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func getWeekDates(for referenceDate: Date) -> [Date] {
        let calendar = Calendar.current
        return (-3...3).compactMap { calendar.date(byAdding: .day, value: $0, to: referenceDate) }
    }
}

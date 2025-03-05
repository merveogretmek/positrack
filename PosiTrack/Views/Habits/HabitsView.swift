//
//  HabitsView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

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
                        List {
                            ForEach(habitStore.habits) { habit in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(hex: "EEEEEE"))
                                    Text(habit.name)
                                        .foregroundColor(Color(hex: "222831"))
                                        .padding()
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(Color(hex: "31363F"))
                    }
                    
                    // Button to add a new habit
                    Button(action: {
                        showNewHabitSheet = true
                    }) {
                        Text("Add a new habit")
                            .foregroundColor(Color(hex: "EEEEEE"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "836FFF"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
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

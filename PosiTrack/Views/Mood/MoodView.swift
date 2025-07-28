//
//  MoodView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct MoodView: View {
    @EnvironmentObject var moodStore: MoodStore
    @State private var showingNewMoodEntry = false
    @State private var selectedPeriod: StatsPeriod = .week
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Quick Stats Section
                    if !moodStore.moodEntries.isEmpty {
                        quickStatsSection
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    
                    // Recent Entries Section
                    if moodStore.moodEntries.isEmpty {
                        emptyStateView
                    } else {
                        recentEntriesSection
                    }
                }
            }
            .navigationTitle("Mood")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewMoodEntry = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "836FFF"))
                    }
                }
            }
            .sheet(isPresented: $showingNewMoodEntry) {
                NewMoodEntryView()
                    .environmentObject(moodStore)
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quick Overview")
                    .font(.headline)
                    .foregroundColor(Color(hex: "EEEEEE"))
                Spacer()
            }
            
            let stats = moodStore.getMoodStats(for: selectedPeriod)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg Intensity",
                    value: String(format: "%.1f", stats.averageIntensity),
                    icon: "heart.fill",
                    color: "FF6B6B"
                )
                
                StatCard(
                    title: "Entries",
                    value: "\(stats.totalEntries)",
                    icon: "list.bullet",
                    color: "4ECDC4"
                )
                
                if let mostCommon = stats.mostCommonCategory {
                    StatCard(
                        title: "Most Common",
                        value: mostCommon.emoji,
                        icon: "chart.bar.fill",
                        color: mostCommon.color
                    )
                }
            }
        }
        .padding(.bottom)
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Entries")
                    .font(.headline)
                    .foregroundColor(Color(hex: "EEEEEE"))
                    .padding(.horizontal)
                Spacer()
            }
            
            List {
                ForEach(Array(moodStore.moodEntries.prefix(20))) { entry in
                    MoodEntryRow(entry: entry)
                        .listRowBackground(Color(hex: "31363F"))
                }
                .onDelete(perform: deleteMoodEntry)
            }
            .listStyle(PlainListStyle())
            .background(Color(hex: "31363F"))
            .scrollContentBackground(.hidden)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "moon.stars")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "836FFF"))
            
            Text("Track Your Mood")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "EEEEEE"))
            
            Text("Start logging your daily moods to understand patterns and improve your wellbeing")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingNewMoodEntry = true
            }) {
                Text("Log First Mood")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color(hex: "836FFF"))
                    .cornerRadius(25)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private func deleteMoodEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = moodStore.moodEntries[index]
            moodStore.deleteMoodEntry(entry)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: color))
                .font(.title2)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "EEEEEE"))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "222831"))
        .cornerRadius(12)
    }
}

struct MoodEntryRow: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Mood emoji and category
            VStack(spacing: 4) {
                Text(entry.category.emoji)
                    .font(.title2)
                
                Text(entry.subcategory)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.category.rawValue)
                        .font(.headline)
                        .foregroundColor(Color(hex: "EEEEEE"))
                    
                    Spacer()
                    
                    // Intensity stars
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= entry.intensity ? "star.fill" : "star")
                                .foregroundColor(star <= entry.intensity ? Color(hex: entry.category.color) : .gray)
                                .font(.caption)
                        }
                    }
                }
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(formatDate(entry.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if !entry.triggers.isEmpty {
                        Text("• \(entry.triggers.first?.rawValue ?? "")")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return "Today \(formatter.string(from: date))"
        } else if Calendar.current.isDateInYesterday(date) {
            formatter.dateFormat = "h:mm a"
            return "Yesterday \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }
}

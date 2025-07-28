//
//  ContentView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Habits tab
            HabitsView()
                .tabItem {
                    Image(systemName: "brain.fill")
                    Text("Habits")
                }
            // Tasks tab
            TasksView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Tasks")
                }
            // Focus tab
            FocusView()
                .tabItem {
                    Image(systemName: "eye")
                    Text("Focus")
                }
            // Mood tab
            MoodView()
                .tabItem {
                    Image(systemName: "heart.circle.fill")
                    Text("Mood")
                }
            // Settings tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(Color(hex: "836FFF"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HabitStore())
            .environmentObject(TaskStore())
            .environmentObject(MoodStore())
    }
}

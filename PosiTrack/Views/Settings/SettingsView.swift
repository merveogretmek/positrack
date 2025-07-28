//
//  SettingsView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var moodStore: MoodStore
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingAnalytics = false
    @State private var showingDataExport = false
    @State private var showingAbout = false
    @State private var enableNotifications = true
    @State private var reminderTime = Date()
    @State private var enableHaptics = true
    @State private var autoBackup = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                Form {
                    // Profile Section
                    profileSection
                    
                    // Appearance Section
                    appearanceSection
                    
                    // Analytics Section
                    analyticsSection
                    
                    // Notifications Section
                    notificationsSection
                    
                    // Data & Privacy Section
                    dataPrivacySection
                    
                    // Support Section
                    supportSection
                    
                    // About Section
                    aboutSection
                }
                .scrollContentBackground(.hidden)
                .background(themeManager.backgroundColor)
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView()
                .environmentObject(habitStore)
                .environmentObject(taskStore)
                .environmentObject(moodStore)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
                .environmentObject(habitStore)
                .environmentObject(taskStore)
                .environmentObject(moodStore)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
                .environmentObject(themeManager)
        }
    }
    
    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(themeManager.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome to PosiTrack")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    
                    Text("Building better habits, one day at a time")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(themeManager.secondaryBackgroundColor)
    }
    
    private var appearanceSection: some View {
        Section(header: sectionHeader("Appearance")) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 24)
                
                Text("Theme")
                    .foregroundColor(themeManager.textColor)
                
                Spacer()
                
                Menu {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button(action: {
                            themeManager.currentTheme = theme
                        }) {
                            HStack {
                                Image(systemName: theme.icon)
                                Text(theme.displayName)
                                if themeManager.currentTheme == theme {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: themeManager.currentTheme.icon)
                        Text(themeManager.currentTheme.displayName)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(themeManager.secondaryBackgroundColor)
    }
    
    private var analyticsSection: some View {
        Section(header: sectionHeader("Analytics & Insights")) {
            settingsRow(
                icon: "chart.bar.fill",
                title: "View Analytics",
                subtitle: "Detailed insights into your progress",
                action: { showingAnalytics = true }
            )
            
            settingsRow(
                icon: "square.and.arrow.up.fill",
                title: "Export Data",
                subtitle: "Export your data as CSV or JSON",
                action: { showingDataExport = true }
            )
        }
        .listRowBackground(themeManager.secondaryBackgroundColor)
    }
    
    private var notificationsSection: some View {
        Section(header: sectionHeader("Notifications & Reminders")) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading) {
                    Text("Enable Notifications")
                        .foregroundColor(themeManager.textColor)
                    Text("Get reminded about your habits and tasks")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
                
                Toggle("", isOn: $enableNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
            }
            .padding(.vertical, 4)
            
            if enableNotifications {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    Text("Daily Reminder")
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
                }
                .padding(.vertical, 4)
            }
            
            HStack {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading) {
                    Text("Haptic Feedback")
                        .foregroundColor(themeManager.textColor)
                    Text("Feel vibrations for interactions")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
                
                Toggle("", isOn: $enableHaptics)
                    .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(themeManager.secondaryBackgroundColor)
    }
    
    private var dataPrivacySection: some View {
        Section(header: sectionHeader("Data & Privacy")) {
            HStack {
                Image(systemName: "icloud.fill")
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading) {
                    Text("Auto Backup")
                        .foregroundColor(themeManager.textColor)
                    Text("Automatically backup data to iCloud")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
                
                Toggle("", isOn: $autoBackup)
                    .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
            }
            .padding(.vertical, 4)
            
            settingsRow(
                icon: "trash.fill",
                title: "Clear All Data",
                subtitle: "Permanently delete all your data",
                isDestructive: true,
                action: { showClearDataAlert() }
            )
        }
        .listRowBackground(themeManager.secondaryBackgroundColor)
    }
    
    private var supportSection: some View {
        Section(header: sectionHeader("Support")) {
            settingsRow(
                icon: "questionmark.circle.fill",
                title: "Help & FAQ",
                subtitle: "Get help and find answers",
                action: { openURL("https://support.positrack.app") }
            )
            
            settingsRow(
                icon: "envelope.fill",
                title: "Contact Support",
                subtitle: "Send feedback or report issues",
                action: { openURL("mailto:support@positrack.app") }
            )
            
            settingsRow(
                icon: "star.fill",
                title: "Rate PosiTrack",
                subtitle: "Help us improve with your review",
                action: { openURL("https://apps.apple.com/app/positrack") }
            )
        }
        .listRowBackground(themeManager.secondaryBackgroundColor)
    }
    
    private var aboutSection: some View {
        Section(header: sectionHeader("About")) {
            settingsRow(
                icon: "info.circle.fill",
                title: "About PosiTrack",
                subtitle: "Version 1.0.0",
                action: { showingAbout = true }
            )
            
            settingsRow(
                icon: "doc.text.fill",
                title: "Privacy Policy",
                subtitle: "Read our privacy policy",
                action: { openURL("https://positrack.app/privacy") }
            )
            
            settingsRow(
                icon: "doc.text.fill",
                title: "Terms of Service",
                subtitle: "Read our terms of service",
                action: { openURL("https://positrack.app/terms") }
            )
        }
        .listRowBackground(themeManager.secondaryBackgroundColor)
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(themeManager.textColor)
    }
    
    private func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : themeManager.accentColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(isDestructive ? .red : themeManager.textColor)
                        .font(.body)
                    
                    Text(subtitle)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .font(.caption)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.secondaryTextColor)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Functions
    private func showClearDataAlert() {
        // Implementation for clearing data alert
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // App Icon and Title
                        VStack(spacing: 16) {
                            Image("positrack")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .cornerRadius(24)
                                .shadow(radius: 10)
                            
                            Text("PosiTrack")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.textColor)
                            
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding(.top, 30)
                        
                        // Description
                        VStack(spacing: 16) {
                            Text("Building Better Habits")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.textColor)
                            
                            Text("PosiTrack is your comprehensive companion for building positive habits, managing tasks, and tracking your mood. Our goal is to help you create lasting change through consistent, mindful tracking.")
                                .font(.body)
                                .foregroundColor(themeManager.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Features
                        VStack(spacing: 20) {
                            Text("Features")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.textColor)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                FeatureCard(
                                    icon: "brain.fill",
                                    title: "Habit Tracking",
                                    description: "Build and maintain positive habits with detailed progress tracking"
                                )
                                
                                FeatureCard(
                                    icon: "list.bullet.clipboard.fill",
                                    title: "Task Management",
                                    description: "Organize your tasks with priorities and due dates"
                                )
                                
                                FeatureCard(
                                    icon: "heart.circle.fill",
                                    title: "Mood Logging",
                                    description: "Track your emotional wellbeing with detailed mood entries"
                                )
                                
                                FeatureCard(
                                    icon: "chart.bar.fill",
                                    title: "Analytics",
                                    description: "Gain insights into your progress and patterns"
                                )
                                
                                FeatureCard(
                                    icon: "eye.fill",
                                    title: "Focus Timer",
                                    description: "Stay focused with customizable Pomodoro sessions"
                                )
                                
                                FeatureCard(
                                    icon: "moon.stars.fill",
                                    title: "Dark Mode",
                                    description: "Beautiful interface that adapts to your preference"
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Credits
                        VStack(spacing: 16) {
                            Text("Credits")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.textColor)
                            
                            VStack(spacing: 8) {
                                Text("Developed with ❤️ using SwiftUI")
                                    .font(.body)
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                Text("SF Symbols by Apple Inc.")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                Text("Special thanks to the iOS development community")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryTextColor)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        // Contact Info
                        VStack(spacing: 12) {
                            Text("Get in Touch")
                                .font(.headline)
                                .foregroundColor(themeManager.textColor)
                            
                            Button(action: {
                                openURL("mailto:support@positrack.app")
                            }) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text("support@positrack.app")
                                }
                                .foregroundColor(themeManager.accentColor)
                            }
                            
                            Button(action: {
                                openURL("https://positrack.app")
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("positrack.app")
                                }
                                .foregroundColor(themeManager.accentColor)
                            }
                        }
                        
                        // Copyright
                        VStack(spacing: 4) {
                            Text("© 2025 PosiTrack")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            Text("All rights reserved")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(themeManager.accentColor)
            )
        }
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.accentColor)
            
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.textColor)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}
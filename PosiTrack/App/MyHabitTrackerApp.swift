import SwiftUI

@main
struct MyHabitTrackerApp: App {
    @StateObject private var habitStore = HabitStore()
    @StateObject private var taskStore = TaskStore()
    
    init() {
        // Set unselected tab icon color to EEEEEE (hex)
        UITabBar.appearance().unselectedItemTintColor = UIColor(
            red: 238/255,
            green: 238/255,
            blue: 238/255,
            alpha: 1.0
        )
        // Optionally, set the tab bar background to match your app's background color
        UITabBar.appearance().barTintColor = UIColor(
            red: 49/255,
            green: 54/255,
            blue: 63/255,
            alpha: 1.0
        )
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color(hex: "31363F"))
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "EEEEEE"))
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "EEEEEE"))
        ]
                    
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitStore)
                .environmentObject(taskStore)
        }
    }
}


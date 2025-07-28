import SwiftUI
import Foundation

// MARK: - Theme Types
enum AppTheme: String, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .system: return "gear"
        }
    }
}

// MARK: - Theme Colors
struct AppColors {
    // Dark Theme Colors
    static let darkBackground = Color(hex: "31363F")
    static let darkSecondary = Color(hex: "222831")
    static let darkAccent = Color(hex: "836FFF")
    static let darkText = Color(hex: "EEEEEE")
    static let darkTextSecondary = Color.gray
    
    // Light Theme Colors
    static let lightBackground = Color.white
    static let lightSecondary = Color(hex: "F8F9FA")
    static let lightAccent = Color(hex: "836FFF")
    static let lightText = Color(hex: "1C1C1E")
    static let lightTextSecondary = Color(hex: "8E8E93")
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
            updateSystemTheme()
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.dark.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .dark
        updateSystemTheme()
    }
    
    private func updateSystemTheme() {
        // This will be used for future system integration
        // For now, we'll handle theme colors manually in views
    }
    
    // MARK: - Color Getters
    var backgroundColor: Color {
        switch currentTheme {
        case .dark:
            return AppColors.darkBackground
        case .light:
            return AppColors.lightBackground
        case .system:
            return AppColors.darkBackground // For now, default to dark
        }
    }
    
    var secondaryBackgroundColor: Color {
        switch currentTheme {
        case .dark:
            return AppColors.darkSecondary
        case .light:
            return AppColors.lightSecondary
        case .system:
            return AppColors.darkSecondary // For now, default to dark
        }
    }
    
    var accentColor: Color {
        return AppColors.darkAccent // Keep accent color consistent
    }
    
    var textColor: Color {
        switch currentTheme {
        case .dark:
            return AppColors.darkText
        case .light:
            return AppColors.lightText
        case .system:
            return AppColors.darkText // For now, default to dark
        }
    }
    
    var secondaryTextColor: Color {
        switch currentTheme {
        case .dark:
            return AppColors.darkTextSecondary
        case .light:
            return AppColors.lightTextSecondary
        case .system:
            return AppColors.darkTextSecondary // For now, default to dark
        }
    }
    
    var isDarkMode: Bool {
        switch currentTheme {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            return true // For now, default to dark
        }
    }
}

// MARK: - Environment Key
private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            TextField("", text: $text)
                .foregroundColor(themeManager.textColor)
        }
    }
}

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(hex: "EEEEEE"))
            }
            TextField("", text: $text)
                .foregroundColor(Color(hex: "EEEEEE"))
        }
    }
}

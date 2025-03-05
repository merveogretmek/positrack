//
//  CustomFocusDurationSheet.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct CustomFocusDurationSheet: View {
    @Binding var customDuration: TimeInterval
    @Binding var isPresented: Bool
    @State private var minutesInput: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Focus Duration (minutes)")) {
                    TextField("Minutes", text: $minutesInput)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Custom Focus Duration")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    if let minutes = Double(minutesInput), minutes > 0 {
                        customDuration = minutes * 60  // convert minutes to seconds
                        isPresented = false
                    }
                }
            )
        }
    }
}

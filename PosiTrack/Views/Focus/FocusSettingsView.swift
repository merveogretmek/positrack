//
//  FocusSettingsView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct FocusSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Lengths")) {
                    HStack {
                        Text("Pomodoro:")
                        Spacer()
                        Text("25 min")
                    }
                    HStack {
                        Text("Short Focus:")
                        Spacer()
                        Text("15 min")
                    }
                    HStack {
                        Text("Long Focus:")
                        Spacer()
                        Text("50 min")
                    }
                }
                
                Section(header: Text("Break Durations")) {
                    HStack {
                        Text("Short Break:")
                        Spacer()
                        Text("5 min")
                    }
                    HStack {
                        Text("Long Break:")
                        Spacer()
                        Text("15 min")
                    }
                }
                
                Section(header: Text("Audio & Notifications")) {
                    Toggle("Enable Background Sound", isOn: .constant(true))
                    Toggle("Silence Notifications", isOn: .constant(false))
                }
            }
            .navigationBarTitle("Focus Settings", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Done") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}

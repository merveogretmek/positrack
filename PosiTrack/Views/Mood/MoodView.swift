//
//  MoodView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct MoodView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F")
                    .ignoresSafeArea()
                Text("Mood Placeholder")
                    .foregroundColor(.white)
                    .navigationTitle("Mood")
            }
        }
    }
}

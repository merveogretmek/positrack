import SwiftUI

struct NewMoodEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var moodStore: MoodStore
    
    @State private var selectedCategory: MoodCategory = .happy
    @State private var selectedSubcategory: String = ""
    @State private var intensity: Double = 3.0
    @State private var notes: String = ""
    @State private var selectedTriggers: Set<MoodTrigger> = []
    @State private var selectedLocation: MoodLocation = .home
    @State private var activities: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "31363F").ignoresSafeArea()
                
                Form {
                    // Mood Category Section
                    Section {
                        VStack(spacing: 20) {
                            // Header with animated moon icon
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(Color(hex: "836FFF"))
                                    .font(.title2)
                                
                                Text("How are you feeling right now?")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "EEEEEE"))
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                            
                            // Mood wheel-style circular layout
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(Color(hex: "222831"), lineWidth: 2)
                                    .frame(width: 280, height: 280)
                                
                                // Mood options arranged in circle
                                ForEach(Array(MoodCategory.allCases.enumerated()), id: \.element) { index, category in
                                    let angle = Double(index) * (360.0 / Double(MoodCategory.allCases.count))
                                    let radians = angle * .pi / 180
                                    let radius: CGFloat = 110
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedCategory = category
                                            selectedSubcategory = category.subcategories.first ?? ""
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    selectedCategory == category ? 
                                                    Color(hex: category.color).opacity(0.8) : 
                                                    Color(hex: "222831")
                                                )
                                                .frame(width: selectedCategory == category ? 60 : 50, height: selectedCategory == category ? 60 : 50)
                                                .shadow(
                                                    color: selectedCategory == category ? Color(hex: category.color).opacity(0.5) : Color.clear,
                                                    radius: selectedCategory == category ? 8 : 0
                                                )
                                            
                                            VStack(spacing: 2) {
                                                Text(category.emoji)
                                                    .font(.system(size: selectedCategory == category ? 24 : 20))
                                                
                                                Text(category.rawValue)
                                                    .font(.system(size: selectedCategory == category ? 8 : 7))
                                                    .fontWeight(selectedCategory == category ? .semibold : .regular)
                                                    .foregroundColor(Color(hex: "EEEEEE"))
                                            }
                                        }
                                        .scaleEffect(selectedCategory == category ? 1.1 : 1.0)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .offset(
                                        x: cos(radians) * radius,
                                        y: sin(radians) * radius
                                    )
                                }
                                
                                // Center indicator
                                if selectedCategory != .happy || !selectedSubcategory.isEmpty {
                                    Circle()
                                        .fill(Color(hex: "836FFF"))
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(1.5)
                                        .opacity(0.8)
                                }
                            }
                            .frame(height: 300)
                            
                            // Selected mood display
                            if selectedCategory != .happy || !selectedSubcategory.isEmpty {
                                HStack(spacing: 12) {
                                    Text(selectedCategory.emoji)
                                        .font(.title)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Feeling \(selectedCategory.rawValue.lowercased())")
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "EEEEEE"))
                                        
                                        Text("Tap to explore deeper feelings")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(hex: selectedCategory.color).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: selectedCategory.color).opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    .listRowInsets(EdgeInsets())
                    
                    // Subcategory Section
                    Section(header: Text("More specifically...").foregroundColor(Color(hex: "EEEEEE"))) {
                        Menu {
                            ForEach(selectedCategory.subcategories, id: \.self) { subcategory in
                                Button(action: {
                                    selectedSubcategory = subcategory
                                }) {
                                    Text(subcategory)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedSubcategory.isEmpty ? "Select specific feeling" : selectedSubcategory)
                                    .foregroundColor(selectedSubcategory.isEmpty ? .gray : Color(hex: "EEEEEE"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color(hex: "EEEEEE"))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // Intensity Section
                    Section(header: Text("Intensity (\\(Int(intensity))/5)").foregroundColor(Color(hex: "EEEEEE"))) {
                        VStack(spacing: 12) {
                            HStack {
                                Text("1")
                                    .foregroundColor(.gray)
                                Slider(value: $intensity, in: 1...5, step: 1)
                                    .accentColor(Color(hex: selectedCategory.color))
                                Text("5")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 20) {
                                ForEach(1...5, id: \.self) { level in
                                    Circle()
                                        .fill(Int(intensity) >= level ? Color(hex: selectedCategory.color) : Color.gray.opacity(0.3))
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    // Triggers Section
                    Section(header: Text("What triggered this mood?").foregroundColor(Color(hex: "EEEEEE"))) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(MoodTrigger.allCases, id: \.self) { trigger in
                                Button(action: {
                                    if selectedTriggers.contains(trigger) {
                                        selectedTriggers.remove(trigger)
                                    } else {
                                        selectedTriggers.insert(trigger)
                                    }
                                }) {
                                    Text(trigger.rawValue)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "EEEEEE"))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedTriggers.contains(trigger) ? 
                                            Color(hex: "836FFF") : 
                                            Color(hex: "222831")
                                        )
                                        .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
                    // Location Section
                    Section(header: Text("Where are you?").foregroundColor(Color(hex: "EEEEEE"))) {
                        Menu {
                            ForEach(MoodLocation.allCases, id: \.self) { location in
                                Button(action: {
                                    selectedLocation = location
                                }) {
                                    Text(location.rawValue)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedLocation.rawValue)
                                    .foregroundColor(Color(hex: "EEEEEE"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color(hex: "EEEEEE"))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // Activities Section
                    Section(header: Text("What are you doing?").foregroundColor(Color(hex: "EEEEEE"))) {
                        ZStack(alignment: .leading) {
                            if activities.isEmpty {
                                Text("e.g., Working, exercising, socializing...")
                                    .foregroundColor(Color(hex: "EEEEEE"))
                            }
                            TextField("", text: $activities)
                                .foregroundColor(Color(hex: "EEEEEE"))
                        }
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // Notes Section
                    Section(header: Text("Additional notes (optional)").foregroundColor(Color(hex: "EEEEEE"))) {
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("How are you feeling? What's on your mind?")
                                    .foregroundColor(Color(hex: "EEEEEE"))
                                    .padding(.top, 8)
                            }
                            TextEditor(text: $notes)
                                .foregroundColor(Color(hex: "EEEEEE"))
                                .frame(minHeight: 80)
                                .background(Color.clear)
                        }
                    }
                    .listRowBackground(Color(hex: "222831"))
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        .listRowBackground(Color(hex: "31363F"))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(hex: "31363F"))
            }
            .navigationTitle("Log Your Mood")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveMoodEntry()
                }
                .foregroundColor(Color(hex: "836FFF"))
            )
        }
    }
    
    private func saveMoodEntry() {
        guard !selectedSubcategory.isEmpty else {
            errorMessage = "Please select a specific feeling"
            return
        }
        
        let activityList = activities.isEmpty ? [] : 
            activities.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let newEntry = MoodEntry(
            category: selectedCategory,
            subcategory: selectedSubcategory,
            intensity: Int(intensity),
            notes: notes,
            triggers: Array(selectedTriggers),
            location: selectedLocation,
            activities: activityList
        )
        
        moodStore.addMoodEntry(newEntry)
        presentationMode.wrappedValue.dismiss()
    }
}

import SwiftUI

struct NewMoodEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var moodStore: MoodStore
    @EnvironmentObject var themeManager: ThemeManager
    
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
                themeManager.backgroundColor.ignoresSafeArea()
                
                Form {
                    // Mood Category Section
                    Section {
                        VStack(spacing: 20) {
                            // Header with animated moon icon
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(themeManager.accentColor)
                                    .font(.title2)
                                
                                Text("How are you feeling right now?")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeManager.textColor)
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                            
                            // Mood wheel-style circular layout
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(themeManager.secondaryBackgroundColor, lineWidth: 2)
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
                                                    themeManager.secondaryBackgroundColor
                                                )
                                                .frame(width: selectedCategory == category ? 60 : 50, height: selectedCategory == category ? 60 : 50)
                                                .shadow(
                                                    color: selectedCategory == category ? Color(hex: category.color).opacity(0.5) : Color.clear,
                                                    radius: selectedCategory == category ? 8 : 0
                                                )
                                            
                                            VStack(spacing: 4) {
                                                Image(systemName: category.symbol)
                                                    .font(.system(size: selectedCategory == category ? 22 : 18, weight: .medium))
                                                    .foregroundColor(
                                                        selectedCategory == category ? 
                                                        themeManager.textColor : 
                                                        Color(hex: category.color)
                                                    )
                                                
                                                Text(category.rawValue)
                                                    .font(.system(size: selectedCategory == category ? 9 : 8))
                                                    .fontWeight(selectedCategory == category ? .semibold : .regular)
                                                    .foregroundColor(themeManager.textColor)
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
                                        .fill(themeManager.accentColor)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(1.5)
                                        .opacity(0.8)
                                }
                            }
                            .frame(height: 300)
                            
                            // Selected mood display
                            if selectedCategory != .happy || !selectedSubcategory.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: selectedCategory.symbol)
                                        .font(.title)
                                        .foregroundColor(Color(hex: selectedCategory.color))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Feeling \(selectedCategory.rawValue.lowercased())")
                                            .font(.headline)
                                            .foregroundColor(themeManager.textColor)
                                        
                                        Text("Tap to explore deeper feelings")
                                            .font(.caption)
                                            .foregroundColor(themeManager.secondaryTextColor)
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
                    .listRowBackground(themeManager.backgroundColor)
                    .listRowInsets(EdgeInsets())
                    
                    // Subcategory Section
                    Section(header: Text("More specifically...").foregroundColor(themeManager.textColor)) {
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
                                    .foregroundColor(selectedSubcategory.isEmpty ? themeManager.secondaryTextColor : themeManager.textColor)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(themeManager.textColor)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    
                    // Intensity Section
                    Section(header: Text("Intensity (\\(Int(intensity))/5)").foregroundColor(themeManager.textColor)) {
                        VStack(spacing: 12) {
                            HStack {
                                Text("1")
                                    .foregroundColor(themeManager.secondaryTextColor)
                                Slider(value: $intensity, in: 1...5, step: 1)
                                    .accentColor(Color(hex: selectedCategory.color))
                                Text("5")
                                    .foregroundColor(themeManager.secondaryTextColor)
                            }
                            
                            HStack(spacing: 20) {
                                ForEach(1...5, id: \.self) { level in
                                    Circle()
                                        .fill(Int(intensity) >= level ? Color(hex: selectedCategory.color) : themeManager.secondaryTextColor.opacity(0.3))
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(themeManager.backgroundColor)
                    
                    // Triggers Section
                    Section(header: Text("What triggered this mood?").foregroundColor(themeManager.textColor)) {
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
                                        .foregroundColor(themeManager.textColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedTriggers.contains(trigger) ? 
                                            themeManager.accentColor : 
                                            themeManager.secondaryBackgroundColor
                                        )
                                        .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(themeManager.backgroundColor)
                    
                    // Location Section
                    Section(header: Text("Where are you?").foregroundColor(themeManager.textColor)) {
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
                                    .foregroundColor(themeManager.textColor)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(themeManager.textColor)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    
                    // Activities Section
                    Section(header: Text("What are you doing?").foregroundColor(themeManager.textColor)) {
                        ZStack(alignment: .leading) {
                            if activities.isEmpty {
                                Text("e.g., Working, exercising, socializing...")
                                    .foregroundColor(themeManager.textColor)
                            }
                            TextField("", text: $activities)
                                .foregroundColor(themeManager.textColor)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    
                    // Notes Section
                    Section(header: Text("Additional notes (optional)").foregroundColor(themeManager.textColor)) {
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("How are you feeling? What's on your mind?")
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.top, 8)
                            }
                            TextEditor(text: $notes)
                                .foregroundColor(themeManager.textColor)
                                .frame(minHeight: 80)
                                .background(Color.clear)
                        }
                    }
                    .listRowBackground(themeManager.secondaryBackgroundColor)
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        .listRowBackground(themeManager.backgroundColor)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(themeManager.backgroundColor)
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
                .foregroundColor(themeManager.accentColor)
            )
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
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

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
                    Section(header: Text("How are you feeling?").foregroundColor(Color(hex: "EEEEEE"))) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(MoodCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                    selectedSubcategory = category.subcategories.first ?? ""
                                }) {
                                    VStack(spacing: 8) {
                                        Text(category.emoji)
                                            .font(.system(size: 32))
                                        Text(category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "EEEEEE"))
                                    }
                                    .frame(height: 70)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        selectedCategory == category ? 
                                        Color(hex: category.color).opacity(0.3) : 
                                        Color(hex: "222831")
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedCategory == category ? 
                                                Color(hex: category.color) : 
                                                Color.clear, 
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color(hex: "31363F"))
                    
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
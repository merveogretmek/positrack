//
//  FocusView.swift
//  PosiTrack
//
//  Created by Merve Öğretmek on 5.03.2025.
//

import SwiftUI

struct FocusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    // Timer state variables
    @State private var selectedPreset: FocusPreset = .pomodoro
    @State private var duration: TimeInterval = FocusPreset.pomodoro.duration
    @State private var remainingTime: TimeInterval = FocusPreset.pomodoro.duration
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil

    // Custom focus input state variables
    @State private var showCustomInput: Bool = false
    @State private var customMinutesInput: String = ""

    // Activity and sheet state variables
    @State private var selectedActivity: String = "General Focus"
    @State private var activeSheet: ActiveFocusSheet? = nil

    // Session options
    @State private var backgroundNoiseOn: Bool = false
    @State private var dndOn: Bool = false
    @State private var sessionEndedAlert: Bool = false

    @EnvironmentObject var habitStore: HabitStore

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header / Title Area
                HStack {
                    Text("Focus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textColor)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                // Timer Display
                ZStack {
                    Circle()
                        .stroke(themeManager.secondaryTextColor.opacity(0.3), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    Circle()
                        .trim(from: 0, to: CGFloat(remainingTime / duration))
                        .stroke(
                            gradientForTimer(),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 200, height: 200)
                        .animation(.linear, value: remainingTime)
                    Text(timeString(time: remainingTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(themeManager.textColor)
                }

                // Activity Selection Button
                Button(action: {
                    activeSheet = .activityPicker
                }) {
                    Text(selectedPreset.rawValue)
                        .font(.title2)
                        .foregroundColor(themeManager.textColor)
                }

                // Controls: Start / Pause / Stop Buttons
                HStack(spacing: 40) {
                    if !isRunning && remainingTime < duration {
                        Button(action: startTimer) {
                            Label("Resume", systemImage: "play.fill")
                                .foregroundColor(themeManager.textColor)
                        }
                    } else if !isRunning {
                        Button(action: startTimer) {
                            Label("Start", systemImage: "play.fill")
                                .foregroundColor(themeManager.textColor)
                        }
                    } else {
                        Button(action: pauseTimer) {
                            Label("Pause", systemImage: "pause.fill")
                                .foregroundColor(themeManager.textColor)
                        }
                    }
                    Button(action: stopTimer) {
                        Label("Stop", systemImage: "stop.fill")
                            .foregroundColor(themeManager.textColor)
                    }
                }
                .font(.title2)
                .foregroundColor(themeManager.accentColor)

                // Session Type Selector (Preset Picker)
                Picker("Session Type", selection: $selectedPreset) {
                    ForEach(FocusPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onAppear {
                    let purpleColor = UIColor(themeManager.accentColor)
                    UISegmentedControl.appearance().selectedSegmentTintColor = purpleColor

                    let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor(themeManager.textColor)]
                    UISegmentedControl.appearance().setTitleTextAttributes(textAttributes, for: .normal)
                    UISegmentedControl.appearance().setTitleTextAttributes(textAttributes, for: .selected)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedPreset) { newValue in
                    if newValue == .custom {
                        // Show the small inline input for custom minutes.
                        showCustomInput = true
                        // Optionally, preset a default value.
                        customMinutesInput = "25"
                    } else {
                        showCustomInput = false
                        duration = newValue.duration
                        remainingTime = newValue.duration
                    }
                }

                // Inline Custom Duration Input Pop-Up
                if showCustomInput && selectedPreset == .custom {
                    HStack(spacing: 8) {
                        Text("Minutes:")
                            .foregroundColor(themeManager.textColor)
                        TextField("e.g., 30", text: $customMinutesInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                        Button("Set") {
                            if let minutes = Double(customMinutesInput), minutes > 0 {
                                let customDuration = minutes * 60
                                duration = customDuration
                                remainingTime = customDuration
                                // Hide the input pop-up once the custom duration is set.
                                showCustomInput = false
                            }
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                    .padding(.horizontal)
                }

                // Session Options: Toggles for Background Noise and DND
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(themeManager.textColor)
                        Toggle("", isOn: $backgroundNoiseOn)
                            .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)
                    HStack(spacing: 8) {
                        Image(systemName: "moon.zzz.fill")
                            .foregroundColor(themeManager.textColor)
                        Toggle("", isOn: $dndOn)
                            .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor))
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .font(.title)

                Spacer()
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .settings:
                    FocusSettingsView()
                case .activityPicker:
                    ActivityPickerView { newActivity in
                        selectedActivity = newActivity
                        activeSheet = nil  // Dismiss the sheet after selection
                    }
                    .environmentObject(habitStore)
                }
            }
            .alert(isPresented: $sessionEndedAlert) {
                Alert(
                    title: Text("Focus Session Complete"),
                    message: Text("Great job! You focused for \(timeString(time: duration))."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }

    // MARK: Timer Methods

    func startTimer() {
        if remainingTime <= 0 {
            remainingTime = duration
        }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                isRunning = false
                sessionEndedAlert = true
            }
        }
    }

    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        remainingTime = duration
    }

    // MARK: Utility Methods

    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func gradientForTimer() -> AngularGradient {
        let progress = remainingTime / duration
        let colors: [Color] = progress > 0.5 ?
            [Color(hex: "9B59B6"), themeManager.accentColor] :
            [themeManager.accentColor, Color(hex: "8E44AD")]
        return AngularGradient(gradient: Gradient(colors: colors), center: .center)
    }
}

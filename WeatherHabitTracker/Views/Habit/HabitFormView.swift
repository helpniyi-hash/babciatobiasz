//
//  HabitFormView.swift
//  WeatherHabitTracker
//
//  Form view for creating and editing habits with modern SwiftUI form elements.
//  Uses Apple's design patterns for form presentation.
//

import SwiftUI

/// Form view for adding or editing a habit.
/// Provides fields for all habit properties with validation.
struct HabitFormView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    
    /// ViewModel for habit operations
    @Bindable var viewModel: HabitViewModel
    
    /// The habit being edited (nil for new habit)
    let habit: Habit?
    
    // MARK: - Form State
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColor: Color = .blue
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var targetFrequency: Int = 1
    
    /// Available icon options
    private let iconOptions = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "drop.fill", "leaf.fill", "moon.fill", "sun.max.fill",
        "figure.run", "figure.walk", "dumbbell.fill", "sportscourt.fill",
        "book.fill", "pencil", "brain.head.profile", "lightbulb.fill",
        "cup.and.saucer.fill", "fork.knife", "pills.fill", "bed.double.fill",
        "music.note", "guitars.fill", "paintbrush.fill", "camera.fill"
    ]
    
    /// Available color options
    private let colorOptions: [Color] = [
        .blue, .purple, .pink, .red, .orange, .yellow,
        .green, .mint, .teal, .cyan, .indigo, .brown
    ]
    
    /// Whether the form has valid input
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Whether we're editing an existing habit
    private var isEditing: Bool {
        habit != nil
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section {
                    TextField("Habit Name", text: $name)
                        .font(.headline)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Basic Info")
                } footer: {
                    Text("Give your habit a memorable name")
                }
                
                // Appearance Section
                Section("Appearance") {
                    // Icon picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        iconPicker
                    }
                    .padding(.vertical, 8)
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        colorPicker
                    }
                    .padding(.vertical, 8)
                }
                
                // Target Section
                Section {
                    Stepper(value: $targetFrequency, in: 1...20) {
                        HStack {
                            Text("Daily Target")
                            Spacer()
                            Text("\(targetFrequency) time\(targetFrequency == 1 ? "" : "s")")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Goal")
                } footer: {
                    Text("How many times per day do you want to complete this habit?")
                }
                
                // Reminder Section
                Section {
                    Toggle("Enable Reminders", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    if reminderEnabled {
                        Text("You'll receive a daily notification at this time")
                    }
                }
                
                // Preview Section
                Section("Preview") {
                    previewCard
                }
            }
            // Use grouped form style - iOS 26 applies Liquid Glass automatically
            .formStyle(.grouped)
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveHabit()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadExistingData()
            }
        }
    }
    
    // MARK: - Icon Picker
    
    /// Grid of icon options
    private var iconPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(iconOptions, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                } label: {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                        .frame(width: 44, height: 44)
                        .background(
                            selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear,
                            in: Circle()
                        )
                        .overlay(
                            Circle()
                                .stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Icon: \(icon)")
            }
        }
    }
    
    // MARK: - Color Picker
    
    /// Grid of color options
    private var colorPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(colorOptions, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                .padding(2)
                        )
                        .overlay {
                            if selectedColor == color {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Preview Card
    
    /// Live preview of how the habit will look
    private var previewCard: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: selectedIcon)
                    .font(.title2)
                    .foregroundStyle(selectedColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? "Habit Name" : name)
                    .font(.headline)
                    .foregroundStyle(name.isEmpty ? .secondary : .primary)
                
                if !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Label("\(targetFrequency)/day", systemImage: "target")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if reminderEnabled {
                        Label(formatTime(reminderTime), systemImage: "bell.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Checkbox preview
            Image(systemName: "circle")
                .font(.title2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Actions
    
    /// Loads existing habit data if editing
    private func loadExistingData() {
        guard let habit = habit else { return }
        
        name = habit.name
        description = habit.habitDescription ?? ""
        selectedIcon = habit.iconName
        selectedColor = habit.color
        reminderEnabled = habit.notificationsEnabled
        reminderTime = habit.reminderTime ?? Date()
        targetFrequency = habit.targetFrequency
    }
    
    /// Saves the habit (creates new or updates existing)
    private func saveHabit() {
        Task {
            if let habit = habit {
                // Update existing habit
                habit.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                habit.habitDescription = description.isEmpty ? nil : description
                habit.iconName = selectedIcon
                habit.colorHex = selectedColor.hexString
                habit.notificationsEnabled = reminderEnabled
                habit.reminderTime = reminderEnabled ? reminderTime : nil
                habit.targetFrequency = targetFrequency
                
                await viewModel.updateHabit(habit)
            } else {
                // Create new habit
                await viewModel.createHabit(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.isEmpty ? nil : description,
                    iconName: selectedIcon,
                    colorHex: selectedColor.hexString,
                    reminderTime: reminderEnabled ? reminderTime : nil,
                    notificationsEnabled: reminderEnabled,
                    targetFrequency: targetFrequency
                )
            }
            
            dismiss()
        }
    }
    
    /// Formats time for display
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("New Habit") {
    HabitFormView(viewModel: HabitViewModel(), habit: nil)
}

#Preview("Edit Habit") {
    HabitFormView(viewModel: HabitViewModel(), habit: Habit.sampleHabits[0])
}

// MainTabView.swift
// BabciaTobiasz

import SwiftUI
import SwiftData

/// Root tab navigation with Weather and Habits tabs
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    
    @State private var viewModel = MainTabViewModel()
    @State private var weatherViewModel = WeatherViewModel()
    @State private var habitViewModel = HabitViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Weather", systemImage: "cloud.sun.fill", value: MainTabViewModel.Tab.weather) {
                WeatherView(viewModel: weatherViewModel)
            }
            
            Tab("Habits", systemImage: "checklist", value: MainTabViewModel.Tab.habits) {
                HabitListView(viewModel: habitViewModel)
            }
            
            Tab("Settings", systemImage: "gear", value: MainTabViewModel.Tab.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onAppear { setupViewModels() }
        .onChange(of: viewModel.selectedTab) { _, _ in
            hapticFeedback(.selection)
        }
    }
    
    private func setupViewModels() {
        let persistenceService = PersistenceService(modelContext: modelContext)
        
        weatherViewModel.configure(
            weatherService: dependencies.weatherService,
            persistenceService: persistenceService,
            locationService: dependencies.locationService
        )
        
        habitViewModel.configure(
            persistenceService: persistenceService,
            notificationService: dependencies.notificationService
        )
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, WeatherData.self, WeatherForecast.self], inMemory: true)
        .environment(AppDependencies())
}

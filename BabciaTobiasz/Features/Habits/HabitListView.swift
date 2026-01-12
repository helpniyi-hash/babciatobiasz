// HabitListView.swift
// BabciaTobiasz

import SwiftUI
import SwiftData

/// Main habit list with management and statistics
struct HabitListView: View {
    @Bindable var viewModel: HabitViewModel
    @State private var showStatsTooltip = false
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                if viewModel.habits.isEmpty && !viewModel.isLoading {
                    emptyStateView
                        .transition(.opacity)
                } else if viewModel.isLoading {
                    HabitSkeletonLoadingView()
                        .transition(.opacity)
                } else {
                    habitListContent
                        .transition(.opacity)
                }
            }
            .animation(theme.motion.listSpring, value: viewModel.habits.isEmpty)
            .navigationTitle("Habits")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
            .searchable(text: $viewModel.searchText, prompt: "Search habits")
            .toolbar { toolbarContent }
            .sheet(isPresented: $viewModel.showHabitForm) {
                HabitFormView(viewModel: viewModel, habit: viewModel.editingHabit)
            }
            .onAppear { viewModel.loadHabits() }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LiquidGlassBackground(style: .habits)
    }
    
    // MARK: - Content
    
    private var habitListContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                statisticsCard
                filterPicker
                habitsList
            }
            .padding()
        }
    }
    
    // MARK: - Statistics
    
    private var statisticsCard: some View {
        GlassCardView {
            VStack(spacing: 16) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 12)
                        .frame(width: theme.grid.ringSize, height: theme.grid.ringSize)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.todayCompletionPercentage)
                        .stroke(
                            LinearGradient(colors: theme.gradients.habitsProgress, startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: theme.grid.ringSize, height: theme.grid.ringSize)
                        .rotationEffect(.degrees(-90))
                        .animation(theme.motion.statsSpring, value: viewModel.todayCompletionPercentage)
                    
                    VStack(spacing: 2) {
                        Text("\(viewModel.completedTodayCount)/\(viewModel.totalHabitsCount)")
                            .dsFont(.title2, weight: .bold)
                            .contentTransition(.numericText())
                        Text("Today")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 30) {
                    statisticItem(icon: "flame.fill", value: "\(viewModel.bestStreak)", label: "Best Streak", color: .orange)
                    
                    Divider().frame(height: 40)
                    
                    statisticItem(icon: "checkmark.circle.fill", value: "\(viewModel.totalCompletions)", label: "Total Done", color: .green)
                }
            }
            .padding(.vertical, 12)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(theme.motion.pressSpring) {
                    showStatsTooltip.toggle()
                }
                hapticFeedback(.light)
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: theme.grid.iconTiny))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
        .overlay {
            if showStatsTooltip {
                FeatureTooltip(
                    title: "Habit Statistics",
                    description: "Track your progress with streaks and completion counts. Build consistency to increase your streak!",
                    icon: "chart.bar.fill",
                    isVisible: $showStatsTooltip
                )
                .transition(.scale.combined(with: .opacity))
                .offset(y: -120)
            }
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
    
    private func statisticItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(value)
            }
            .dsFont(.headline, weight: .bold)
            
            Text(label)
                .dsFont(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Filter
    
    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.filterOption) {
            ForEach(HabitViewModel.FilterOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.filterOption) { _, _ in
            hapticFeedback(.selection)
        }
    }
    
    // MARK: - Habits List
    
    private var habitsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredHabits) { habit in
                NavigationLink(destination: HabitDetailView(habit: habit, viewModel: viewModel)) {
                    HabitRowView(
                        habit: habit,
                        onToggleCompletion: {
                    withAnimation(theme.motion.pressSpring) {
                        viewModel.toggleCompletion(for: habit)
                    }
                }
            )
                }
                .buttonStyle(.plain)
                .contextMenu { habitContextMenu(for: habit) }
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                        .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        .blur(radius: phase.isIdentity ? 0 : 2)
                }
            }
        }
        .sensoryFeedback(.success, trigger: viewModel.totalCompletions)
    }
    
    private func habitContextMenu(for habit: Habit) -> some View {
        Group {
            Button {
                viewModel.toggleCompletion(for: habit)
                hapticFeedback(.success)
            } label: {
                Label(
                    habit.isCompletedToday ? "Mark Incomplete" : "Mark Complete",
                    systemImage: habit.isCompletedToday ? "xmark.circle" : "checkmark.circle"
                )
            }
            
            Button { viewModel.editHabit(habit) } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                viewModel.deleteHabit(habit)
                hapticFeedback(.warning)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checklist")
                .font(.system(size: theme.grid.iconXXL))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Habits Yet")
                    .dsFont(.title2, weight: .bold)
                
                Text("Start building good habits by adding your first one!")
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                viewModel.addNewHabit()
                hapticFeedback(.medium)
            } label: {
                Label("Add Your First Habit", systemImage: "plus.circle.fill")
                    .dsFont(.headline)
            }
            .buttonStyle(.nativeGlassProminent)
        }
        .padding()
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.addNewHabit()
                hapticFeedback(.medium)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: theme.grid.iconSmall))
            }
            .accessibilityLabel("Add new habit")
        }
    }
}

#Preview {
    HabitListView(viewModel: HabitViewModel())
        .modelContainer(for: Habit.self, inMemory: true)
        .environment(AppDependencies())
}

//
//  AreaDetailView.swift
//  BabciaTobiasz
//

import SwiftUI
import SwiftData

/// Detail view for an Area's current bowl and tasks.
struct HabitDetailView: View {
    let area: Area
    @Bindable var viewModel: AreaViewModel
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                tasksSection
                bowlStatusSection
            }
            .padding()
        }
        .background(backgroundGradient)
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(area.name)
                    .dsFont(.headline, weight: .bold)
                    .lineLimit(1)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.editArea(area)
                    } label: {
                        Label("Edit Area", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive) {
                        viewModel.deleteArea(area)
                    } label: {
                        Label("Delete Area", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAreaForm) {
            HabitFormView(viewModel: viewModel, area: viewModel.editingArea)
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: [
                    area.color.opacity(0.15),
                    theme.palette.secondary.opacity(0.1),
                    area.color.opacity(0.1),
                    theme.palette.tertiary.opacity(0.15),
                    area.color.opacity(0.2),
                    theme.palette.primary.opacity(0.1),
                    area.color.opacity(0.1),
                    theme.palette.secondary.opacity(0.15),
                    area.color.opacity(0.15)
                ]
            )
        }
        .ignoresSafeArea()
    }

    private func animatedMeshPoints(for date: Date) -> [SIMD2<Float>] {
        let time = Float(date.timeIntervalSince1970)
        let interval = Float(max(theme.motion.meshAnimationInterval, 0.1))
        let baseSpeed = 1.0 / interval
        let offset = sin(time * (baseSpeed * 0.5)) * 0.2
        let offset2 = cos(time * (baseSpeed * 0.35)) * 0.14
        return [
            [0.0, 0.0], [0.5 + offset2, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + offset, 0.5 - offset], [1.0, 0.5],
            [0.0, 1.0], [0.5 - offset2, 1.0], [1.0, 1.0]
        ]
    }

    // MARK: - Header

    private var headerSection: some View {
        GlassCardView {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(area.color.opacity(0.2))
                        .frame(width: 96, height: 96)

                    Image(systemName: area.iconName)
                        .font(.system(size: theme.grid.iconLarge))
                        .foregroundStyle(area.color)
                }

                if let description = area.areaDescription, !description.isEmpty {
                    Text(description)
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Give your area a memorable name")
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let bowl = area.activeBowl {
                    Text("Bowl created \(formattedDate(bowl.createdAt))")
                        .dsFont(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 12)
        }
    }

    // MARK: - Tasks

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tasks (5)")
                .dsFont(.headline, weight: .bold)

            GlassCardView {
                VStack(spacing: 0) {
                    ForEach(activeTasks) { task in
                        taskRow(task)
                        if task.id != activeTasks.last?.id {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }

    private func taskRow(_ task: CleaningTask) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.toggleTaskCompletion(task)
                hapticFeedback(.light)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .dsFont(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .dsFont(.body)
                if let detail = task.detail, !detail.isEmpty {
                    Text(detail)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Bowl Status

    private var bowlStatusSection: some View {
        GlassCardView {
            VStack(spacing: 12) {
                if bowlCompleted {
                    Text("Bowl complete")
                        .dsFont(.headline, weight: .bold)

                    Text("You can verify this bowl for more points.")
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if let bowl = area.activeBowl, bowl.isVerified {
                        verifiedBadge(for: bowl)
                    } else {
                        Button {
                            if let bowl = area.activeBowl {
                                let isSuper = Int.random(in: 1...20) == 1
                                viewModel.verifyBowl(bowl, superVerified: isSuper)
                                hapticFeedback(.success)
                            }
                        } label: {
                            Label("Verify bowl", systemImage: "checkmark.seal.fill")
                                .dsFont(.headline)
                        }
                        .buttonStyle(.nativeGlassProminent)
                    }
                } else {
                    Text("Finish all 5 tasks to complete the bowl.")
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func verifiedBadge(for bowl: AreaBowl) -> some View {
        let title = bowl.verificationStatus == .superVerified ? "Superverify" : "Verified"
        let icon = bowl.verificationStatus == .superVerified ? "checkmark.seal.fill" : "checkmark.seal"
        let color: Color = bowl.verificationStatus == .superVerified ? .yellow : .blue

        return HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .dsFont(.headline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(color.opacity(0.15), in: Capsule())
    }

    // MARK: - Helpers

    private var activeTasks: [CleaningTask] {
        area.activeBowl?.tasks ?? []
    }

    private var bowlCompleted: Bool {
        area.activeBowl?.isCompleted ?? false
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(area: Area.sampleAreas[0], viewModel: AreaViewModel())
    }
    .modelContainer(for: Area.self, inMemory: true)
}

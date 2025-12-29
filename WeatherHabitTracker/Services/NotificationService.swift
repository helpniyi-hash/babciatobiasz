//
//  NotificationService.swift
//  WeatherHabitTracker
//
//  Service responsible for managing local notifications for habit reminders.
//  Uses UserNotifications framework for scheduling and managing notifications.
//

import Foundation
import UserNotifications

/// Service that manages local notifications for habit reminders.
/// Handles permission requests, scheduling, and cancellation of notifications.
@MainActor
@Observable
final class NotificationService {
    
    // MARK: - Properties
    
    /// The notification center instance
    private var notificationCenter: UNUserNotificationCenter? {
        // Avoid crashing in raw executable mode (swift run) where bundle ID is nil
        guard Bundle.main.bundleIdentifier != nil else { return nil }
        return UNUserNotificationCenter.current()
    }
    
    /// Current authorization status
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    /// Whether notifications are authorized
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }
    
    // MARK: - Initialization
    
    /// Initializes the notification service and checks current authorization status
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// Checks the current notification authorization status
    func checkAuthorizationStatus() async {
        guard let center = notificationCenter else { return }
        let settings = await center.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
        }
    }
    
    /// Requests notification authorization from the user
    /// - Returns: Whether authorization was granted
    @discardableResult
    func requestAuthorization() async -> Bool {
        guard let center = notificationCenter else {
            print("Notification authorization skipped: No bundle identifier")
            return false
        }

        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Scheduling
    
    /// Schedules a daily reminder notification for a habit
    /// - Parameters:
    ///   - habit: The habit to schedule notifications for
    /// - Throws: NotificationError if scheduling fails
    func scheduleHabitReminder(for habit: Habit) async throws {
        guard habit.notificationsEnabled,
              let reminderTime = habit.reminderTime else {
            return
        }
        
        // Ensure we have authorization
        var authorized = isAuthorized
        if !authorized {
            authorized = await requestAuthorization()
        }
        
        guard authorized else {
            throw NotificationError.notAuthorized
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habit.name)"
        content.body = habit.habitDescription ?? "Don't forget to complete your habit!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "HABIT_REMINDER"
        content.userInfo = ["habitId": habit.id.uuidString]
        
        // Create daily trigger based on reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request with habit ID as identifier
        let identifier = "habit-\(habit.id.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        if let center = notificationCenter {
            try await center.add(request)
        }
    }
    
    /// Cancels notification for a specific habit
    /// - Parameter habit: The habit to cancel notifications for
    func cancelHabitReminder(for habit: Habit) {
        let identifier = "habit-\(habit.id.uuidString)"
        notificationCenter?.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Updates notification for a habit (cancels existing and schedules new)
    /// - Parameter habit: The habit to update notifications for
    func updateHabitReminder(for habit: Habit) async throws {
        cancelHabitReminder(for: habit)
        
        if habit.notificationsEnabled {
            try await scheduleHabitReminder(for: habit)
        }
    }
    
    /// Cancels all pending habit notifications
    func cancelAllHabitReminders() {
        notificationCenter?.removeAllPendingNotificationRequests()
    }
    
    /// Gets all pending notification requests
    /// - Returns: Array of pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter?.pendingNotificationRequests() ?? []
    }
    
    // MARK: - Badge Management
    
    /// Clears the app badge
    @MainActor
    func clearBadge() {
        notificationCenter?.setBadgeCount(0)
    }
    
    /// Sets the app badge to a specific count
    /// - Parameter count: The badge count to set
    @MainActor
    func setBadge(count: Int) {
        notificationCenter?.setBadgeCount(count)
    }
    
    // MARK: - Notification Categories
    
    /// Registers notification categories and actions
    func registerNotificationCategories() {
        // Action to mark habit as complete from notification
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_HABIT",
            title: "Mark Complete",
            options: [.foreground]
        )
        
        // Action to snooze the reminder
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_HABIT",
            title: "Remind in 1 hour",
            options: []
        )
        
        // Define the habit reminder category
        let habitCategory = UNNotificationCategory(
            identifier: "HABIT_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter?.setNotificationCategories([habitCategory])
    }
}

// MARK: - NotificationError

/// Errors that can occur when managing notifications
enum NotificationError: LocalizedError {
    case notAuthorized
    case schedulingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notification permission not granted. Please enable notifications in Settings."
        case .schedulingFailed(let error):
            return "Failed to schedule notification: \(error.localizedDescription)"
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate Support

/// Extension to help with notification handling
extension NotificationService {
    /// Handles a notification action
    /// - Parameters:
    ///   - actionIdentifier: The action that was selected
    ///   - habitId: The habit ID from the notification
    /// - Returns: The action type that was performed
    func handleNotificationAction(
        actionIdentifier: String,
        habitId: String
    ) -> NotificationAction {
        switch actionIdentifier {
        case "COMPLETE_HABIT":
            return .complete(habitId: habitId)
        case "SNOOZE_HABIT":
            return .snooze(habitId: habitId)
        case UNNotificationDismissActionIdentifier:
            return .dismiss
        default:
            return .open(habitId: habitId)
        }
    }
}

/// Actions that can be performed from a notification
enum NotificationAction {
    case complete(habitId: String)
    case snooze(habitId: String)
    case dismiss
    case open(habitId: String)
}

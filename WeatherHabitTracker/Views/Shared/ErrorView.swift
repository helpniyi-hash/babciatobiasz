//
//  ErrorView.swift
//  WeatherHabitTracker
//
//  A reusable error display component with retry functionality.
//  Provides consistent error handling UI across the app.
//

import SwiftUI

/// A view for displaying error states with an optional retry action.
/// Uses glass styling and provides clear user feedback.
struct ErrorView: View {
    
    // MARK: - Properties
    
    /// The error title
    var title: String = "Something went wrong"
    
    /// The error message/description
    var message: String
    
    /// SF Symbol name for the error icon
    var iconName: String = "exclamationmark.triangle.fill"
    
    /// Icon color
    var iconColor: Color = .orange
    
    /// Optional retry action
    var retryAction: (() -> Void)?
    
    /// Optional dismiss action
    var dismissAction: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        GlassCardView {
            VStack(spacing: 20) {
                // Error icon
                Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundStyle(iconColor)
                    .symbolEffect(.pulse)
                
                // Error text
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Action buttons
                actionButtons
            }
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Action Buttons
    
    /// Retry and dismiss buttons
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Dismiss button (if provided)
            if let dismissAction = dismissAction {
                Button {
                    dismissAction()
                } label: {
                    Text("Dismiss")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            
            // Retry button (if provided)
            if let retryAction = retryAction {
                Button {
                    retryAction()
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass(color: .blue, prominent: true))
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Error Types

/// Common error display configurations
extension ErrorView {
    /// Creates an error view for network errors
    static func networkError(
        message: String = "Please check your internet connection and try again.",
        retryAction: @escaping () -> Void
    ) -> ErrorView {
        ErrorView(
            title: "Connection Error",
            message: message,
            iconName: "wifi.exclamationmark",
            iconColor: .red,
            retryAction: retryAction
        )
    }
    
    /// Creates an error view for location errors
    static func locationError(
        message: String = "Unable to access your location. Please check your settings.",
        retryAction: (() -> Void)? = nil
    ) -> ErrorView {
        ErrorView(
            title: "Location Error",
            message: message,
            iconName: "location.slash.fill",
            iconColor: .orange,
            retryAction: retryAction
        )
    }
    
    /// Creates an error view for data loading errors
    static func dataError(
        message: String = "Unable to load data. Please try again later.",
        retryAction: @escaping () -> Void
    ) -> ErrorView {
        ErrorView(
            title: "Loading Error",
            message: message,
            iconName: "exclamationmark.icloud.fill",
            iconColor: .gray,
            retryAction: retryAction
        )
    }
    
    /// Creates an error view for permission errors
    static func permissionError(
        title: String = "Permission Required",
        message: String,
        settingsAction: @escaping () -> Void
    ) -> some View {
        GlassCardView {
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    settingsAction()
                } label: {
                    Label("Open Settings", systemImage: "gear")
                        .font(.headline)
                }
                .buttonStyle(.glass(color: .blue, prominent: true))
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Inline Error Banner

/// A compact inline error banner for non-blocking errors
struct ErrorBanner: View {
    
    // MARK: - Properties
    
    var message: String
    var dismissAction: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
            
            Text(message)
                .font(.subheadline)
                .lineLimit(2)
            
            Spacer()
            
            if let dismissAction = dismissAction {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Error View Modifier

extension View {
    /// Shows an error overlay when an error occurs
    /// - Parameters:
    ///   - error: Binding to the optional error message
    ///   - retryAction: Action to perform when retry is tapped
    /// - Returns: The view with error overlay capability
    func errorOverlay(
        error: Binding<String?>,
        retryAction: @escaping () -> Void
    ) -> some View {
        self.overlay {
            if let errorMessage = error.wrappedValue {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ErrorView(
                        message: errorMessage,
                        retryAction: retryAction,
                        dismissAction: { error.wrappedValue = nil }
                    )
                    .padding()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: error.wrappedValue != nil)
    }
}

// MARK: - Preview

#Preview("Error Views") {
    ScrollView {
        VStack(spacing: 24) {
            // Default error
            ErrorView(
                message: "An unexpected error occurred. Please try again.",
                retryAction: { print("Retry tapped") }
            )
            
            // Network error
            ErrorView.networkError {
                print("Retry network")
            }
            
            // Location error
            ErrorView.locationError()
            
            // Error banner
            ErrorBanner(message: "Unable to sync your data") {
                print("Dismissed")
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}

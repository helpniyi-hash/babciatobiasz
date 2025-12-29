//
//  LaunchView.swift
//  WeatherHabitTracker
//
//  The initial view displayed when the app launches.
//  Handles splash screen animation and transitions to the main content.
//

import SwiftUI

/// LaunchView serves as the entry point view that displays a splash screen
/// before transitioning to the main tab view. It handles initial setup animations
/// and provides a polished launch experience.
struct LaunchView: View {
    
    // MARK: - State
    
    /// Controls whether the splash animation has completed
    @State private var isAnimationComplete = false
    
    /// Controls the opacity of the splash content for fade animation
    @State private var splashOpacity: Double = 1.0
    
    /// Controls the scale of the app icon during animation
    @State private var iconScale: CGFloat = 0.8
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main content (shown after splash)
            if isAnimationComplete {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
            
            // Splash screen overlay
            if !isAnimationComplete {
                splashContent
                    .opacity(splashOpacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isAnimationComplete)
        .task {
            await performLaunchAnimation()
        }
    }
    
    // MARK: - Splash Content
    
    /// The splash screen content with app branding and animation
    private var splashContent: some View {
        ZStack {
            // Background gradient with liquid glass effect
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.cyan.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glass overlay effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // App branding content
            VStack(spacing: 24) {
                // App icon with animation
                ZStack {
                    // Weather icon
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 60))
                        .symbolRenderingMode(.multicolor)
                        .offset(x: -20, y: -10)
                    
                    // Habit checkmark icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                        .offset(x: 30, y: 20)
                }
                .scaleEffect(iconScale)
                
                // App title
                VStack(spacing: 8) {
                    Text("WeatherHabit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
                    Text("Track weather & build habits")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.primary)
                    .padding(.top, 20)
            }
        }
    }
    
    // MARK: - Animation
    
    /// Performs the launch animation sequence
    /// - Returns: Completes after animation finishes
    private func performLaunchAnimation() async {
        // Initial delay for branding visibility
        try? await Task.sleep(for: .milliseconds(500))
        
        // Animate icon scale
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconScale = 1.0
        }
        
        // Wait for animation
        try? await Task.sleep(for: .milliseconds(1000))
        
        // Fade out splash
        withAnimation(.easeOut(duration: 0.3)) {
            splashOpacity = 0.0
        }
        
        try? await Task.sleep(for: .milliseconds(300))
        
        // Show main content
        isAnimationComplete = true
    }
}

// MARK: - Preview

#Preview {
    LaunchView()
        .environment(AppDependencies())
}

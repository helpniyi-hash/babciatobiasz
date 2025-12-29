//
//  LiquidGlassStyle.swift
//  WeatherHabitTracker
//
//  Native iOS 26 Liquid Glass support using system APIs.
//  Uses Apple's glassEffect modifier and system materials.
//

import SwiftUI

// MARK: - Native Liquid Glass View Modifier

/// A view modifier that applies native iOS 26 Liquid Glass effects.
/// Uses system `.glassEffect()` on iOS 26+ or falls back to materials on earlier versions.
struct NativeLiquidGlass: ViewModifier {
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            // Fallback for earlier iOS versions
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    /// Applies native iOS 26 Liquid Glass effect to the view.
    /// Uses system `.glassEffect()` API when available.
    func liquidGlass(cornerRadius: CGFloat = 24) -> some View {
        self.modifier(NativeLiquidGlass(cornerRadius: cornerRadius))
    }
    
    /// Applies glass effect with prominent styling for important actions.
    @ViewBuilder
    func liquidGlassProminent(cornerRadius: CGFloat = 24) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

// MARK: - Liquid Glass Background

/// A background view optimized for Liquid Glass content.
/// Provides a subtle gradient that works well with translucent materials.
struct LiquidGlassBackground: View {
    var style: BackgroundStyle = .default
    
    enum BackgroundStyle {
        case `default`
        case weather
        case habits
    }
    
    var body: some View {
        switch style {
        case .default:
            defaultBackground
        case .weather:
            weatherBackground
        case .habits:
            habitsBackground
        }
    }
    
    private var defaultBackground: some View {
        #if os(iOS)
        LinearGradient(
            colors: [
                Color(uiColor: .systemBackground),
                Color(uiColor: .secondarySystemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        #else
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .controlBackgroundColor)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        #endif
    }
    
    private var weatherBackground: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.3),
                Color.cyan.opacity(0.2),
                Color.purple.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var habitsBackground: some View {
        LinearGradient(
            colors: [
                Color.green.opacity(0.15),
                Color.teal.opacity(0.1),
                Color.blue.opacity(0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Concentric Shape Support

extension View {
    /// Creates a concentric rounded rectangle shape that aligns with container curvature.
    /// Uses iOS 26's ConcentricRectangle when available.
    @ViewBuilder
    func concentricClipShape(cornerRadius: CGFloat = 20) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.clipShape(ConcentricRectangle())
        } else {
            self.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

// LiquidGlassStyle.swift
// BabciaTobiasz

import SwiftUI

// MARK: - Liquid Glass Modifier

/// Applies native iOS 26 Liquid Glass effects with fallback
struct NativeLiquidGlass: ViewModifier {
    var cornerRadius: CGFloat?
    @Environment(\.dsTheme) private var theme
    
    func body(content: Content) -> some View {
        let resolvedCornerRadius = cornerRadius ?? theme.shape.glassCornerRadius
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(true), in: .rect(cornerRadius: resolvedCornerRadius))
        } else {
            fallbackContent(content, cornerRadius: resolvedCornerRadius)
        }
        #else
        fallbackContent(content, cornerRadius: resolvedCornerRadius)
        #endif
    }
    
    @ViewBuilder
    private func fallbackContent(_ content: Content, cornerRadius: CGFloat) -> some View {
        content
            .background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct LiquidGlassProminentModifier: ViewModifier {
    var cornerRadius: CGFloat?
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let resolvedCornerRadius = cornerRadius ?? theme.shape.glassCornerRadius
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(.regular.tint(theme.palette.primary), in: .rect(cornerRadius: resolvedCornerRadius))
        } else {
            content.background(theme.glass.prominentStrength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        }
        #else
        content.background(theme.glass.prominentStrength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        #endif
    }
}

struct SubtleGlassModifier: ViewModifier {
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let resolvedCornerRadius = theme.shape.subtleCornerRadius
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(.regular, in: .rect(cornerRadius: resolvedCornerRadius))
        } else {
            content.background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        }
        #else
        content.background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        #endif
    }
}

extension View {
    /// Applies Liquid Glass effect
    func liquidGlass(cornerRadius: CGFloat? = nil) -> some View {
        modifier(NativeLiquidGlass(cornerRadius: cornerRadius))
    }
    
    /// Prominent glass effect for buttons
    func liquidGlassProminent(cornerRadius: CGFloat? = nil) -> some View {
        modifier(LiquidGlassProminentModifier(cornerRadius: cornerRadius))
    }
    
    /// Subtle glass effect
    func subtleGlass() -> some View {
        modifier(SubtleGlassModifier())
    }
    
    /// Concentric clip shape for nested elements
    @ViewBuilder
    func concentricClipShape(cornerRadius: CGFloat = 20) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            self.clipShape(ConcentricRectangle())
        } else {
            self.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        #else
        self.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        #endif
    }
}

// MARK: - Glass Background

struct LiquidGlassBackground: View {
    var style: BackgroundStyle = .default
    @Environment(\.dsTheme) private var theme
    
    enum BackgroundStyle { case `default`, weather, habits }
    
    var body: some View {
        switch style {
        case .default: defaultBackground
        case .weather: weatherBackground
        case .habits: habitsBackground
        }
    }
    
    private var defaultBackground: some View {
        #if os(iOS)
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: theme.gradients.backgroundDefault
        )
        .ignoresSafeArea()
        #else
        LinearGradient(
            colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .controlBackgroundColor)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        #endif
    }
    
    private var weatherBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.6, 0.4], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: theme.gradients.backgroundWeather
        )
        .ignoresSafeArea()
    }
    
    private var habitsBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: theme.gradients.backgroundHabits
        )
        .ignoresSafeArea()
    }
}

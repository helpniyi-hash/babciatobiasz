//
//  GlassCardView.swift
//  WeatherHabitTracker
//
//  A reusable glass-style card component using Apple's Liquid Glass design.
//  Provides consistent styling across the app with material backgrounds and effects.
//

import SwiftUI

/// A glass-morphism card view implementing Apple's Liquid Glass design language.
/// Uses ultraThinMaterial backgrounds with subtle borders and shadows for depth.
///
/// Usage:
/// ```swift
/// GlassCardView {
///     Text("Card Content")
/// }
/// ```
struct GlassCardView<Content: View>: View {
    
    // MARK: - Properties
    
    /// The content to display inside the card
    let content: Content
    
    /// Corner radius of the card
    var cornerRadius: CGFloat = 20
    
    /// Whether to show a border
    var showBorder: Bool = true
    
    /// Padding inside the card
    var padding: CGFloat = 16
    
    // MARK: - Initialization
    
    /// Creates a new GlassCardView with the given content
    /// - Parameter content: A ViewBuilder closure providing the card's content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    /// Creates a GlassCardView with custom styling options
    /// - Parameters:
    ///   - cornerRadius: The corner radius (default: 20)
    ///   - showBorder: Whether to show the border (default: true)
    ///   - padding: Internal padding (default: 16)
    ///   - content: A ViewBuilder closure providing the card's content
    init(
        cornerRadius: CGFloat = 20,
        showBorder: Bool = true,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
        self.padding = padding
        self.content = content()
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity)
            .liquidGlass(cornerRadius: cornerRadius)
    }
}

// MARK: - Glass Card Modifiers

extension View {
    /// Applies a glass card style to any view using native iOS 26 API when available.
    /// - Parameters:
    ///   - cornerRadius: The corner radius
    ///   - padding: Internal padding
    /// - Returns: A view with glass card styling
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity)
            .liquidGlass(cornerRadius: cornerRadius)
    }
    
    /// Applies a subtle glass effect to any view
    /// - Returns: A view with subtle glass styling
    @ViewBuilder
    func subtleGlass() -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: 12))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Native Glass Button Styles

/// Button style that uses native iOS 26 glass button styling when available.
struct NativeGlassButtonStyle: ButtonStyle {
    var isProminent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            // Use native glass button styling on iOS 26+
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassEffect(
                    isProminent ? .regular.interactive() : .regular,
                    in: .capsule
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
        } else {
            // Fallback for earlier versions
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
        }
    }
}

extension ButtonStyle where Self == NativeGlassButtonStyle {
    /// A glass-style button using native iOS 26 glass effect
    static var nativeGlass: NativeGlassButtonStyle { NativeGlassButtonStyle() }
    
    /// A prominent glass-style button
    static var nativeGlassProminent: NativeGlassButtonStyle { NativeGlassButtonStyle(isProminent: true) }
}

// MARK: - Legacy Glass Button Style (for compatibility)

/// A button style with glass-morphism effect for primary actions
struct GlassButtonStyle: ButtonStyle {
    var color: Color = .blue
    var isProminent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            // Use native button styles on iOS 26+
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassEffect(
                    isProminent ? .regular.interactive() : .regular,
                    in: .capsule
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
        } else {
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    isProminent
                        ? AnyShapeStyle(color.gradient)
                        : AnyShapeStyle(.ultraThinMaterial)
                )
                .foregroundStyle(isProminent ? .white : .primary)
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
        }
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    /// A glass-style button appearance
    static var glass: GlassButtonStyle { GlassButtonStyle() }
    
    /// A prominent glass-style button with filled background
    static func glass(color: Color, prominent: Bool = false) -> GlassButtonStyle {
        GlassButtonStyle(color: color, isProminent: prominent)
    }
}

// MARK: - Preview

#Preview("Glass Card Variations") {
    ScrollView {
        VStack(spacing: 20) {
            // Standard glass card
            GlassCardView {
                VStack(spacing: 12) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)
                    
                    Text("Standard Glass Card")
                        .font(.headline)
                    
                    Text("Using ultraThinMaterial with gradient border")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Compact card
            GlassCardView(cornerRadius: 12, padding: 12) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                    Text("Compact Card")
                    Spacer()
                    Text("Info")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Using modifier
            VStack(spacing: 8) {
                Text("Using Modifier")
                    .font(.headline)
                Text("Applied with .glassCard()")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .glassCard()
            
            // Glass buttons
            HStack(spacing: 16) {
                Button("Glass") {}
                    .buttonStyle(.glass)
                
                Button("Prominent") {}
                    .buttonStyle(.glass(color: .blue, prominent: true))
            }
        }
        .padding()
    }
    .background(
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}

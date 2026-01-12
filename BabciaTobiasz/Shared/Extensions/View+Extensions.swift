//
//  View+Extensions.swift
//  BabciaTobiasz
//
//  SwiftUI View extensions for common modifiers and utilities.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension View {
    
    // MARK: - Conditional Modifiers
    
    /// Applies a modifier conditionally
    /// - Parameters:
    ///   - condition: Whether to apply the modifier
    ///   - transform: The modifier to apply
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies a modifier if a value is non-nil
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    // MARK: - Animation
    
    /// Applies standard spring animation to changes
    func animateOnChange<V: Equatable>(of value: V) -> some View {
        modifier(AnimateOnChangeModifier(value: value))
    }
    
    // MARK: - Accessibility
    
    /// Adds accessibility label and hint
    func accessible(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
    }
}

struct AnimateOnChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        content.animation(theme.motion.listSpring, value: value)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension View {
    /// Wraps view in a preview container with common modifiers
    func previewContainer() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            #if canImport(UIKit)
            .background(Color(UIColor.systemBackground))
            #else
            .background(Color.primary.colorInvert()) // Fallback for non-UIKit platforms
            #endif
    }
}
#endif

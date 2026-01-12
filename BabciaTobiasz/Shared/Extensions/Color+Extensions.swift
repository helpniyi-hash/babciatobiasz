//
//  Color+Extensions.swift
//  BabciaTobiasz
//
//  Color utilities and app-wide color palette.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    
    // MARK: - App Colors
    
    /// Primary accent color for the app
    static let appAccent = Color.blue
    
    /// Success/completion color
    static let appSuccess = Color.green
    
    /// Warning color
    static let appWarning = Color.orange
    
    /// Error/danger color
    static let appError = Color.red
    
    // MARK: - Weather Colors
    
    /// Clear/sunny sky color
    static let weatherSunny = Color(red: 0.4, green: 0.7, blue: 1.0)
    
    /// Cloudy sky color
    static let weatherCloudy = Color(red: 0.6, green: 0.65, blue: 0.7)
    
    /// Rainy sky color
    static let weatherRainy = Color(red: 0.4, green: 0.5, blue: 0.6)
    
    /// Night sky color
    static let weatherNight = Color(red: 0.15, green: 0.2, blue: 0.35)
    
    // MARK: - Gradients
    
    /// Sunrise gradient colors
    static let sunriseGradient: [Color] = [
        Color(red: 1.0, green: 0.8, blue: 0.4),
        Color(red: 1.0, green: 0.6, blue: 0.5),
        Color(red: 0.7, green: 0.5, blue: 0.8)
    ]
    
    /// Daytime gradient colors
    static let dayGradient: [Color] = [
        Color(red: 0.4, green: 0.7, blue: 1.0),
        Color(red: 0.5, green: 0.8, blue: 1.0),
        Color(red: 0.6, green: 0.9, blue: 1.0)
    ]
    
    /// Sunset gradient colors
    static let sunsetGradient: [Color] = [
        Color(red: 1.0, green: 0.5, blue: 0.3),
        Color(red: 0.9, green: 0.4, blue: 0.5),
        Color(red: 0.5, green: 0.3, blue: 0.6)
    ]
    
    /// Night gradient colors
    static let nightGradient: [Color] = [
        Color(red: 0.1, green: 0.15, blue: 0.3),
        Color(red: 0.15, green: 0.2, blue: 0.35),
        Color(red: 0.2, green: 0.25, blue: 0.4)
    ]
    
    // MARK: - Hex Utilities
    
    /// Initialize a Color from a hex string (failable)
    /// - Parameter hex: Hex color string (with or without #)
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    /// Converts the Color to a hex string
    var hexString: String {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else { return "#007AFF" }
        #elseif canImport(AppKit)
        guard let components = NSColor(self).cgColor.components else { return "#007AFF" }
        #else
        return "#007AFF"
        #endif
        
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

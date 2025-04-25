import SwiftUI

// Add this file to your project as "Theme.swift"

// Color constants for consistent colors across the app
struct Theme {
    // Main colors
    static let primaryColor = Color.orange
    static let secondaryColor = Color.black
    static let backgroundColor = Color.white
    
    // Text colors
    static let titleColor = Color.white
    static let subtitleColor = Color.orange
    static let bodyTextColor = Color.black
    
    // Button styles
    static let primaryButtonColor = Color.orange
    static let primaryButtonTextColor = Color.white
    
    static let secondaryButtonColor = Color.black.opacity(0.7)
    static let secondaryButtonTextColor = Color.white
    
    // Main gradient for backgrounds
    static func backgroundGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.white, Color.black.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Button style for consistency
    static func standardButtonStyle(backgroundColor: Color, textColor: Color) -> some View {
        return AnyView(
            ZStack {
                backgroundColor
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.2), radius: 3)
            }
        )
    }
}

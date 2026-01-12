//
//  Color+Extensions.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 26.12.25.
//

import SwiftUI

// MARK: - Manga Theme Colors
/// Centralized color palette matching Design_System.md
/// Provides semantic color names and pre-built gradients

extension Color {
    // MARK: Primary Colors (from Design_System.md)
    
    /// Primary Red - #EF4444
    /// Used in: Actions, positive feedback, main theme, MangaBackdrop
    static let mangaRed = Color(red: 0.937, green: 0.267, blue: 0.267)
    
    /// Primary Orange - #F97316
    /// Used in: Secondary actions, warm accents, streak theme
    static let mangaOrange = Color(red: 0.976, green: 0.451, blue: 0.086)
    
    /// Purple - #8B5CF6
    /// Used in: Special elements, level progress, stat cards
    static let mangaPurple = Color(red: 0.545, green: 0.361, blue: 0.965)
    
    /// Green - #10B981
    /// Used in: Correct answers, success states, achievements
    static let mangaGreen = Color(red: 0.063, green: 0.725, blue: 0.506)
    
    /// Yellow - #FBBF24
    /// Used in: Achievements, celebrations, tips
    static let mangaYellow = Color(red: 0.984, green: 0.749, blue: 0.141)
    
    // MARK: Background Colors
    
    /// Dark Card - #111827
    static let mangaDarkCard = Color(red: 0.067, green: 0.094, blue: 0.153)
    
    // MARK: Text Colors
    
    /// Secondary Text - #9CA3AF
    static let mangaTextSecondary = Color(red: 0.612, green: 0.639, blue: 0.686)
    
    /// Muted Text - #6B7280
    static let mangaTextMuted = Color(red: 0.420, green: 0.447, blue: 0.502)
    
    // MARK: Gradients (Design_System.md: "Red→Orange for buttons, XP bars")
    
    /// Primary gradient: Red → Orange
    static var mangaPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [mangaRed, mangaOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Success gradient: Green variations
    static var mangaSuccessGradient: LinearGradient {
        LinearGradient(
            colors: [mangaGreen, mangaGreen.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: Legacy Aliases (maintain backward compatibility with existing code)
    
    /// Legacy alias - matches mangaRed closely
    static let tsukiRed = Color(red: 0.9, green: 0.2, blue: 0.3)
    
    /// Legacy alias - matches mangaOrange closely
    static let tsukiOrange = Color(red: 1.0, green: 0.5, blue: 0.2)
}

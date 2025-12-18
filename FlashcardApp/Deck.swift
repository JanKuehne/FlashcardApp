//
//  Deck.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import Foundation
import SwiftData

@Model
final class Deck {
    var id: UUID
    var name: String
    var deckDescription: String
    var createdDate: Date
    var color: String              // Hex color for UI
    var iconName: String           // SF Symbol name
    
    // Language support (added for multi-language feature)
    var nativeLanguage: String      // "de" (German) - always for now
    var targetLanguage: String      // "en" (English) or "es" (Spanish)
    
    // Computed properties for UI
    var languageFlag: String {
        switch targetLanguage {
        case "es": return "🇪🇸"
        case "en": return "🇬🇧"
        default: return "🇬🇧"
        }
    }
    
    var languageName: String {
        switch targetLanguage {
        case "es": return "Español"
        case "en": return "English"
        default: return "English"
        }
    }
    
    init(name: String, description: String = "", color: String = "#0052FF", targetLanguage: String = "en") {
        self.id = UUID()
        self.name = name
        self.deckDescription = description
        self.createdDate = Date()
        self.color = color
        self.iconName = "book.fill"
        self.nativeLanguage = "de"
        self.targetLanguage = targetLanguage
    }
}

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
    
    init(name: String, description: String = "", color: String = "#0052FF") {
        self.id = UUID()
        self.name = name
        self.deckDescription = description
        self.createdDate = Date()
        self.color = color
        self.iconName = "book.fill"
    }
}

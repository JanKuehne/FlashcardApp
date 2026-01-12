//
//  Flashcard.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import Foundation
import SwiftData

@Model
final class Flashcard {
    // Identifiers
    var id: UUID
    var deckId: UUID
    
    // Content
    var front: String              // German word
    var back: String               // English translation
    var exampleSentence: String?   // Optional context
    var imageURL: String?          // Future: associated image
    
    // SM-2 Algorithm Data
    var easinessFactor: Double     // 1.3 to 2.5, starts at 2.5
    var repetitions: Int           // Consecutive correct answers
    var interval: Int              // Days until next review
    var nextReviewDate: Date       // When card is due
    
    // Learning Queue (Anki-style)
    var cardState: String          // "learning" or "graduated"
    var learningStep: Int          // Number of times reviewed in learning phase (0-2)
    
    // Statistics
    var createdDate: Date
    var lastReviewedDate: Date?
    var timesReviewed: Int         // Total review count
    var timesCorrect: Int          // Successful reviews
    var averageResponseTime: Double? // Seconds to answer
    
    // Metadata
    var tags: [String]             // [noun, animal, chapter-3]
    var source: String?            // "School Textbook p.42"
    var notes: String?             // Additional context
    
    init(
        front: String,
        back: String,
        deckId: UUID,
        exampleSentence: String? = nil
    ) {
        self.id = UUID()
        self.deckId = deckId
        self.front = front
        self.back = back
        self.exampleSentence = exampleSentence
        
        // SM-2 defaults
        self.easinessFactor = 2.5
        self.repetitions = 0
        self.interval = 0
        self.nextReviewDate = Date()
        
        // Learning queue defaults
        self.cardState = "learning"  // New cards start in learning phase
        self.learningStep = 0
        
        // Stats defaults
        self.createdDate = Date()
        self.timesReviewed = 0
        self.timesCorrect = 0
        self.tags = []
    }
}


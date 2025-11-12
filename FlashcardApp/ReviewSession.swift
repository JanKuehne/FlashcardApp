//
//  ReviewSession.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import Foundation
import SwiftData

@Model
final class ReviewSession {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var deckId: UUID
    
    // Session Results
    var cardsReviewed: Int
    var correctAnswers: Int
    var xpEarned: Int
    var durationSeconds: Int
    
    init(deckId: UUID) {
        self.id = UUID()
        self.deckId = deckId
        self.startDate = Date()
        self.cardsReviewed = 0
        self.correctAnswers = 0
        self.xpEarned = 0
        self.durationSeconds = 0
    }
}

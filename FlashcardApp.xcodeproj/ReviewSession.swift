//
//  ReviewSession.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 17.12.24.
//

import Foundation
import SwiftData

@Model
final class ReviewSession {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var deckId: UUID
    
    // Session Statistics
    var cardsReviewed: Int
    var correctAnswers: Int
    var wrongAnswers: Int
    var hardAnswers: Int
    
    // XP & Progress
    var xpEarned: Int
    var sessionDuration: TimeInterval // in seconds
    
    // Computed properties
    var accuracy: Double {
        guard cardsReviewed > 0 else { return 0 }
        return Double(correctAnswers) / Double(cardsReviewed) * 100
    }
    
    var isComplete: Bool {
        endDate != nil
    }
    
    init(deckId: UUID) {
        self.id = UUID()
        self.startDate = Date()
        self.endDate = nil
        self.deckId = deckId
        self.cardsReviewed = 0
        self.correctAnswers = 0
        self.wrongAnswers = 0
        self.hardAnswers = 0
        self.xpEarned = 0
        self.sessionDuration = 0
    }
    
    /// Mark session as complete
    func complete() {
        if endDate == nil {
            endDate = Date()
            sessionDuration = endDate!.timeIntervalSince(startDate)
        }
    }
    
    /// Record a card review result
    func recordReview(correct: Bool, difficulty: ReviewDifficulty) {
        cardsReviewed += 1
        
        switch difficulty {
        case .wrong:
            wrongAnswers += 1
        case .hard:
            hardAnswers += 1
            correctAnswers += 1
        case .easy:
            correctAnswers += 1
        }
        
        // Calculate XP based on difficulty
        if correct {
            xpEarned += difficulty.xpValue
        }
    }
}

// MARK: - Review Difficulty

enum ReviewDifficulty {
    case wrong   // 0 XP
    case hard    // 5 XP
    case easy    // 10 XP
    
    var xpValue: Int {
        switch self {
        case .wrong: return 0
        case .hard: return 5
        case .easy: return 10
        }
    }
    
    var label: String {
        switch self {
        case .wrong: return "FALSCH"
        case .hard: return "SCHWER"
        case .easy: return "EINFACH"
        }
    }
    
    var color: String {
        switch self {
        case .wrong: return "#FF3B30"
        case .hard: return "#FF9500"
        case .easy: return "#34C759"
        }
    }
}

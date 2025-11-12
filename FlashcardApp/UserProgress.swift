//
//  UserProgress.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    
    // XP & Leveling
    var totalXP: Int
    var currentLevel: Int
    
    // Streaks
    var currentStreak: Int         // Consecutive days
    var longestStreak: Int
    var lastCompletionDate: Date?  // Track daily completion
    
    // Session Stats
    var totalCardsReviewed: Int
    var totalCorrectAnswers: Int
    var totalStudyTimeSeconds: Int
    
    // Achievements (future: array of achievement IDs)
    var unlockedAchievements: [String]
    
    // Settings
    var dailyGoal: Int             // Default 20
    var notificationTime: Date?    // Reminder time
    var soundEnabled: Bool
    var animationsEnabled: Bool
    
    init() {
        self.id = UUID()
        self.totalXP = 0
        self.currentLevel = 1
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalCardsReviewed = 0
        self.totalCorrectAnswers = 0
        self.totalStudyTimeSeconds = 0
        self.unlockedAchievements = []
        self.dailyGoal = 20
        self.soundEnabled = true
        self.animationsEnabled = true
    }
}

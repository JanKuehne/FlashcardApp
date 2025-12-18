//
//  AchievementManager.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 15.12.25.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class AchievementManager: ObservableObject {
    private var modelContext: ModelContext
    @Published var newlyUnlockedAchievement: Achievement?
    @Published var showUnlockAnimation = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Check and Update Achievements
    
    func checkAchievements(
        userProgress: UserProgress,
        recentSession: ReviewSession? = nil,
        flashcards: [Flashcard] = []
    ) {
        let achievements = fetchAllAchievements()
        
        for achievement in achievements where !achievement.isUnlocked {
            updateAchievementProgress(
                achievement: achievement,
                userProgress: userProgress,
                recentSession: recentSession,
                flashcards: flashcards
            )
            
            if achievement.isComplete && !achievement.isUnlocked {
                unlockAchievement(achievement)
            }
        }
    }
    
    private func updateAchievementProgress(
        achievement: Achievement,
        userProgress: UserProgress,
        recentSession: ReviewSession?,
        flashcards: [Flashcard]
    ) {
        switch achievement.category {
        case .streak:
            updateStreakAchievements(achievement: achievement, userProgress: userProgress)
            
        case .cards:
            updateCardsAchievements(achievement: achievement, userProgress: userProgress)
            
        case .accuracy:
            updateAccuracyAchievements(achievement: achievement, recentSession: recentSession, userProgress: userProgress)
            
        case .speed:
            updateSpeedAchievements(achievement: achievement, recentSession: recentSession)
            
        case .dedication:
            updateDedicationAchievements(achievement: achievement, recentSession: recentSession, userProgress: userProgress)
            
        case .mastery:
            updateMasteryAchievements(achievement: achievement, userProgress: userProgress, flashcards: flashcards)
            
        case .special:
            updateSpecialAchievements(achievement: achievement, flashcards: flashcards, userProgress: userProgress)
        }
    }
    
    // MARK: - Category-Specific Updates
    
    private func updateStreakAchievements(achievement: Achievement, userProgress: UserProgress) {
        achievement.progress = userProgress.currentStreak
    }
    
    private func updateCardsAchievements(achievement: Achievement, userProgress: UserProgress) {
        achievement.progress = userProgress.totalCardsReviewed
    }
    
    private func updateAccuracyAchievements(achievement: Achievement, recentSession: ReviewSession?, userProgress: UserProgress) {
        guard let session = recentSession else { return }
        
        let sessionAccuracy = session.cardsReviewed > 0 
            ? Int((Double(session.correctAnswers) / Double(session.cardsReviewed)) * 100)
            : 0
        
        if achievement.title == "Sharp Shooter" {
            achievement.progress = max(achievement.progress, sessionAccuracy)
        } else if achievement.title == "Perfect Round" {
            achievement.progress = sessionAccuracy == 100 ? 100 : achievement.progress
        } else if achievement.title == "Perfectionist" {
            if sessionAccuracy == 100 {
                achievement.progress += 1
            }
        } else if achievement.title == "Flawless" {
            if sessionAccuracy == 100 {
                achievement.progress += 1
            }
        }
    }
    
    private func updateSpeedAchievements(achievement: Achievement, recentSession: ReviewSession?) {
        guard let session = recentSession else { return }
        achievement.progress = max(achievement.progress, session.cardsReviewed)
    }
    
    private func updateDedicationAchievements(achievement: Achievement, recentSession: ReviewSession?, userProgress: UserProgress) {
        guard let session = recentSession else { return }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: session.startDate)
        
        if achievement.title == "Early Bird" && hour < 8 {
            achievement.progress = 1
        } else if achievement.title == "Night Owl" && hour >= 22 {
            achievement.progress = 1
        } else if achievement.title == "Dedicated" {
            achievement.progress = userProgress.currentStreak
        } else if achievement.title == "Overachiever" {
            let todayCards = getTodayCardsCount()
            if todayCards >= userProgress.dailyGoal * 2 {
                achievement.progress = 1
            }
        }
    }
    
    private func updateMasteryAchievements(achievement: Achievement, userProgress: UserProgress, flashcards: [Flashcard]) {
        if achievement.title == "Polyglot Beginner" {
            let uniqueLanguages = Set(fetchAllDecks().map { $0.targetLanguage })
            achievement.progress = uniqueLanguages.count
        } else if achievement.title.starts(with: "Level") {
            let currentLevel = calculateLevel(totalXP: userProgress.totalXP)
            achievement.progress = currentLevel
        }
    }
    
    private func updateSpecialAchievements(achievement: Achievement, flashcards: [Flashcard], userProgress: UserProgress) {
        if achievement.title == "First Blood" {
            achievement.progress = flashcards.isEmpty ? 0 : 1
        } else if achievement.title == "Weekend Warrior" {
            let calendar = Calendar.current
            let today = Date()
            let isSaturday = calendar.component(.weekday, from: today) == 7
            let isSunday = calendar.component(.weekday, from: today) == 1
            
            if isSaturday || isSunday {
                let todayCards = getTodayCardsCount()
                if todayCards > 0 {
                    // Check if both weekend days have been studied
                    achievement.progress = checkWeekendStudy() ? 1 : 0
                }
            }
        }
    }
    
    // MARK: - Unlock Achievement
    
    private func unlockAchievement(_ achievement: Achievement) {
        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        
        try? modelContext.save()
        
        // Trigger UI notification
        newlyUnlockedAchievement = achievement
        showUnlockAnimation = true
        
        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Auto-hide after 3 seconds
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation {
                showUnlockAnimation = false
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func fetchAllAchievements() -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>()
        let achievements = (try? modelContext.fetch(descriptor)) ?? []
        
        // Sort in memory by title to avoid enum comparison issues
        return achievements.sorted { $0.title < $1.title }
    }
    
    func initializeAchievements() {
        let existing = fetchAllAchievements()
        
        if existing.isEmpty {
            let defaultAchievements = Achievement.createDefaultAchievements()
            for achievement in defaultAchievements {
                modelContext.insert(achievement)
            }
            try? modelContext.save()
        }
    }
    
    private func fetchAllDecks() -> [Deck] {
        let descriptor = FetchDescriptor<Deck>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func getTodayCardsCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<ReviewSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        if let sessions = try? modelContext.fetch(descriptor) {
            return sessions
                .filter { Calendar.current.isDate($0.startDate, inSameDayAs: today) }
                .reduce(0) { $0 + $1.cardsReviewed }
        }
        return 0
    }
    
    private func checkWeekendStudy() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let saturday = calendar.date(bySetting: .weekday, value: 7, of: today),
              let sunday = calendar.date(bySetting: .weekday, value: 1, of: today) else {
            return false
        }
        
        let descriptor = FetchDescriptor<ReviewSession>()
        guard let sessions = try? modelContext.fetch(descriptor) else { return false }
        
        let saturdayStudied = sessions.contains { calendar.isDate($0.startDate, inSameDayAs: saturday) }
        let sundayStudied = sessions.contains { calendar.isDate($0.startDate, inSameDayAs: sunday) }
        
        return saturdayStudied && sundayStudied
    }
    
    private func calculateLevel(totalXP: Int) -> Int {
        var level = 1
        var xpRequired = 0
        
        while xpRequired <= totalXP {
            level += 1
            xpRequired = level * level * 100
        }
        
        return level - 1
    }
    
    // MARK: - Statistics
    
    func getAchievementStats() -> (unlocked: Int, total: Int, percentage: Double) {
        let all = fetchAllAchievements()
        let unlocked = all.filter { $0.isUnlocked }.count
        let total = all.count
        let percentage = total > 0 ? Double(unlocked) / Double(total) * 100 : 0
        
        return (unlocked, total, percentage)
    }
    
    func getRecentAchievements(limit: Int = 5) -> [Achievement] {
        let all = fetchAllAchievements()
        return all
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedDate ?? Date.distantPast) > ($1.unlockedDate ?? Date.distantPast) }
            .prefix(limit)
            .map { $0 }
    }
}

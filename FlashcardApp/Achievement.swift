//
//  Achievement.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 15.12.25.
//

import Foundation
import SwiftData

@Model
class Achievement {
    var id: UUID
    var title: String
    var achievementDescription: String
    var icon: String  // Emoji or SF Symbol name
    var category: AchievementCategory
    var tier: AchievementTier
    var requirement: Int  // The value needed to unlock
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Int  // Current progress toward requirement
    
    init(
        id: UUID = UUID(),
        title: String,
        achievementDescription: String,
        icon: String,
        category: AchievementCategory,
        tier: AchievementTier,
        requirement: Int,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil,
        progress: Int = 0
    ) {
        self.id = id
        self.title = title
        self.achievementDescription = achievementDescription
        self.icon = icon
        self.category = category
        self.tier = tier
        self.requirement = requirement
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.progress = progress
    }
    
    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(requirement))
    }
    
    var isComplete: Bool {
        progress >= requirement
    }
}

enum AchievementCategory: String, Codable, Comparable {
    case streak = "連続"        // Streak-based
    case cards = "カード"       // Card count
    case accuracy = "正確"      // Accuracy
    case speed = "速度"         // Speed
    case dedication = "献身"    // Dedication (total study)
    case mastery = "熟練"       // Mastery (advanced achievements)
    case special = "特別"       // Special/hidden achievements
    
    var emoji: String {
        switch self {
        case .streak: return "🔥"
        case .cards: return "📚"
        case .accuracy: return "🎯"
        case .speed: return "⚡️"
        case .dedication: return "💪"
        case .mastery: return "🏅"
        case .special: return "✨"
        }
    }
    
    var displayName: String {
        switch self {
        case .streak: return "STREAK"
        case .cards: return "CARDS"
        case .accuracy: return "ACCURACY"
        case .speed: return "SPEED"
        case .dedication: return "DEDICATION"
        case .mastery: return "MASTERY"
        case .special: return "SPECIAL"
        }
    }
    
    var color: String {
        switch self {
        case .streak: return "orange"
        case .cards: return "blue"
        case .accuracy: return "green"
        case .speed: return "purple"
        case .dedication: return "pink"
        case .mastery: return "yellow"
        case .special: return "rainbow"
        }
    }
    
    // Implement Comparable
    static func < (lhs: AchievementCategory, rhs: AchievementCategory) -> Bool {
        let order: [AchievementCategory] = [.streak, .cards, .accuracy, .speed, .dedication, .mastery, .special]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

enum AchievementTier: String, Codable, Comparable {
    case bronze = "銅"
    case silver = "銀"
    case gold = "金"
    case platinum = "白金"
    case diamond = "💎"
    
    var displayName: String {
        switch self {
        case .bronze: return "BRONZE"
        case .silver: return "SILVER"
        case .gold: return "GOLD"
        case .platinum: return "PLATINUM"
        case .diamond: return "DIAMOND"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .bronze: return 1
        case .silver: return 2
        case .gold: return 3
        case .platinum: return 4
        case .diamond: return 5
        }
    }
    
    // Implement Comparable
    static func < (lhs: AchievementTier, rhs: AchievementTier) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Predefined Achievements
extension Achievement {
    static func createDefaultAchievements() -> [Achievement] {
        [
            // STREAK ACHIEVEMENTS
            Achievement(
                title: "First Steps",
                achievementDescription: "Complete your first day",
                icon: "🔥",
                category: .streak,
                tier: .bronze,
                requirement: 1
            ),
            Achievement(
                title: "Week Warrior",
                achievementDescription: "Maintain a 7-day streak",
                icon: "⚡️",
                category: .streak,
                tier: .silver,
                requirement: 7
            ),
            Achievement(
                title: "Month Master",
                achievementDescription: "Maintain a 30-day streak",
                icon: "🌟",
                category: .streak,
                tier: .gold,
                requirement: 30
            ),
            Achievement(
                title: "Unstoppable",
                achievementDescription: "Maintain a 100-day streak",
                icon: "👑",
                category: .streak,
                tier: .platinum,
                requirement: 100
            ),
            Achievement(
                title: "Legend",
                achievementDescription: "Maintain a 365-day streak",
                icon: "🏆",
                category: .streak,
                tier: .diamond,
                requirement: 365
            ),
            
            // CARDS ACHIEVEMENTS
            Achievement(
                title: "Beginner",
                achievementDescription: "Review 10 cards",
                icon: "📝",
                category: .cards,
                tier: .bronze,
                requirement: 10
            ),
            Achievement(
                title: "Student",
                achievementDescription: "Review 100 cards",
                icon: "📚",
                category: .cards,
                tier: .silver,
                requirement: 100
            ),
            Achievement(
                title: "Scholar",
                achievementDescription: "Review 500 cards",
                icon: "🎓",
                category: .cards,
                tier: .gold,
                requirement: 500
            ),
            Achievement(
                title: "Professor",
                achievementDescription: "Review 1,000 cards",
                icon: "👨‍🏫",
                category: .cards,
                tier: .platinum,
                requirement: 1000
            ),
            Achievement(
                title: "Grand Master",
                achievementDescription: "Review 5,000 cards",
                icon: "🧙‍♂️",
                category: .cards,
                tier: .diamond,
                requirement: 5000
            ),
            
            // ACCURACY ACHIEVEMENTS
            Achievement(
                title: "Sharp Shooter",
                achievementDescription: "Get 90% accuracy in a session",
                icon: "🎯",
                category: .accuracy,
                tier: .bronze,
                requirement: 90
            ),
            Achievement(
                title: "Perfect Round",
                achievementDescription: "Get 100% accuracy in a session",
                icon: "💯",
                category: .accuracy,
                tier: .silver,
                requirement: 100
            ),
            Achievement(
                title: "Perfectionist",
                achievementDescription: "Get 100% accuracy 5 times",
                icon: "✨",
                category: .accuracy,
                tier: .gold,
                requirement: 5
            ),
            Achievement(
                title: "Flawless",
                achievementDescription: "Get 100% accuracy 20 times",
                icon: "💎",
                category: .accuracy,
                tier: .platinum,
                requirement: 20
            ),
            
            // SPEED ACHIEVEMENTS
            Achievement(
                title: "Speed Demon",
                achievementDescription: "Complete 20 cards in one session",
                icon: "⚡️",
                category: .speed,
                tier: .bronze,
                requirement: 20
            ),
            Achievement(
                title: "Lightning Fast",
                achievementDescription: "Complete 50 cards in one session",
                icon: "⚡️",
                category: .speed,
                tier: .silver,
                requirement: 50
            ),
            Achievement(
                title: "Sonic Speed",
                achievementDescription: "Complete 100 cards in one session",
                icon: "💨",
                category: .speed,
                tier: .gold,
                requirement: 100
            ),
            
            // DEDICATION ACHIEVEMENTS
            Achievement(
                title: "Early Bird",
                achievementDescription: "Complete a session before 8 AM",
                icon: "🌅",
                category: .dedication,
                tier: .bronze,
                requirement: 1
            ),
            Achievement(
                title: "Night Owl",
                achievementDescription: "Complete a session after 10 PM",
                icon: "🦉",
                category: .dedication,
                tier: .bronze,
                requirement: 1
            ),
            Achievement(
                title: "Dedicated",
                achievementDescription: "Study 7 days in a row",
                icon: "💪",
                category: .dedication,
                tier: .silver,
                requirement: 7
            ),
            Achievement(
                title: "Overachiever",
                achievementDescription: "Complete 2x your daily goal",
                icon: "🚀",
                category: .dedication,
                tier: .gold,
                requirement: 1
            ),
            
            // MASTERY ACHIEVEMENTS
            Achievement(
                title: "Polyglot Beginner",
                achievementDescription: "Learn cards in 2 languages",
                icon: "🌍",
                category: .mastery,
                tier: .silver,
                requirement: 2
            ),
            Achievement(
                title: "Level 5",
                achievementDescription: "Reach Level 5",
                icon: "⭐️",
                category: .mastery,
                tier: .bronze,
                requirement: 5
            ),
            Achievement(
                title: "Level 10",
                achievementDescription: "Reach Level 10",
                icon: "🌟",
                category: .mastery,
                tier: .silver,
                requirement: 10
            ),
            Achievement(
                title: "Level 25",
                achievementDescription: "Reach Level 25",
                icon: "✨",
                category: .mastery,
                tier: .gold,
                requirement: 25
            ),
            Achievement(
                title: "Level 50",
                achievementDescription: "Reach Level 50",
                icon: "💫",
                category: .mastery,
                tier: .platinum,
                requirement: 50
            ),
            
            // SPECIAL ACHIEVEMENTS
            Achievement(
                title: "First Blood",
                achievementDescription: "Create your first flashcard",
                icon: "🎴",
                category: .special,
                tier: .bronze,
                requirement: 1
            ),
            Achievement(
                title: "Comeback Kid",
                achievementDescription: "Restore a broken streak",
                icon: "🔄",
                category: .special,
                tier: .silver,
                requirement: 1
            ),
            Achievement(
                title: "Weekend Warrior",
                achievementDescription: "Study on both Saturday and Sunday",
                icon: "📅",
                category: .special,
                tier: .bronze,
                requirement: 1
            ),
            Achievement(
                title: "Marathon",
                achievementDescription: "Study for 30 minutes straight",
                icon: "🏃",
                category: .special,
                tier: .gold,
                requirement: 30
            )
        ]
    }
}

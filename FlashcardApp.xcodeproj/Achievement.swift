//
//  Achievement.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 17.12.24.
//

import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var title: String
    var achievementDescription: String
    var iconName: String // SF Symbol name
    var category: AchievementCategory
    var tier: AchievementTier
    
    // Progress tracking
    var progress: Int
    var requirement: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    // Computed properties
    var isComplete: Bool {
        progress >= requirement
    }
    
    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(progress) / Double(requirement) * 100, 100)
    }
    
    init(
        title: String,
        description: String,
        iconName: String,
        category: AchievementCategory,
        tier: AchievementTier = .bronze,
        requirement: Int
    ) {
        self.id = UUID()
        self.title = title
        self.achievementDescription = description
        self.iconName = iconName
        self.category = category
        self.tier = tier
        self.progress = 0
        self.requirement = requirement
        self.isUnlocked = false
    }
    
    /// Create all default achievements for the app
    static func createDefaultAchievements() -> [Achievement] {
        var achievements: [Achievement] = []
        
        // MARK: - Streak Achievements
        achievements.append(Achievement(
            title: "Getting Started",
            description: "Study for 3 days in a row",
            iconName: "flame",
            category: .streak,
            tier: .bronze,
            requirement: 3
        ))
        
        achievements.append(Achievement(
            title: "On Fire",
            description: "Study for 7 days in a row",
            iconName: "flame.fill",
            category: .streak,
            tier: .silver,
            requirement: 7
        ))
        
        achievements.append(Achievement(
            title: "Unstoppable",
            description: "Study for 30 days in a row",
            iconName: "sparkles",
            category: .streak,
            tier: .gold,
            requirement: 30
        ))
        
        achievements.append(Achievement(
            title: "Legendary",
            description: "Study for 100 days in a row",
            iconName: "star.fill",
            category: .streak,
            tier: .platinum,
            requirement: 100
        ))
        
        // MARK: - Cards Achievements
        achievements.append(Achievement(
            title: "First Steps",
            description: "Review 50 cards",
            iconName: "rectangle.stack",
            category: .cards,
            tier: .bronze,
            requirement: 50
        ))
        
        achievements.append(Achievement(
            title: "Card Collector",
            description: "Review 500 cards",
            iconName: "rectangle.stack.fill",
            category: .cards,
            tier: .silver,
            requirement: 500
        ))
        
        achievements.append(Achievement(
            title: "Master Reviewer",
            description: "Review 2,000 cards",
            iconName: "square.stack.3d.up.fill",
            category: .cards,
            tier: .gold,
            requirement: 2000
        ))
        
        achievements.append(Achievement(
            title: "Ultimate Scholar",
            description: "Review 10,000 cards",
            iconName: "books.vertical.fill",
            category: .cards,
            tier: .platinum,
            requirement: 10000
        ))
        
        // MARK: - Accuracy Achievements
        achievements.append(Achievement(
            title: "Sharp Shooter",
            description: "Get 80% accuracy in a session",
            iconName: "target",
            category: .accuracy,
            tier: .bronze,
            requirement: 80
        ))
        
        achievements.append(Achievement(
            title: "Perfect Round",
            description: "Get 100% accuracy in a session",
            iconName: "checkmark.circle.fill",
            category: .accuracy,
            tier: .silver,
            requirement: 100
        ))
        
        achievements.append(Achievement(
            title: "Perfectionist",
            description: "Get 100% accuracy in 10 sessions",
            iconName: "sparkles",
            category: .accuracy,
            tier: .gold,
            requirement: 10
        ))
        
        achievements.append(Achievement(
            title: "Flawless",
            description: "Get 100% accuracy in 50 sessions",
            iconName: "crown.fill",
            category: .accuracy,
            tier: .platinum,
            requirement: 50
        ))
        
        // MARK: - Speed Achievements
        achievements.append(Achievement(
            title: "Quick Study",
            description: "Review 20 cards in one session",
            iconName: "bolt.fill",
            category: .speed,
            tier: .bronze,
            requirement: 20
        ))
        
        achievements.append(Achievement(
            title: "Speed Demon",
            description: "Review 50 cards in one session",
            iconName: "hare.fill",
            category: .speed,
            tier: .silver,
            requirement: 50
        ))
        
        achievements.append(Achievement(
            title: "Lightning",
            description: "Review 100 cards in one session",
            iconName: "bolt.circle.fill",
            category: .speed,
            tier: .gold,
            requirement: 100
        ))
        
        // MARK: - Dedication Achievements
        achievements.append(Achievement(
            title: "Early Bird",
            description: "Study before 8 AM",
            iconName: "sunrise.fill",
            category: .dedication,
            tier: .bronze,
            requirement: 1
        ))
        
        achievements.append(Achievement(
            title: "Night Owl",
            description: "Study after 10 PM",
            iconName: "moon.stars.fill",
            category: .dedication,
            tier: .bronze,
            requirement: 1
        ))
        
        achievements.append(Achievement(
            title: "Dedicated",
            description: "Maintain a 14-day streak",
            iconName: "calendar",
            category: .dedication,
            tier: .silver,
            requirement: 14
        ))
        
        achievements.append(Achievement(
            title: "Overachiever",
            description: "Complete 2x your daily goal in one day",
            iconName: "chart.bar.fill",
            category: .dedication,
            tier: .gold,
            requirement: 1
        ))
        
        // MARK: - Mastery Achievements
        achievements.append(Achievement(
            title: "Level 5",
            description: "Reach Level 5",
            iconName: "star",
            category: .mastery,
            tier: .bronze,
            requirement: 5
        ))
        
        achievements.append(Achievement(
            title: "Level 10",
            description: "Reach Level 10",
            iconName: "star.fill",
            category: .mastery,
            tier: .silver,
            requirement: 10
        ))
        
        achievements.append(Achievement(
            title: "Level 20",
            description: "Reach Level 20",
            iconName: "sparkle",
            category: .mastery,
            tier: .gold,
            requirement: 20
        ))
        
        achievements.append(Achievement(
            title: "Level 50",
            description: "Reach Level 50",
            iconName: "crown.fill",
            category: .mastery,
            tier: .platinum,
            requirement: 50
        ))
        
        achievements.append(Achievement(
            title: "Polyglot Beginner",
            description: "Study 2 different languages",
            iconName: "globe",
            category: .mastery,
            tier: .silver,
            requirement: 2
        ))
        
        // MARK: - Special Achievements
        achievements.append(Achievement(
            title: "First Blood",
            description: "Add your first flashcard",
            iconName: "plus.circle.fill",
            category: .special,
            tier: .bronze,
            requirement: 1
        ))
        
        achievements.append(Achievement(
            title: "Weekend Warrior",
            description: "Study on both weekend days",
            iconName: "calendar.badge.clock",
            category: .special,
            tier: .silver,
            requirement: 1
        ))
        
        return achievements
    }
}

// MARK: - Achievement Category

enum AchievementCategory: String, Codable {
    case streak
    case cards
    case accuracy
    case speed
    case dedication
    case mastery
    case special
    
    var displayName: String {
        switch self {
        case .streak: return "Streaks"
        case .cards: return "Cards"
        case .accuracy: return "Accuracy"
        case .speed: return "Speed"
        case .dedication: return "Dedication"
        case .mastery: return "Mastery"
        case .special: return "Special"
        }
    }
    
    var emoji: String {
        switch self {
        case .streak: return "🔥"
        case .cards: return "📚"
        case .accuracy: return "🎯"
        case .speed: return "⚡"
        case .dedication: return "💪"
        case .mastery: return "👑"
        case .special: return "✨"
        }
    }
}

// MARK: - Achievement Tier

enum AchievementTier: String, Codable {
    case bronze
    case silver
    case gold
    case platinum
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: String {
        switch self {
        case .bronze: return "#CD7F32"
        case .silver: return "#C0C0C0"
        case .gold: return "#FFD700"
        case .platinum: return "#E5E4E2"
        }
    }
}

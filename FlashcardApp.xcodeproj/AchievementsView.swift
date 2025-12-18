//
//  AchievementsView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 17.12.24.
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var achievements: [Achievement]
    
    @State private var selectedCategory: AchievementCategory?
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }
    
    private var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    private var progressPercentage: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievements.count) * 100
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                HalftonePattern()
                    .opacity(0.03)
                    .allowsHitTesting(false)
                
                VStack(spacing: 20) {
                    // Progress Header
                    VStack(spacing: 12) {
                        Text("🏆")
                            .font(.system(size: 60))
                        
                        Text("ACHIEVEMENTS")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        
                        Text("\(unlockedCount) / \(achievements.count) Freigeschaltet")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        ProgressView(value: progressPercentage, total: 100)
                            .tint(.yellow)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryButton(
                                category: nil,
                                isSelected: selectedCategory == nil
                            ) {
                                withAnimation {
                                    selectedCategory = nil
                                }
                            }
                            
                            ForEach([AchievementCategory.streak, .cards, .accuracy, .speed, .dedication, .mastery, .special], id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Achievements List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAchievements.sorted(by: { $0.tier.rawValue < $1.tier.rawValue })) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let category: AchievementCategory?
    let isSelected: Bool
    let action: () -> Void
    
    private var label: String {
        category?.emoji ?? "📋"
    }
    
    private var title: String {
        category?.displayName ?? "Alle"
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.title2)
                
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                : LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.05)], startPoint: .top, endPoint: .bottom)
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.white.opacity(0.2), lineWidth: 2)
            )
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    
    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return .orange
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        case .diamond: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                        ? LinearGradient(colors: [tierColor, tierColor.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 60, height: 60)
                
                // Display icon (can be emoji or SF Symbol name)
                if achievement.icon.contains(".") {
                    // It's likely an SF Symbol name
                    Image(systemName: achievement.icon)
                        .font(.system(size: 28))
                        .foregroundColor(achievement.isUnlocked ? .white : .gray.opacity(0.5))
                } else {
                    // It's an emoji
                    Text(achievement.icon)
                        .font(.system(size: 28))
                        .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                
                Text(achievement.achievementDescription)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    HStack(spacing: 8) {
                        ProgressView(value: Double(achievement.progress), total: Double(achievement.requirement))
                            .tint(tierColor)
                        
                        Text("\(achievement.progress)/\(achievement.requirement)")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(tierColor)
                    }
                } else if let date = achievement.unlockedDate {
                    Text("Freigeschaltet: \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Tier Badge
            Text(achievement.tier.displayName)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tierColor.opacity(0.3))
                .cornerRadius(6)
        }
        .padding()
        .background(
            achievement.isUnlocked
            ? Color.white.opacity(0.08)
            : Color.white.opacity(0.03)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.isUnlocked ? tierColor.opacity(0.5) : Color.white.opacity(0.1),
                    lineWidth: achievement.isUnlocked ? 2 : 1
                )
        )
        .cornerRadius(16)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    AchievementsView()
        .modelContainer(for: [Achievement.self])
}

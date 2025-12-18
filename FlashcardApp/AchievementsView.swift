//
//  AchievementsView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 15.12.25.
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var achievements: [Achievement]
    @State private var selectedCategory: AchievementCategory?
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }
    
    private var groupedAchievements: [AchievementCategory: [Achievement]] {
        Dictionary(grouping: filteredAchievements) { $0.category }
    }
    
    private var stats: (unlocked: Int, total: Int, percentage: Double) {
        let unlocked = achievements.filter { $0.isUnlocked }.count
        let total = achievements.count
        let percentage = total > 0 ? Double(unlocked) / Double(total) * 100 : 0
        return (unlocked, total, percentage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                HalftonePattern()
                    .opacity(0.02)
                    .allowsHitTesting(false)
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        statsSection
                        
                        categoryFilter
                        
                        achievementsGrid
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("ACHIEVEMENTS")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("実績")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.yellow.opacity(0.8))
            
            Text("DEINE ERFOLGE")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .textCase(.uppercase)
            
            Text("Unlock badges by completing challenges")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 10)
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text("🏆")
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(stats.unlocked) / \(stats.total)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("FREIGESCHALTET")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .textCase(.uppercase)
                }
                
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (stats.percentage / 100))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
            }
            .frame(height: 24)
            
            Text("\(Int(stats.percentage))% KOMPLETT")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 3)
        )
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "ALL",
                    isSelected: selectedCategory == nil,
                    color: .white
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                }
                
                ForEach([
                    AchievementCategory.streak,
                    .cards,
                    .accuracy,
                    .speed,
                    .dedication,
                    .mastery,
                    .special
                ], id: \.self) { category in
                    CategoryFilterButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        color: categoryColor(category)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(filteredAchievements.sorted(by: {
                if $0.category != $1.category {
                    return $0.category.displayName < $1.category.displayName
                }
                return $0.tier.sortOrder < $1.tier.sortOrder
            }), id: \.id) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
    }
    
    private func categoryColor(_ category: AchievementCategory) -> Color {
        switch category {
        case .streak: return .orange
        case .cards: return .blue
        case .accuracy: return .green
        case .speed: return .purple
        case .dedication: return .pink
        case .mastery: return .yellow
        case .special: return .cyan
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? color
                    : Color.white.opacity(0.1)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color.white.opacity(0.3), lineWidth: 2)
                )
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        case .diamond: return .purple
        }
    }
    
    private var categoryColor: Color {
        switch achievement.category {
        case .streak: return .orange
        case .cards: return .blue
        case .accuracy: return .green
        case .speed: return .purple
        case .dedication: return .pink
        case .mastery: return .yellow
        case .special: return .cyan
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                        ? LinearGradient(
                            colors: [categoryColor, categoryColor.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(
                                achievement.isUnlocked ? tierColor : Color.gray,
                                lineWidth: 3
                            )
                    )
                
                Text(achievement.icon)
                    .font(.system(size: 36))
                    .grayscale(achievement.isUnlocked ? 0 : 1)
                    .opacity(achievement.isUnlocked ? 1 : 0.4)
            }
            
            // Title
            Text(achievement.title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .textCase(.uppercase)
            
            // Tier badge
            Text(achievement.tier.rawValue)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(achievement.isUnlocked ? tierColor : .gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            
            // Progress bar (if not unlocked)
            if !achievement.isUnlocked {
                VStack(spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(categoryColor.opacity(0.6))
                                .frame(width: geometry.size.width * achievement.progressPercentage)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(achievement.progress)/\(achievement.requirement)")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                // Unlocked date
                if let date = achievement.unlockedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Description
            Text(achievement.achievementDescription)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            achievement.isUnlocked
            ? Color.white.opacity(0.08)
            : Color.white.opacity(0.03)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.isUnlocked ? categoryColor.opacity(0.5) : Color.white.opacity(0.2),
                    lineWidth: achievement.isUnlocked ? 3 : 2
                )
        )
        .cornerRadius(16)
        .shadow(
            color: achievement.isUnlocked ? categoryColor.opacity(0.3) : .clear,
            radius: 8,
            y: 4
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    let context = container.mainContext
    
    // Add sample achievements
    for achievement in Achievement.createDefaultAchievements().prefix(10) {
        if Int.random(in: 0...2) == 0 {
            achievement.isUnlocked = true
            achievement.unlockedDate = Date()
        } else {
            achievement.progress = Int.random(in: 0...achievement.requirement)
        }
        context.insert(achievement)
    }
    
    return AchievementsView()
        .modelContainer(container)
}

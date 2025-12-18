//
//  AchievementUnlockView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 15.12.25.
//

import SwiftUI
import SwiftData

struct AchievementUnlockView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -180
    @State private var opacity: Double = 0
    @State private var glowOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAnimation()
                }
            
            VStack(spacing: 20) {
                // Japanese text
                Text("実績解除!")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.yellow)
                    .opacity(opacity)
                
                // Main card
                VStack(spacing: 16) {
                    // Glowing badge
                    ZStack {
                        // Glow effects
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [tierColor.opacity(0.6), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .blur(radius: 20)
                            .opacity(glowOpacity)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [tierColor.opacity(0.8), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 10)
                            .opacity(glowOpacity)
                        
                        // Main badge - supports both icon (emoji) and SF Symbol
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [tierColor, tierColor.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color.yellow, lineWidth: 4)
                                )
                                .shadow(color: tierColor.opacity(0.5), radius: 10)
                            
                            // Display icon (can be emoji or SF Symbol name)
                            if achievement.icon.contains(".") {
                                // It's likely an SF Symbol name
                                Image(systemName: achievement.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            } else {
                                // It's an emoji
                                Text(achievement.icon)
                                    .font(.system(size: 50))
                            }
                        }
                        .scaleEffect(scale)
                        .rotation3DEffect(
                            .degrees(rotation),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        
                        // Sparkles
                        ForEach(0..<8) { i in
                            Image(systemName: "sparkle")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                                .offset(
                                    x: cos(Double(i) * .pi / 4) * 70,
                                    y: sin(Double(i) * .pi / 4) * 70
                                )
                                .opacity(opacity)
                                .scaleEffect(scale)
                        }
                    }
                    .frame(height: 160)
                    
                    // Achievement info
                    VStack(spacing: 8) {
                        Text("ACHIEVEMENT UNLOCKED")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .textCase(.uppercase)
                        
                        Text(achievement.title)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .textCase(.uppercase)
                        
                        Text(achievement.tier.displayName)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(tierColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                        
                        Text(achievement.achievementDescription)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .opacity(opacity)
                    
                    // Close button
                    Button(action: dismissAnimation) {
                        Text("WEITER")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .opacity(opacity)
                    .padding(.top, 8)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(tierColor, lineWidth: 4)
                        )
                )
                .shadow(color: tierColor.opacity(0.5), radius: 20)
                .scaleEffect(scale)
            }
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                rotation = 0
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
    }
    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return .orange
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        case .diamond: return .purple
        }
    }
    
    private func dismissAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

// Preview for testing
#Preview {
    @Previewable @State var isShowing = true
    
    let achievement = Achievement(
        title: "Week Warrior",
        achievementDescription: "Maintain a 7-day streak",
        icon: "⚡️",
        category: .streak,
        tier: .gold,
        requirement: 7,
        isUnlocked: true
    )
    
    AchievementUnlockView(achievement: achievement, isShowing: $isShowing)
        .modelContainer(for: [Achievement.self])
}

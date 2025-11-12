//
//  ContentView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgress: [UserProgress]
    @Query private var decks: [Deck]
    
    @State private var showReviewSession = false
    @State private var cardsCompletedToday = 0
    @State private var showCelebration = false
    
    var progress: UserProgress {
        userProgress.first ?? UserProgress()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black.ignoresSafeArea()
                
                // Manga character backdrop (silhouettes)
                MangaBackdrop()
                    .opacity(0.15)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Top stats cards
                        HStack(spacing: 16) {
                            // Streak card
                            MangaStatCard(
                                topLabel: "日",
                                mainValue: "\(progress.currentStreak)",
                                bottomLabel: "STREAK",
                                color: .orange,
                                gradient: [Color.orange, Color.red]
                            )
                            
                            // Level card
                            MangaStatCard(
                                topLabel: "Lv",
                                mainValue: "\(currentLevel)",
                                bottomLabel: "\(progress.totalXP) XP",
                                color: .purple,
                                gradient: [Color.purple, Color.blue]
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // XP Progress bar
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("LEVEL \(currentLevel + 1)")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.purple)
                                    .textCase(.uppercase)
                                
                                Spacer()
                                
                                Text("\(xpProgress.current)/\(xpProgress.needed)")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.purple, Color.blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * (Double(xpProgress.current) / Double(xpProgress.needed)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                }
                            }
                            .frame(height: 20)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                        .padding(.horizontal)
                        
                        // Daily Goal section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("今日")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.blue.opacity(0.8))
                                
                                Text("TAGESZIEL")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                    .textCase(.uppercase)
                                
                                Spacer()
                                
                                if cardsCompletedToday >= progress.dailyGoal {
                                    Text("完")
                                        .font(.system(.title, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("\(cardsCompletedToday)")
                                    .font(.system(size: 48, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("/")
                                    .font(.system(.title, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Text("\(progress.dailyGoal)")
                                    .font(.system(.title, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("KARTEN")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.blue)
                                    .textCase(.uppercase)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            cardsCompletedToday >= progress.dailyGoal
                                                ? LinearGradient(colors: [Color.green, Color.green.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                                : LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .frame(width: geometry.size.width * min(1.0, Double(cardsCompletedToday) / Double(progress.dailyGoal)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                }
                            }
                            .frame(height: 24)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 4)
                        )
                        .padding(.horizontal)
                        
                        // Stats section
                        HStack(spacing: 16) {
                            MangaStatBox(
                                value: "\(progress.totalCardsReviewed)",
                                label: "GELERNT",
                                color: .blue
                            )
                            
                            MangaStatBox(
                                value: accuracyPercentage,
                                label: "GENAUIGKEIT",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 40)
                        
                        // Main action button
                        Button(action: {
                            showReviewSession = true
                        }) {
                            VStack(spacing: 8) {
                                Text("開始")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text(cardsCompletedToday >= progress.dailyGoal ? "WEITER ÜBEN" : "LERNEN STARTEN")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .textCase(.uppercase)
                                
                                Text("\(progress.dailyGoal) KARTEN")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 5)
                            )
                            .shadow(color: .blue.opacity(0.5), radius: 20, y: 10)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        .overlay(
                            Group {
                                if showCelebration {
                                    VStack {
                                        Text("🎉")
                                            .font(.system(size: 100))
                                            .scaleEffect(showCelebration ? 1.0 : 0.1)
                                            .opacity(showCelebration ? 0 : 1)
                                    }
                                }
                            }
                            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showCelebration)
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("DASHBOARD")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showReviewSession, onDismiss: {
                let previousCount = cardsCompletedToday
                updateCardsCompletedToday()
                
                if previousCount < progress.dailyGoal && cardsCompletedToday >= progress.dailyGoal {
                    showCelebration = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showCelebration = false
                    }
                }
            }) {
                ReviewSessionView()
            }
            .task {
                updateCardsCompletedToday()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                updateCardsCompletedToday()
            }
        }
    }
    
    var currentLevel: Int {
        calculateLevel(totalXP: progress.totalXP)
    }
    
    var xpProgress: (current: Int, needed: Int) {
        xpForNextLevel(currentLevel: currentLevel, currentXP: progress.totalXP)
    }
    
    var accuracyPercentage: String {
        guard progress.totalCardsReviewed > 0 else { return "0%" }
        let percentage = Int(Double(progress.totalCorrectAnswers) / Double(progress.totalCardsReviewed) * 100)
        return "\(percentage)%"
    }
    
    func calculateLevel(totalXP: Int) -> Int {
        var level = 1
        var xpRequired = 0
        
        while xpRequired <= totalXP {
            level += 1
            xpRequired = level * level * 100
        }
        
        return level - 1
    }
    
    func xpForNextLevel(currentLevel: Int, currentXP: Int) -> (current: Int, needed: Int) {
        let nextLevelXP = (currentLevel + 1) * (currentLevel + 1) * 100
        let currentLevelXP = currentLevel * currentLevel * 100
        
        return (
            current: currentXP - currentLevelXP,
            needed: nextLevelXP - currentLevelXP
        )
    }
    
    func updateCardsCompletedToday() {
        let today = Calendar.current.startOfDay(for: Date())
        
        let descriptor = FetchDescriptor<ReviewSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        if let sessions = try? modelContext.fetch(descriptor) {
            cardsCompletedToday = sessions
                .filter { Calendar.current.isDate($0.startDate, inSameDayAs: today) }
                .reduce(0) { $0 + $1.cardsReviewed }
        }
    }
}

struct MangaStatCard: View {
    let topLabel: String
    let mainValue: String
    let bottomLabel: String
    let color: Color
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Text(topLabel)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(color.opacity(0.8))
            
            Text(mainValue)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text(bottomLabel)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: gradient.map { $0.opacity(0.2) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.6), lineWidth: 4)
        )
        .cornerRadius(16)
    }
}

struct MangaStatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(value)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 3)
        )
        .cornerRadius(16)
    }
}

struct MangaBackdrop: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: -50, y: geometry.size.height * 0.3))
                    path.addLine(to: CGPoint(x: 100, y: geometry.size.height * 0.2))
                    path.addLine(to: CGPoint(x: 150, y: geometry.size.height * 0.8))
                    path.addLine(to: CGPoint(x: 50, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: -50, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width + 50, y: geometry.size.height * 0.4))
                    path.addLine(to: CGPoint(x: geometry.size.width - 100, y: geometry.size.height * 0.3))
                    path.addLine(to: CGPoint(x: geometry.size.width - 150, y: geometry.size.height * 0.9))
                    path.addLine(to: CGPoint(x: geometry.size.width - 50, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width + 50, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Flashcard.self, Deck.self, UserProgress.self, ReviewSession.self])
}

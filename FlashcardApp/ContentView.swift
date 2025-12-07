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
    @Query private var flashcards: [Flashcard]
    
    @State private var showReviewSession = false
    @State private var showAddCard = false
    @State private var showSettings = false
    @State private var cardsCompletedToday = 0
    @State private var showCelebration = false
    
    var progress: UserProgress {
        userProgress.first ?? UserProgress()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                HalftonePattern()
                    .opacity(0.03)
                    .allowsHitTesting(false)
                
                MangaBackdrop()
                    .opacity(0.3)
                    .allowsHitTesting(false)
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack(spacing: 16) {
                            MangaStatCard(
                                topLabel: "日",
                                mainValue: "\(progress.currentStreak)",
                                bottomLabel: "STREAK",
                                color: .orange,
                                gradient: [Color.orange, Color.red]
                            )
                            
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
                        
                        HStack(spacing: 16) {
                            MangaStatBox(
                                value: "\(progress.totalCardsReviewed)",
                                label: "GELERNT",
                                color: .blue
                            )
                            
                            MangaStatBox(
                                value: "\(flashcards.count)",
                                label: "KARTEN",
                                color: .purple
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
                    }
                }
                .overlay(alignment: .topTrailing) {
                    ChibiMascot(
                        level: currentLevel,
                        streak: progress.currentStreak,
                        goalComplete: cardsCompletedToday >= progress.dailyGoal
                    )
                    .frame(width: 80, height: 80)
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                    .allowsHitTesting(false)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("DASHBOARD")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddCard = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.white)
                        }
                        .shadow(color: .blue.opacity(0.5), radius: 8, y: 4)
                    }
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
            .sheet(isPresented: $showAddCard) {
                AddCardView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
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
                // Geometric manga panels for depth
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
                
                // MANGA CHARACTER PNG IMAGES
                
                // Hero action character - Left side
                Image("hero_action_blue")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .opacity(0.8)
                    .position(x: 90, y: geometry.size.height * 0.5)
                
                // Ninja character - Right side
                Image("ninja_side_purple")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .opacity(0.8)
                    .position(x: geometry.size.width - 80, y: geometry.size.height * 0.6)
                
                // Fox mascot - Bottom left
                Image("fox_mascot_orange")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .opacity(0.8)
                    .position(x: 100, y: geometry.size.height - 100)
                
                // Victory power character - Top right
                Image("victory_power_red")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .opacity(0.8)
                    .position(x: geometry.size.width - 70, y: 180)
            }
        }
    }
}

struct ChibiMascot: View {
    let level: Int
    let streak: Int
    let goalComplete: Bool
    
    var expression: String {
        if goalComplete {
            return "😎"
        } else if streak >= 7 {
            return "🔥"
        } else if streak >= 3 {
            return "😊"
        } else {
            return "💪"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
            
            VStack(spacing: 2) {
                Text(expression)
                    .font(.system(size: 32))
                
                Text("Lv\(level)")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            
            if level >= 5 {
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .scaleEffect(1.1)
                    .opacity(0.6)
            }
        }
        .shadow(color: .blue.opacity(0.5), radius: 10)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Flashcard.self, Deck.self, UserProgress.self, ReviewSession.self])
}

//
//  ContentView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import SwiftUI
import SwiftData
import UIKit

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
    @State private var selectedLanguage: String = "en" // Default to English
    
    // Get the active deck based on selected language
    var activeDeck: Deck? {
        decks.first { $0.targetLanguage == selectedLanguage }
    }
    
    // Get flashcards for the selected language
    var activeFlashcards: [Flashcard] {
        guard let deck = activeDeck else { return [] }
        return flashcards.filter { $0.deckId == deck.id }
    }
    
    var progress: UserProgress {
        userProgress.first ?? {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            return newProgress
        }()
    }
    
    var body: some View {
        NavigationStack {
            dashboardContent
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $showReviewSession, onDismiss: handleReviewSessionDismiss) {
                    if let deck = activeDeck {
                        ReviewSessionView(selectedDeck: deck)
                    }
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
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
                addButtonContent
            }
        }
    }
    
    private var addButtonContent: some View {
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
    
    private var dashboardContent: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Add the dashboard background red image
            Image("dashboard_background_red")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .opacity(0.4)
            
            MangaBackdrop()
                .opacity(0.8)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // Main content
            ScrollView {
                dashboardScrollContent
            }
            
            // Mascot overlay
            VStack {
                HStack {
                    Spacer()
                    mascotOverlay
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                }
                Spacer()
            }
            .allowsHitTesting(false)
        }
    }
    
    private var backgroundLayers: some View {
        ZStack {
            Color.black
            
            HalftonePattern()
                .opacity(0.03)
            
            MangaBackdrop()
                .opacity(0.3)
        }
        .ignoresSafeArea()
    }
    
    private var dashboardScrollContent: some View {
        VStack(spacing: 24) {
            statsCards
            
            levelProgressCard
            
            DailyGoalCard(
                cardsCompletedToday: cardsCompletedToday,
                dailyGoal: progress.dailyGoal
            )
            .padding(.horizontal)
            
            // LERNEN STARTEN button - moved up here for immediate visibility
            StartLearningButton(
                activeFlashcards: activeFlashcards,
                selectedLanguage: selectedLanguage,
                cardsCompletedToday: cardsCompletedToday,
                dailyGoal: progress.dailyGoal,
                onStart: handleStartLearning
            )
            .padding(.horizontal, 24)
            
            statBoxes
            
            LanguageSelectorView(
                selectedLanguage: $selectedLanguage,
                decks: decks,
                flashcards: flashcards
            )
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 40)
        }
    }
    
    private var statsCards: some View {
        HStack(spacing: 16) {
            MangaStatCard(
                topLabel: "🔥",
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
    }
    
    private var levelProgressCard: some View {
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
            
            LevelProgressBar(xpProgress: xpProgress)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    private var statBoxes: some View {
        HStack(spacing: 16) {
            MangaStatBox(
                value: "\(progress.totalCardsReviewed)",
                label: "GELERNT",
                color: .blue
            )
            
            MangaStatBox(
                value: "\(activeFlashcards.count)",
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
    }
    
    private var mascotOverlay: some View {
        ChibiMascot(
            level: currentLevel,
            streak: progress.currentStreak,
            goalComplete: cardsCompletedToday >= progress.dailyGoal
        )
        .frame(width: 80, height: 80)
        .allowsHitTesting(false)
    }
    
    private func handleStartLearning() {
        if activeFlashcards.isEmpty {
            showAddCard = true
        } else {
            showReviewSession = true
        }
    }
    
    private func handleReviewSessionDismiss() {
        let previousCount = cardsCompletedToday
        updateCardsCompletedToday()
        
        if previousCount < progress.dailyGoal && cardsCompletedToday >= progress.dailyGoal {
            showCelebration = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCelebration = false
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
        let needed = max(1, nextLevelXP - currentLevelXP) // Ensure never 0
        
        return (
            current: max(0, currentXP - currentLevelXP),
            needed: needed
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

// MARK: - Level Progress Bar Component
struct LevelProgressBar: View {
    let xpProgress: (current: Int, needed: Int)
    
    private var progressRatio: Double {
        guard xpProgress.needed > 0 else { return 0 }
        let current = Double(xpProgress.current)
        let needed = Double(xpProgress.needed)
        
        // Extra safety: ensure both values are valid
        guard current.isFinite, needed.isFinite, needed > 0 else { return 0 }
        
        let ratio = current / needed
        // Ensure ratio is finite and within bounds
        guard ratio.isFinite, ratio >= 0 else { return 0 }
        return min(1, ratio)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                
                // Only render progress bar if ALL values are safe
                if geometry.size.width > 1, 
                   geometry.size.width.isFinite,
                   progressRatio > 0,
                   progressRatio <= 1,
                   progressRatio.isFinite {
                    let width = min(geometry.size.width * progressRatio, geometry.size.width)
                    if width > 0 && width < .infinity {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: width)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                }
            }
        }
        .frame(height: 20)
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
        ZStack {
            // Geometric manga panels with red theme - EVEN BIGGER and BOLDER
            GeometryReader { geometry in
                ZStack {
                    // LEFT PANEL - Much larger and brighter
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.5, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.35, y: geometry.size.height * 0.5))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.tsukiRed.opacity(0.6), Color.tsukiOrange.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // RIGHT PANEL - Much larger and brighter
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.5, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.65, y: geometry.size.height * 0.5))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.tsukiOrange.opacity(0.6), Color.tsukiRed.opacity(0.5)],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    
                    // CENTER ACCENT - Vertical stripe
                    Rectangle()
                        .fill(Color.tsukiRed.opacity(0.15))
                        .frame(width: 3)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    // SPEED LINES - Manga action effect (more visible)
                    ForEach(0..<12) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 3)
                            .rotationEffect(.degrees(-20))
                            .offset(x: CGFloat(i) * 60 - 200)
                    }
                }
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

// MARK: - Daily Goal Card Component
struct DailyGoalCard: View {
    let cardsCompletedToday: Int
    let dailyGoal: Int
    
    private var isComplete: Bool { 
        dailyGoal > 0 && cardsCompletedToday >= dailyGoal 
    }
    private var progressRatio: Double {
        guard dailyGoal > 0 else { return 0 }
        let completed = Double(cardsCompletedToday)
        let goal = Double(dailyGoal)
        
        // Extra safety: ensure both values are valid
        guard completed.isFinite, goal.isFinite, goal > 0 else { return 0 }
        
        let ratio = completed / goal
        // Ensure ratio is finite and within bounds
        guard ratio.isFinite, ratio >= 0 else { return 0 }
        return min(1.0, ratio)
    }
    
    var body: some View {
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
                
                if isComplete {
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
                
                Text("\(dailyGoal)")
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
                    
                    // Only render progress bar if ALL values are safe
                    if geometry.size.width > 1,
                       geometry.size.width.isFinite,
                       progressRatio > 0,
                       progressRatio <= 1,
                       progressRatio.isFinite {
                        let width = min(geometry.size.width * progressRatio, geometry.size.width)
                        if width > 0 && width < .infinity {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(progressGradient)
                                .frame(width: width)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                    }
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
    }
    
    private var progressGradient: LinearGradient {
        if isComplete {
            return LinearGradient(
                colors: [Color.green, Color.green.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - Start Learning Button Component
struct StartLearningButton: View {
    let activeFlashcards: [Flashcard]
    let selectedLanguage: String
    let cardsCompletedToday: Int
    let dailyGoal: Int
    let onStart: () -> Void
    
    private var hasCards: Bool { !activeFlashcards.isEmpty }
    private var buttonTitle: String { cardsCompletedToday >= dailyGoal ? "WEITER ÜBEN" : "LERNEN STARTEN" }
    private var flag: String { selectedLanguage == "es" ? "🇪🇸" : "🇬🇧" }
    private var cardCountText: String { "\(min(activeFlashcards.count, dailyGoal)) KARTEN" }
    
    var body: some View {
        Button(action: onStart) {
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text("開始")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(flag)
                        .font(.system(size: 20))
                }
                
                Text(buttonTitle)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                
                if hasCards {
                    Text(cardCountText)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("KEINE KARTEN - TIPPE ZUM HINZUFÜGEN")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(buttonBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black, lineWidth: 3)
            )
            .shadow(color: hasCards ? .blue.opacity(0.5) : .clear, radius: 12, y: 6)
        }
    }
    
    private var buttonBackground: some View {
        Group {
            if hasCards {
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [.gray, .gray.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}

// MARK: - Language Selector Component
struct LanguageSelectorView: View {
    @Binding var selectedLanguage: String
    let decks: [Deck]
    let flashcards: [Flashcard]
    
    private func cardCount(for language: String) -> Int {
        guard let deck = decks.first(where: { $0.targetLanguage == language }) else { return 0 }
        return flashcards.filter { $0.deckId == deck.id }.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("LERNSPRACHE")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.orange)
            
            HStack(spacing: 12) {
                LanguageButton(
                    flag: "🇬🇧",
                    name: "English",
                    language: "en",
                    cardCount: cardCount(for: "en"),
                    isSelected: selectedLanguage == "en",
                    color: .green
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLanguage = "en"
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                LanguageButton(
                    flag: "🇪🇸",
                    name: "Español",
                    language: "es",
                    cardCount: cardCount(for: "es"),
                    isSelected: selectedLanguage == "es",
                    color: .orange
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLanguage = "es"
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
    }
}

struct LanguageButton: View {
    let flag: String
    let name: String
    let language: String
    let cardCount: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(flag)
                    .font(.system(size: 40))
                Text(name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                Text("\(cardCount)")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isSelected
                ? LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                : LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.05)], startPoint: .top, endPoint: .bottom)
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: isSelected ? 3 : 2)
            )
            .shadow(color: isSelected ? color.opacity(0.5) : .clear, radius: 8)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Flashcard.self, Deck.self, UserProgress.self, ReviewSession.self, Achievement.self])
}

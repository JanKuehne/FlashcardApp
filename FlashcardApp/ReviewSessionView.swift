//
//  ReviewSessionView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import SwiftUI
import SwiftData
import UIKit

struct ReviewSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var decks: [Deck]
    @Query private var userProgress: [UserProgress]
    
    let selectedDeck: Deck  // Pass in the deck to review
    
    @State private var cards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var sessionComplete = false
    @State private var correctCount = 0
    @State private var showImpact = false
    @State private var soundEffect: SoundEffectType? = nil
    
    // Get user's name for personalized messages
    private var userName: String {
        AppSettings.shared.userName
    }
    
    // Get success message based on deck language
    private var successMessage: String {
        AppSettings.shared.successMessage(for: selectedDeck.targetLanguage, userName: userName)
    }
    
    var dailyGoal: Int {
        userProgress.first?.dailyGoal ?? 100
    }
    
    var cardsPerSession: Int {
        userProgress.first?.cardsPerSession ?? 20
    }
    
    var reviewMode: String {
        userProgress.first?.reviewMode ?? "newest"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if sessionComplete {
                sessionSummaryView
            } else if currentIndex < cards.count {
                reviewCardView
            } else {
                loadingView
            }
            
            if let effect = soundEffect {
                SoundEffectText(type: effect)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .task {
            loadReviewCards()
        }
    }
    
    var reviewCardView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Text("✕")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Show language flag
                Text(selectedDeck.languageFlag)
                    .font(.system(size: 32))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(currentIndex + 1)/\(cards.count)")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("\(correctCount) 正解")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(currentIndex) / Double(cards.count)), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)
            
            Spacer()
            
            let card = cards[currentIndex]
            
            // Learning status badge
            if card.cardState == "learning" {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.caption)
                        Text("LERNEN")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.black)
                        if card.learningStep > 0 {
                            Text("(\(card.learningStep + 1)/3)")
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            }
            
            ZStack {
                if isFlipped {
                    MangaSpeedLines()
                        .opacity(0.4)
                }
                
                if showImpact {
                    ImpactStarsView()
                }
                
                ZStack {
                    MangaCardFace(
                        text: card.back,
                        subtitle: card.exampleSentence,
                        isAnswer: true,
                        language: selectedDeck.targetLanguage == "es" ? "es-ES" : "en-US"
                    )
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    
                    MangaCardFace(
                        text: card.front,
                        subtitle: "タップ!",
                        isAnswer: false,
                        language: "de-DE"
                    )
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: 450)
                .padding(.horizontal, 24)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    soundEffect = .swoosh
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        soundEffect = nil
                    }
                }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isFlipped.toggle()
                }
                
                // Auto-play back side when flipped
                if isFlipped {
                    autoPlayIfNeeded(front: false)
                }
            }
            
            Spacer()
            
            if isFlipped {
                VStack(spacing: 12) {
                    Text("どう？")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                    
                    HStack(spacing: 12) {
                        MangaGradeButton(
                            title: "FALSCH",
                            symbol: "✕",
                            color: .red
                        ) {
                            gradeCard(grade: .wrong)
                        }
                        
                        MangaGradeButton(
                            title: "SCHWER",
                            symbol: "～",
                            color: .orange
                        ) {
                            gradeCard(grade: .hard)
                        }
                        
                        MangaGradeButton(
                            title: "LEICHT",
                            symbol: "✓",
                            color: .green
                        ) {
                            gradeCard(grade: .easy)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    var sessionSummaryView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    StarburstEffect()
                    
                    VStack(spacing: 8) {
                        Text("完了!")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 10)
                        
                        ZStack {
                            Text("SUCCESS!")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: 4, y: 4)
                            
                            Text("SUCCESS!")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .yellow],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        
                        // Language-specific success message
                        Text(successMessage)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .blue, radius: 8)
                    }
                }
                .frame(height: 200)
                
                VStack(spacing: 20) {
                    MangaStatRow(
                        label: "KARTEN",
                        value: "\(cards.count)",
                        color: .blue
                    )
                    
                    MangaStatRow(
                        label: "RICHTIG",
                        value: "\(correctCount)",
                        color: .green
                    )
                    
                    MangaStatRow(
                        label: "SCORE",
                        value: "\(Int(Double(correctCount) / Double(cards.count) * 100))%",
                        color: .purple
                    )
                }
                .padding(24)
                .background(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 4)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 12) {
                    MangaActionButton(
                        title: "もう一度",
                        subtitle: "NOCHMAL ÜBEN",
                        color: .green
                    ) {
                        currentIndex = 0
                        correctCount = 0
                        sessionComplete = false
                        isFlipped = false
                        showImpact = false
                        loadReviewCards()
                    }
                    
                    MangaActionButton(
                        title: "終了",
                        subtitle: "FERTIG",
                        color: .blue
                    ) {
                        dismiss()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
        }
    }
    
    var loadingView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("読み込み中...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
    
    func loadReviewCards() {
        let descriptor = FetchDescriptor<Flashcard>(
            sortBy: [SortDescriptor(\.createdDate)]
        )
        
        if let fetchedCards = try? modelContext.fetch(descriptor) {
            // Filter cards for this deck
            let deckCards = fetchedCards.filter { $0.deckId == selectedDeck.id }
            
            // LEARNING QUEUE SYSTEM
            // Priority 1: Cards in learning (need multiple exposures today)
            // Priority 2: Due cards (graduated cards ready for review)
            // Priority 3: New cards (start learning if session not full)
            
            var selectedCards: [Flashcard] = []
            let sessionSize = cardsPerSession  // Use cards per session, not daily goal
            
            // 1. Get learning cards (highest priority - must finish learning)
            let learningCards = deckCards
                .filter { $0.cardState == "learning" && $0.nextReviewDate <= Date() }
                .sorted { $0.createdDate > $1.createdDate }  // Newest first
            
            selectedCards.append(contentsOf: learningCards.prefix(sessionSize))
            print("📚 Learning cards: \(learningCards.count)")
            
            // 2. If not full, add due cards (graduated, ready for review)
            if selectedCards.count < sessionSize {
                let dueCards = deckCards
                    .filter { 
                        $0.cardState == "graduated" && 
                        $0.nextReviewDate <= Date() 
                    }
                    .sorted { $0.nextReviewDate < $1.nextReviewDate }  // Oldest due first
                
                let needed = sessionSize - selectedCards.count
                selectedCards.append(contentsOf: dueCards.prefix(needed))
                print("🔄 Due cards: \(dueCards.count)")
            }
            
            // 3. If still not full, add new cards (never reviewed)
            if selectedCards.count < sessionSize {
                let allNewCards = deckCards
                    .filter { $0.timesReviewed == 0 && $0.cardState == "learning" }
                
                // Sort based on reviewMode setting
                let newCards: [Flashcard]
                if reviewMode == "newest" {
                    // NEUESTE: Focus on newest cards (Anki-style)
                    newCards = allNewCards.sorted { $0.createdDate > $1.createdDate }
                    print("✨ Mode: NEUESTE - Newest cards first")
                } else {
                    // ALLE: Mix all cards evenly (shuffle or oldest first)
                    newCards = allNewCards.sorted { $0.createdDate < $1.createdDate }
                    print("📚 Mode: ALLE - All cards mixed")
                }
                
                let needed = sessionSize - selectedCards.count
                selectedCards.append(contentsOf: newCards.prefix(needed))
                print("✨ New cards added: \(min(needed, newCards.count))")
            }
            
            cards = selectedCards
            print("📊 Session: \(cards.count) cards total (Mode: \(reviewMode))")
        }
        
        // Auto-play first card if enabled
        if !cards.isEmpty {
            autoPlayIfNeeded(front: true)
        }
    }
    
    /// Auto-play audio based on settings
    func autoPlayIfNeeded(front: Bool) {
        guard currentIndex < cards.count else { return }
        
        let mode = AudioService.shared.autoPlayMode
        let shouldPlay = (front && (mode == .frontOnly || mode == .bothSides)) ||
                         (!front && (mode == .backOnly || mode == .bothSides))
        
        guard shouldPlay else { return }
        
        let delay = AudioService.shared.autoPlayDelay
        let card = cards[currentIndex]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if front {
                AudioService.shared.speakGerman(card.front)
            } else {
                let languageCode = self.selectedDeck.targetLanguage == "es" ? "es-ES" : "en-US"
                AudioService.shared.speak(card.back, language: languageCode)
            }
        }
    }
    
    func gradeCard(grade: ReviewGrade) {
        let card = cards[currentIndex]
        
        if grade == .wrong {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                soundEffect = .oops
            }
        } else if grade == .easy {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            showImpact = true
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                soundEffect = .correct
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showImpact = false
            }
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                soundEffect = .good
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                soundEffect = nil
            }
        }
        
        card.timesReviewed += 1
        card.lastReviewedDate = Date()
        
        if grade != .wrong {
            correctCount += 1
            card.timesCorrect += 1
        }
        
        updateCardWithSM2(card: card, grade: grade)
        try? modelContext.save()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if currentIndex < cards.count - 1 {
                currentIndex += 1
                isFlipped = false
                
                // Auto-play next card (front side)
                autoPlayIfNeeded(front: true)
            } else {
                sessionComplete = true
                saveSessionAndUpdateProgress()
            }
        }
    }
    
    func updateCardWithSM2(card: Flashcard, grade: ReviewGrade) {
        // LEARNING QUEUE SYSTEM (Anki-style)
        // New cards stay in "learning" until mastered
        // Graduated cards use normal SM-2
        
        if card.cardState == "learning" {
            // ============================================
            // LEARNING PHASE: New cards need multiple exposures
            // ============================================
            
            switch grade {
            case .easy:
                // Mastered immediately! Graduate to reviews
                card.cardState = "graduated"
                card.repetitions = 1
                card.interval = 1  // Show tomorrow
                if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                    card.nextReviewDate = tomorrow
                }
                print("🎓 Card graduated after first attempt!")
                
            case .hard:
                // Making progress, but needs more practice
                card.learningStep += 1
                
                if card.learningStep >= 2 {
                    // Seen 2+ times with "hard" - graduate anyway
                    card.cardState = "graduated"
                    card.repetitions = 1
                    card.interval = 1
                    if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                        card.nextReviewDate = tomorrow
                    }
                    print("🎓 Card graduated after \(card.learningStep) learning attempts")
                } else {
                    // Show again later in this session
                    card.nextReviewDate = Date()
                    print("📚 Card stays in learning, step \(card.learningStep)")
                }
                
            case .wrong:
                // Reset learning progress
                card.learningStep = 0
                card.nextReviewDate = Date()  // Show again soon
                card.easinessFactor = max(1.3, card.easinessFactor - 0.2)
                print("❌ Card reset in learning phase")
            }
            
        } else {
            // ============================================
            // GRADUATED PHASE: Normal SM-2 Algorithm
            // ============================================
            
            if grade == .wrong {
                // Failed review - back to learning!
                card.cardState = "learning"
                card.learningStep = 0
                card.repetitions = 0
                card.interval = 0
                card.nextReviewDate = Date()
                card.easinessFactor = max(1.3, card.easinessFactor - 0.2)
                print("⚠️ Card demoted back to learning")
            } else {
                // Correct - continue SM-2
                card.repetitions += 1
                
                if card.repetitions == 1 {
                    card.interval = 1
                } else if card.repetitions == 2 {
                    card.interval = 6
                } else {
                    card.interval = Int(Double(card.interval) * card.easinessFactor)
                }
                
                if grade == .hard {
                    card.easinessFactor = max(1.3, card.easinessFactor - 0.15)
                } else if grade == .easy {
                    card.easinessFactor = min(2.5, card.easinessFactor + 0.1)
                }
                
                if let nextDate = Calendar.current.date(byAdding: .day, value: card.interval, to: Date()) {
                    card.nextReviewDate = nextDate
                }
                
                print("✅ Card reviewed, next in \(card.interval) days")
            }
        }
    }
    
    func saveSessionAndUpdateProgress() {
        guard let deck = decks.first else { return }
        
        let session = ReviewSession(deckId: deck.id)
        session.cardsReviewed = cards.count
        session.correctAnswers = correctCount
        session.endDate = Date()
        
        modelContext.insert(session)
        
        if let progress = try? modelContext.fetch(FetchDescriptor<UserProgress>()).first {
            progress.totalCardsReviewed += cards.count
            progress.totalCorrectAnswers += correctCount
            
            let xpEarned = correctCount * 10
            progress.totalXP += xpEarned
            session.xpEarned = xpEarned
            
            if cards.count >= progress.dailyGoal {
                updateStreak(progress: progress)
            }
        }
        
        try? modelContext.save()
    }
    
    func updateStreak(progress: UserProgress) {
        let today = Calendar.current.startOfDay(for: Date())
        
        guard let lastCompletion = progress.lastCompletionDate else {
            progress.currentStreak = 1
            progress.longestStreak = 1
            progress.lastCompletionDate = today
            return
        }
        
        let lastCompletionDay = Calendar.current.startOfDay(for: lastCompletion)
        let daysSinceCompletion = Calendar.current.dateComponents(
            [.day],
            from: lastCompletionDay,
            to: today
        ).day ?? 0
        
        if daysSinceCompletion == 0 {
            return
        } else if daysSinceCompletion == 1 {
            progress.currentStreak += 1
            progress.longestStreak = max(progress.longestStreak, progress.currentStreak)
        } else {
            progress.currentStreak = 1
        }
        
        progress.lastCompletionDate = today
    }
}

struct MangaCardFace: View {
    let text: String
    let subtitle: String?
    let isAnswer: Bool
    let language: String  // NEW: Language code for audio
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isAnswer ? Color.green.opacity(0.95) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 6)
                )
                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
            
            VStack(spacing: 16) {
                Spacer()
                
                Text(text)
                    .font(.system(size: isAnswer ? 42 : 52, weight: .black, design: .rounded))
                    .foregroundColor(isAnswer ? .white : .black)
                    .multilineTextAlignment(.center)
                    .shadow(color: isAnswer ? .black.opacity(0.3) : .clear, radius: 2)
                    .textCase(.uppercase)
                
                // Audio button
                AudioButton(
                    text: text,
                    language: language,
                    size: 50,
                    iconSize: 22
                )
                .padding(.top, 8)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(isAnswer ? .white.opacity(0.9) : .gray)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(30)
        }
    }
}

struct MangaGradeButton: View {
    let title: String
    let symbol: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Text(symbol)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .offset(x: 3, y: 3)
                    
                    Text(symbol)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(color)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(MangaButtonStyle())
    }
}

struct MangaSpeedLines: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<12) { i in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 4, height: geometry.size.height * 1.2)
                        .offset(x: CGFloat(i) * 40 - 200, y: -50)
                        .rotationEffect(.degrees(-20))
                }
            }
        }
    }
}

struct ImpactStarsView: View {
    var body: some View {
        ZStack {
            ForEach(0..<8) { i in
                Text("★")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                    .offset(
                        x: cos(Double(i) * .pi / 4) * 100,
                        y: sin(Double(i) * .pi / 4) * 100
                    )
                    .opacity(0.8)
            }
        }
    }
}

struct MangaStatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(color)
                .textCase(.uppercase)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct MangaActionButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(color)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
        }
        .buttonStyle(MangaButtonStyle())
    }
}

struct StarburstEffect: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<16) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.8),
                                Color.orange.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 150, height: 8)
                    .offset(x: 75)
                    .rotationEffect(.degrees(Double(i) * 22.5))
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            }
            
            Circle()
                .stroke(Color.yellow, lineWidth: 6)
                .frame(width: 100, height: 100)
                .scaleEffect(isAnimating ? 1.5 : 0.5)
                .opacity(isAnimating ? 0 : 1)
            
            Circle()
                .stroke(Color.orange, lineWidth: 4)
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1.3 : 0.7)
                .opacity(isAnimating ? 0 : 1)
        }
        .onAppear {
            withAnimation(
                .easeOut(duration: 1.5)
            ) {
                isAnimating = true
            }
        }
    }
}

enum SoundEffectType {
    case swoosh
    case correct
    case good
    case oops
    
    var text: String {
        switch self {
        case .swoosh: return "SWOOSH!"
        case .correct: return "CORRECT!"
        case .good: return "GOOD!"
        case .oops: return "OOPS!"
        }
    }
    
    var color: Color {
        switch self {
        case .swoosh: return .blue
        case .correct: return .green
        case .good: return .orange
        case .oops: return .red
        }
    }
}

struct SoundEffectText: View {
    let type: SoundEffectType
    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = -10
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Multiple shadow layers for glow effect
            Text(type.text)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(type.color)
                .blur(radius: 20)
                .opacity(0.8)
            
            Text(type.text)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(type.color)
                .blur(radius: 10)
                .opacity(0.6)
            
            // Black outline/shadow (thicker)
            Text(type.text)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .offset(x: 6, y: 6)
            
            // White stroke
            Text(type.text)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 3)
            
            // Main colored text
            Text(type.text)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [type.color, type.color.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.2
                rotation = 10
            }
            
            // Fade out animation
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                opacity = 0
            }
        }
    }
}

enum ReviewGrade {
    case wrong
    case hard
    case easy
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Flashcard.self, Deck.self, configurations: config)
    let context = container.mainContext
    
    // Create a sample deck for preview
    let deck = Deck(name: "English", description: "Demo Deck", targetLanguage: "en")
    context.insert(deck)
    
    return ReviewSessionView(selectedDeck: deck)
        .modelContainer(container)
}

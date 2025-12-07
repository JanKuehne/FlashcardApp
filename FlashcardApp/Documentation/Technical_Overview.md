# Technical Architecture

## Technology Stack
- **Platform**: iOS 17+, iPhone only
- **Framework**: SwiftUI + SwiftData
- **Language**: Swift 5.9+
- **Persistence**: SwiftData (local, no cloud sync)
- **Dependencies**: None (zero external packages)

## Data Models

### Flashcard
```swift
@Model class Flashcard {
    var id: UUID
    var deckId: UUID
    var front: String        // German word
    var back: String         // English translation
    var exampleSentence: String?
    
    // SM-2 Spaced Repetition
    var easinessFactor: Double  // 1.3-2.5
    var repetitions: Int
    var interval: Int           // days until next review
    var nextReviewDate: Date
    
    // Progress tracking
    var timesReviewed: Int
    var timesCorrect: Int
    var lastReviewedDate: Date?
    var createdDate: Date
}
```

### Deck
```swift
@Model class Deck {
    var id: UUID
    var name: String
    var language: String      // "German" (expandable)
    var createdDate: Date
}
```

### UserProgress
```swift
@Model class UserProgress {
    var id: UUID
    var totalXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var dailyGoal: Int        // default: 20 cards
    var totalCardsReviewed: Int
    var totalCorrectAnswers: Int
    var lastCompletionDate: Date?
}
```

### ReviewSession
```swift
@Model class ReviewSession {
    var id: UUID
    var deckId: UUID
    var startDate: Date
    var endDate: Date?
    var cardsReviewed: Int
    var correctAnswers: Int
    var xpEarned: Int
}
```

## App Architecture

### View Hierarchy
```
ContentView (Dashboard)
├── Stats Overview (Streak, Level, XP)
├── Daily Goal Progress
├── Action Button → ReviewSessionView
└── Background (Manga elements)

ReviewSessionView (Study Session)
├── Card Display (flip animation)
├── Progress Bar
├── Grade Buttons (Wrong/Hard/Easy)
├── Sound Effect Overlays
└── Session Summary
```

## Key Algorithms

### SM-2 Spaced Repetition
- **Wrong**: repetitions=0, interval=0, easiness-0.2
- **Hard**: easiness-0.15
- **Easy**: easiness+0.1
- Intervals: 1 day → 6 days → interval * easiness

### XP & Leveling
- **XP per correct card**: 10 XP
- **Level formula**: level² × 100 XP
  - Level 1→2: 100 XP
  - Level 2→3: 400 XP  
  - Level 3→4: 900 XP

### Streak Calculation
- Resets if 24+ hours since last completion
- Increments only when daily goal reached
- Persists across app restarts

## Design Patterns
- **MVVM-style**: Views observe SwiftData models
- **Single source of truth**: SwiftData @Query
- **Composition**: Reusable manga-style components
- **Animation layering**: Multiple visual effects combined

# CLAUDE.md - AI Assistant Guide for Bredenbook

**Last Updated**: December 28, 2024  
**App Name**: Bredenbook (formerly FlashcardApp)  
**Current Version**: 1.0 (In Development)

---

## 📋 Quick Reference

### Essential Files to Read First
1. **PROJECT_OVERVIEW.md** - Vision, goals, target users
2. **TASKS.md** - Current priorities and backlog
3. **DEVELOPMENT_ROADMAP.md** - What's done, what's next
4. **DESIGN_SYSTEM.md** - Manga styling rules
5. This file (CLAUDE.md) - Working guidelines

### Project Context
- **Target Users**: Twin boys aged 8-10, learning German vocabulary
- **Design Philosophy**: Authentic manga/anime aesthetic (Naruto-inspired)
- **Tech Stack**: SwiftUI, SwiftData, iOS 17+
- **Platform**: iOS only (iPhone primary, iPad future)
- **Learning Method**: Spaced repetition (SM-2 algorithm)

---

## 🎨 Design System Rules

### Manga Aesthetic Principles
**ALWAYS maintain these:**
- ✅ Black backgrounds (NOT white/gray)
- ✅ Thick black borders (3-5px) on all cards/buttons
- ✅ Bold text with heavy weights (.black, .bold)
- ✅ Japanese text accents (学習, 完了, 開始, etc.)
- ✅ Vibrant gradient colors (blue→purple, red→orange)
- ✅ Dramatic animations (scale, rotation, fade)
- ✅ High contrast for readability

### Color Palette
```swift
// Primary Colors (defined in Color+Extensions.swift)
Color.tsukiRed = Color(red: 0.9, green: 0.2, blue: 0.3)
Color.tsukiOrange = Color(red: 1.0, green: 0.5, blue: 0.2)

// Common Gradients
LinearGradient(colors: [.blue, .purple], ...)  // Primary actions
LinearGradient(colors: [.tsukiRed, .tsukiOrange], ...) // Backgrounds
LinearGradient(colors: [.green, .green.opacity(0.7)], ...) // Success
```

### Typography Rules
```swift
// Headings
.font(.system(size: 32-48, weight: .black, design: .rounded))

// Body Text
.font(.system(.body, design: .rounded)).fontWeight(.semibold)

// Japanese Accent Text
.font(.system(.caption, design: .rounded)).foregroundColor(.orange)
```

### Animation Standards
```swift
// Button Press
.spring(response: 0.3, dampingFraction: 0.6)

// Card Flip
.animation(.spring(response: 0.5, dampingFraction: 0.7))

// Success Effects
.easeOut(duration: 0.6)
```

---

## 🏗️ Architecture Overview

### SwiftData Models
```
Flashcard: Core vocabulary card
├── front: String (German word)
├── back: String (English translation)
├── exampleSentence: String?
├── easinessFactor: Double (SM-2)
├── nextReviewDate: Date
└── deckId: UUID

Deck: Card collection
├── name: String
├── targetLanguage: String ("en", "es")
└── id: UUID

UserProgress: Gamification state
├── totalXP: Int
├── currentStreak: Int
├── dailyGoal: Int
└── totalCardsReviewed: Int

ReviewSession: Session tracking
├── cardsReviewed: Int
├── correctAnswers: Int
└── startDate: Date

Achievement: Badge system
├── name: String
├── isUnlocked: Bool
└── requirement: Int
```

### Key Views
```
FlashcardAppApp.swift → Entry point
├── SplashScreenView → Launch screen (2.5s)
│   └── Shows twin_start image + random Monty Python phrase
└── ContentView → Main dashboard
    ├── Stats cards (streak, level, XP)
    ├── Daily goal progress
    ├── LERNEN STARTEN button
    ├── Language selector (EN/ES)
    └── MangaBackdrop (diagonal red/orange panels)

ReviewSessionView → Learning session
├── Card flip animations
├── Grade buttons (FALSCH/SCHWER/LEICHT)
├── Progress tracking
└── Success screen (starburst effect)

AddCardView → Manual card entry
├── German word field
├── English translation field
├── AI magic wand button (LLM auto-complete)
└── Language selector (EN/ES)

SettingsView → Configuration
├── Daily goal slider
├── API key input (OpenAI)
├── Mock mode toggle
└── Statistics display
```

---

## 🔧 Important Components

### Custom Components (DO NOT BREAK)
```swift
// MangaComponents.swift
- MangaButtonStyle: Press animation
- HalftonePattern: Background dots (currently subtle)

// ContentView.swift
- MangaBackdrop: Diagonal red/orange geometric panels
- MangaStatCard: Streak/Level display
- StartLearningButton: Main CTA button
- DailyGoalCard: Progress visualization

// ReviewSessionView.swift
- SoundEffectText: "SWOOSH!", "CORRECT!" animations
- StarburstEffect: Success celebration
- MangaGradeButton: FALSCH/SCHWER/LEICHT buttons
```

### Services
```swift
// LLMService.swift
- OpenAI integration for card auto-complete
- MockLLMService for free testing (10 words)
- Cost: ~$0.00004 per card

// AppSettings.swift (@Observable)
- Singleton settings manager
- API key storage (UserDefaults)
- Mock mode toggle
- Language preferences
```

---

## 📝 Coding Standards

### DO's ✅
- Use `.rounded` design for all fonts
- Add haptic feedback: `UIImpactFeedbackGenerator()`, `UINotificationFeedbackGenerator()`
- Include Japanese text for manga authenticity
- Animate all state changes
- Use `@Observable` for settings (not `ObservableObject`)
- Comment major sections with `// MARK: -`
- Test at small screen sizes (iPhone SE)

### DON'Ts ❌
- Don't use white/light backgrounds (breaks manga aesthetic)
- Don't use thin borders (<2px)
- Don't use system fonts without `.rounded` design
- Don't skip animations (makes UI feel unpolished)
- Don't remove black outlines from text
- Don't make buttons smaller than 44x44pt (accessibility)
- Don't use deprecated APIs

### Common Patterns
```swift
// Background layers (always this order)
Color.black.ignoresSafeArea()
Image("background_asset").opacity(0.3-0.4)
MangaBackdrop().opacity(0.8)

// Button structure
Button { action } label: {
    VStack {
        Text("Japanese")
        Text("ENGLISH")
    }
    .padding()
    .background(gradient)
    .cornerRadius(16)
    .overlay(RoundedRectangle(...).stroke(Color.black, lineWidth: 3))
}
.buttonStyle(MangaButtonStyle())

// Text with manga outline
ZStack {
    Text("TITLE").foregroundColor(.black).offset(x: 4, y: 4) // Shadow
    Text("TITLE").foregroundStyle(gradient) // Main
}
```

---

## 🚨 Known Issues & Quirks

### Fixed Issues
- ✅ Random halftone dots removed (looked ugly, not manga-style)
- ✅ Buttons sized appropriately for iPhone screens
- ✅ LERNEN STARTEN moved above fold (no scrolling needed)
- ✅ Duplicate file conflicts resolved (MangaComponents.swift vs individual files)

### Current Limitations
- No iPad optimization (iPhone only for now)
- English and Spanish only (more languages planned)
- Mock LLM only has 10 words (sufficient for testing)
- No iCloud sync (local only)

### Technical Debt
- Extract more components to separate files
- Add unit tests for SM-2 algorithm
- Profile animation performance
- Add accessibility labels

---

## 🎯 Current Development Phase

### Recently Completed ✅
- Splash screen with random Monty Python phrases (3 languages)
- App icon integration (bredenbook_favicon)
- Enhanced manga background with larger diagonal panels
- Button sizing fixes
- Dashboard layout optimization

### Active Work 🔄
- General polish and refinement
- Bug fixing
- Performance optimization

### Next Priorities 📋
1. **Testing with target users** (twin sons)
2. **Achievement badges UI** (AchievementsView exists but needs polish)
3. **Level-up animation** (explosion effect when reaching new level)
4. **Spanish deck expansion** (add more vocabulary)

---

## 💬 Working with This Project

### When Starting a New Session
1. Read this file (CLAUDE.md)
2. Check TASKS.md for current priorities
3. Review recent commits/changes
4. Ask user for context if unclear

### Before Making Changes
- Verify changes align with manga aesthetic
- Check if component exists before creating new one
- Consider iPhone SE size constraints
- Test animations on actual device if possible

### After Making Changes
- Update TASKS.md if task completed
- Document any new patterns in this file
- Note any breaking changes
- Suggest next logical steps

### Communication Style
- Be enthusiastic about manga aesthetic
- Explain technical decisions clearly
- Offer alternatives when appropriate
- Ask for clarification on design choices
- Reference existing documentation

---

## 🎨 Fun Easter Eggs

**Current Features:**
- Random Monty Python "hovercraft full of eels" phrase on splash (EN/DE/ES)
- Japanese kanji "学習" (learning) in splash screen
- Emoji mascot with sunglasses when daily goal complete
- Success messages in target language ("WELL DONE!" vs "¡MUY BIEN!")

**Ideas for Future:**
- Rare "ultra rare" card animations (1% chance)
- Hidden achievement for perfect week
- Special effects on level milestones (10, 25, 50)

---

## 📚 External Resources

### SwiftUI Documentation
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

### Design Inspiration
- Naruto anime aesthetic
- Duolingo gamification patterns
- Anki spaced repetition algorithm

### APIs & Services
- OpenAI GPT-4o-mini for card auto-complete
- AVSpeechSynthesizer for pronunciation (planned)

---

## 🤝 Collaboration Guidelines

### With User (Jan)
- He prefers concise, actionable feedback
- Likes manga/anime aesthetic (Naruto fan)
- Building this for his twin sons (age 8-10)
- Open to creative suggestions
- Values clean code and good UX

### With Future AI Assistants
- Read this file first
- Maintain consistency with existing patterns
- Don't break the manga aesthetic
- Update documentation when making significant changes
- Reference line numbers when suggesting code changes

---

## 🎓 Learning Points

### What Works Well
- Bold, high-contrast manga styling is engaging
- Haptic feedback makes interactions feel responsive
- Japanese text adds authenticity without being distracting
- Spaced repetition keeps users coming back
- Gamification (XP, levels, streaks) drives motivation

### What to Avoid
- Subtle effects (users won't notice them)
- Complex animations on low-end devices
- Too much text (kids lose interest)
- Generic UI patterns (breaks immersion)

---

## 📞 Quick Commands for AI Assistants

When user says:
- **"Check tasks"** → View TASKS.md
- **"What's next?"** → Check Phase 10 in DEVELOPMENT_ROADMAP.md
- **"Design rules"** → Reference DESIGN_SYSTEM.md + this file's Design System section
- **"Fix manga style"** → Apply rules from this file's Design System section
- **"Add feature X"** → Check if it aligns with PROJECT_OVERVIEW.md goals first

---

**Remember**: This is a passion project to help kids learn German while having fun. Keep it engaging, polished, and authentic to the manga aesthetic! 🎌📚✨

---

_This file should be updated whenever significant architectural changes are made or new patterns emerge._

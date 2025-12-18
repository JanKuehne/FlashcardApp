# 🏗️ Bilingual Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      FlashcardApp                           │
│                   Bilingual Edition                         │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │ English │          │ Spanish │          │  Core   │
   │  Deck   │          │  Deck   │          │  Logic  │
   │   🇬🇧    │          │   🇪🇸    │          │         │
   └─────────┘          └─────────┘          └─────────┘
        │                     │                     │
        └─────────────────────┴─────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Unified Stats   │
                    │  XP, Streak, etc │
                    └──────────────────┘
```

---

## Data Flow

### **Adding a Card**

```
User Input
    │
    ├─ Select Language (🇬🇧 or 🇪🇸)
    │       │
    │       ├─ AppSettings.lastTargetLanguage = "es"
    │       └─ UI updates dynamically
    │
    ├─ Enter German Word: "Sonne"
    │
    ├─ Enter Target Word: "sol"
    │
    ├─ Tap AI Button 🪄
    │       │
    │       ├─ LLMService.generateExample(
    │       │      germanWord: "Sonne",
    │       │      targetWord: "sol",
    │       │      targetLanguage: "es"
    │       │   )
    │       │
    │       ├─ MockLLMService checks spanishExamples dict
    │       │
    │       └─ Returns: "El sol brilla."
    │
    ├─ Save Card
    │       │
    │       ├─ Find deck with targetLanguage = "es"
    │       │       │
    │       │       ├─ Found? Use it
    │       │       └─ Not found? Create new "Español" deck
    │       │
    │       └─ Insert Flashcard(
    │              front: "Sonne",
    │              back: "sol",
    │              deckId: spanishDeck.id,
    │              exampleSentence: "El sol brilla."
    │           )
    │
    └─ Success! Card saved to Spanish deck
```

---

## Language Selection Flow

```
┌─────────────────────────────────────────────────────┐
│                  AddCardView                        │
│  ┌────────────────────────────────────────────┐    │
│  │        ZIELSPRACHE                         │    │
│  │  ┌──────────┬───────────┐                 │    │
│  │  │ 🇬🇧 EN   │  🇪🇸 ES   │   ← User taps   │    │
│  │  └──────────┴───────────┘                 │    │
│  └────────────────────────────────────────────┘    │
│                    │                               │
│                    │ onChange                      │
│                    ▼                               │
│       AppSettings.lastTargetLanguage = "es"        │
│                    │                               │
│                    ▼                               │
│         ┌──────────────────────┐                  │
│         │  UI Updates:         │                  │
│         │  - Label: 🇪🇸 ESPAÑOL │                  │
│         │  - Placeholder: sol  │                  │
│         │  - Tip: spanische    │                  │
│         └──────────────────────┘                  │
└─────────────────────────────────────────────────────┘
```

---

## Deck Structure

```
Database (SwiftData)
│
├─ Decks
│   │
│   ├─ Deck #1
│   │   ├─ name: "English"
│   │   ├─ targetLanguage: "en"
│   │   ├─ nativeLanguage: "de"
│   │   └─ languageFlag: "🇬🇧" (computed)
│   │
│   └─ Deck #2
│       ├─ name: "Español"
│       ├─ targetLanguage: "es"
│       ├─ nativeLanguage: "de"
│       └─ languageFlag: "🇪🇸" (computed)
│
└─ Flashcards
    │
    ├─ Card #1 (English)
    │   ├─ front: "Sonne"
    │   ├─ back: "sun"
    │   ├─ deckId: → Deck #1
    │   └─ exampleSentence: "The sun shines brightly."
    │
    ├─ Card #2 (Spanish)
    │   ├─ front: "Sonne"
    │   ├─ back: "sol"
    │   ├─ deckId: → Deck #2
    │   └─ exampleSentence: "El sol brilla."
    │
    └─ ... more cards
```

---

## Review Session Flow

```
Start Review
    │
    ├─ Load ReviewSessionView
    │
    ├─ loadReviewCards()
    │       │
    │       ├─ Get deck: decks.first
    │       │       │
    │       │       └─ e.g., Spanish Deck (targetLanguage = "es")
    │       │
    │       ├─ Store: reviewedDeck = deck
    │       │
    │       └─ Filter cards: card.deckId == deck.id
    │
    ├─ User reviews cards
    │       │
    │       ├─ Front: "Sonne"
    │       ├─ Tap to flip
    │       ├─ Back: "sol"
    │       ├─ Example: "El sol brilla."
    │       └─ Grade: Easy/Medium/Hard
    │
    ├─ Complete Session
    │       │
    │       └─ sessionComplete = true
    │
    └─ Show Success Screen
            │
            ├─ Get success message:
            │       AppSettings.shared.successMessage(
            │           for: reviewedDeck.targetLanguage,  // "es"
            │           userName: "Henri"
            │       )
            │
            └─ Display: "¡MUY BIEN, HENRI!"
```

---

## LLM Service Architecture

```
┌─────────────────────────────────────────────────────┐
│                  LLMService                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  generateExample(                                   │
│      germanWord: String,                            │
│      targetWord: String,                            │
│      targetLanguage: String  ← NEW!                 │
│  ) -> String?                                       │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Real Implementation:                               │
│  └─ OpenAI API                                      │
│      └─ Prompt: "Create {languageName} sentence..." │
│                                                     │
│  Mock Implementation:                               │
│  └─ MockLLMService                                  │
│      ├─ englishExamples: [String: String]          │
│      └─ spanishExamples: [String: String]          │
│                                                     │
└─────────────────────────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
┌──────────────┐                 ┌──────────────┐
│   English    │                 │   Spanish    │
│  Examples    │                 │  Examples    │
├──────────────┤                 ├──────────────┤
│ Sonne → ...  │                 │ Sonne → ...  │
│ Mond → ...   │                 │ Mond → ...   │
│ Apfel → ...  │                 │ Apfel → ...  │
│ (10 words)   │                 │ (10 words)   │
└──────────────┘                 └──────────────┘
```

---

## Success Message Logic

```
ReviewSessionView
    │
    ├─ sessionComplete = true
    │
    ├─ Compute successMessage:
    │       │
    │       ├─ Get deck: reviewedDeck
    │       │       │
    │       │       └─ e.g., targetLanguage = "es"
    │       │
    │       ├─ Get username: AppSettings.shared.userName
    │       │       │
    │       │       └─ e.g., "Henri"
    │       │
    │       └─ Call: AppSettings.shared.successMessage(
    │              for: "es",
    │              userName: "Henri"
    │          )
    │
    ├─ successMessage function:
    │       │
    │       ├─ Check language:
    │       │   ├─ "es" → "¡MUY BIEN"
    │       │   ├─ "en" → "WELL DONE"
    │       │   └─ default → "GUT GEMACHT"
    │       │
    │       ├─ Check username:
    │       │   ├─ Not empty → append ", {NAME}!"
    │       │   └─ Empty → append "!"
    │       │
    │       └─ Return: "¡MUY BIEN, HENRI!"
    │
    └─ Display in UI
```

---

## Component Relationships

```
                    ┌──────────────┐
                    │  AppSettings │
                    │              │
                    │ - userName   │
                    │ - lastLang   │
                    │ - methods    │
                    └──────┬───────┘
                           │
                           │ provides
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  AddCardView  │  │ReviewSession  │  │  LLMService   │
│               │  │     View      │  │               │
│ - language    │  │ - reviewed    │  │ - generate    │
│   picker      │  │   Deck        │  │   example     │
│ - dynamic UI  │  │ - success msg │  │ - language    │
└───────┬───────┘  └───────┬───────┘  └───────┬───────┘
        │                  │                  │
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                           │ operates on
                           │
                    ┌──────▼───────┐
                    │  SwiftData   │
                    │              │
                    │ - Decks      │
                    │ - Flashcards │
                    │ - Progress   │
                    └──────────────┘
```

---

## Stats Integration

```
┌─────────────────────────────────────────────────────┐
│                  UserProgress                       │
│                  (Global Stats)                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  totalXP: 1250          ← Combined from all langs  │
│  currentStreak: 7       ← Overall streak           │
│  totalCardsReviewed: 57 ← English + Spanish        │
│  totalCorrectAnswers: 48                           │
│                                                     │
└─────────────────────────────────────────────────────┘
                         │
                         │ aggregates
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
┌──────────────┐                 ┌──────────────┐
│ English Deck │                 │ Spanish Deck │
│              │                 │              │
│ 45 cards     │                 │ 12 cards     │
│ 85% accuracy │                 │ 70% accuracy │
└──────────────┘                 └──────────────┘
```

---

## Migration Path

```
Old Schema (v1.0):
┌──────────┐
│   Deck   │
├──────────┤
│ name     │
│ color    │
│ iconName │  ← No language info
└──────────┘

Migration (automatic):
┌──────────┐
│   Deck   │
├──────────┤
│ name     │
│ color    │
│ iconName │
│ + targetLang = "en"  ← Defaults to English
│ + nativeLang = "de"  ← Always German
└──────────┘

New Schema (v2.0):
┌──────────┐
│   Deck   │
├──────────┤
│ name     │
│ color    │
│ iconName │
│ targetLang  ← "en" or "es"
│ nativeLang  ← "de"
└──────────┘
```

---

## UI State Machine

```
AddCardView States:

Initial
    │
    ├─ targetLanguage = lastTargetLanguage
    │       │
    │       └─ e.g., "en" (English)
    │
    ├─ Display English UI
    │
    ├─ User switches to Spanish
    │       │
    │       ├─ targetLanguage = "es"
    │       ├─ Save: lastTargetLanguage = "es"
    │       ├─ Clear: targetWord = ""
    │       ├─ Clear: exampleSentence = ""
    │       └─ Update: UI labels, placeholders
    │
    ├─ User enters words
    │
    ├─ User taps AI
    │       │
    │       ├─ isLoadingAI = true
    │       ├─ Call: generateExample(..., "es")
    │       └─ isLoadingAI = false
    │
    ├─ User saves card
    │       │
    │       ├─ Find deck for "es"
    │       ├─ Create deck if needed
    │       └─ Insert card
    │
    └─ Reset or Close
```

---

## Language Resolution

```
Determine Success Message:

reviewedDeck.targetLanguage
    │
    ├─ "en" → English Path
    │       │
    │       ├─ userName.isEmpty?
    │       │   ├─ true  → "WELL DONE!"
    │       │   └─ false → "WELL DONE, {NAME}!"
    │       │
    │       └─ Return English message
    │
    ├─ "es" → Spanish Path
    │       │
    │       ├─ userName.isEmpty?
    │       │   ├─ true  → "¡MUY BIEN!"
    │       │   └─ false → "¡MUY BIEN, {NAME}!"
    │       │
    │       └─ Return Spanish message
    │
    └─ default → German Path
            │
            └─ Return "GUT GEMACHT!" or with name
```

---

## Deck Auto-Creation

```
Save Card Flow:

User saves card
    │
    ├─ Get targetLanguage (e.g., "es")
    │
    ├─ Find existing deck:
    │       decks.first { $0.targetLanguage == "es" }
    │       │
    │       ├─ Found? ✓
    │       │   └─ Use existing deck
    │       │
    │       └─ Not found? ✗
    │           └─ Create new deck:
    │               │
    │               ├─ name: "Español"
    │               ├─ description: "Deutsch → Español"
    │               ├─ targetLanguage: "es"
    │               ├─ nativeLanguage: "de"
    │               │
    │               ├─ Insert into SwiftData
    │               └─ Return new deck
    │
    └─ Insert card with deckId
```

---

## Error Handling

```
AI Generation Flow:

User taps AI button
    │
    ├─ Validate: germanWord & targetWord not empty
    │       │
    │       ├─ Invalid → Disable button
    │       └─ Valid → Continue
    │
    ├─ Show loading: isLoadingAI = true
    │
    ├─ Call: generateExample()
    │       │
    │       ├─ Success → Return example
    │       │       │
    │       │       ├─ Set: exampleSentence = result
    │       │       ├─ Haptic: success
    │       │       └─ Focus: example field
    │       │
    │       ├─ No content → Return nil
    │       │       │
    │       │       ├─ Set: aiErrorMessage = "No response"
    │       │       ├─ Haptic: error
    │       │       └─ Show: error banner
    │       │
    │       └─ Exception → Throw error
    │               │
    │               ├─ Catch in Task
    │               ├─ Set: aiErrorMessage = error.description
    │               ├─ Haptic: error
    │               └─ Show: error banner
    │
    └─ Hide loading: isLoadingAI = false
```

---

## Visual Hierarchy

```
App Structure:

FlashcardApp
    ├─ ContentView (Dashboard)
    │   ├─ Stats Display
    │   ├─ Deck List
    │   │   ├─ English Deck 🇬🇧
    │   │   └─ Spanish Deck 🇪🇸
    │   └─ Start Review Button
    │
    ├─ AddCardView
    │   ├─ Language Picker ← NEW!
    │   ├─ German Input
    │   ├─ Target Input (dynamic)
    │   ├─ AI Button 🪄
    │   ├─ Example Input (dynamic)
    │   └─ Save Buttons
    │
    ├─ ReviewSessionView
    │   ├─ Progress Bar
    │   ├─ Flashcard Display
    │   ├─ Flip Animation
    │   ├─ Grade Buttons
    │   └─ Success Screen
    │       └─ Language-specific message ← NEW!
    │
    └─ SettingsView
        ├─ Profile (username)
        ├─ Daily Goal
        ├─ AI Settings
        └─ Stats
```

---

## Key Design Principles

1. **Language Isolation**
   - Each deck = one language
   - No mixed cards
   - Clear separation

2. **Unified Stats**
   - Global XP, streak
   - All learning counts
   - Fair progression

3. **Remember Preferences**
   - Last selected language
   - Reduces cognitive load
   - Better UX

4. **Auto-Creation**
   - No manual deck setup
   - Seamless onboarding
   - Just add cards!

5. **Dynamic UI**
   - Labels change with language
   - Visual feedback
   - Clear state

6. **Backwards Compatible**
   - Existing data preserved
   - Default to English
   - No breaking changes

---

**Architecture Version:** 2.0  
**Last Updated:** December 10, 2024  
**Status:** Production Ready ✅

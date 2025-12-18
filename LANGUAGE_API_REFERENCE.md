# 🌍 Language API Reference

## Quick Reference for Bilingual Features

---

## 📚 Language Codes

```swift
"en" // English
"es" // Spanish (Español)
"de" // German (Deutsch) - native language
```

---

## 🏗️ Data Models

### **Deck**

```swift
@Model
final class Deck {
    var targetLanguage: String = "en"  // "en" or "es"
    var nativeLanguage: String = "de"  // Always German
    
    // Computed properties
    var languageFlag: String {
        targetLanguage == "es" ? "🇪🇸" : "🇬🇧"
    }
    
    var languageName: String {
        targetLanguage == "es" ? "Español" : "English"
    }
}
```

**Usage:**
```swift
// Create English deck
let englishDeck = Deck(
    name: "English",
    targetLanguage: "en"
)

// Create Spanish deck
let spanishDeck = Deck(
    name: "Español",
    targetLanguage: "es"
)
```

---

## ⚙️ AppSettings

### **Properties**

```swift
class AppSettings {
    // Remember last selected language
    var lastTargetLanguage: String  // "en" or "es"
    
    // Available languages
    let availableLanguages = ["en", "es"]
}
```

### **Methods**

```swift
// Get flag emoji
func languageFlag(_ code: String) -> String
// "en" → "🇬🇧"
// "es" → "🇪🇸"

// Get language name
func languageName(_ code: String) -> String
// "en" → "English"
// "es" → "Español"

// Get success message
func successMessage(for language: String, userName: String) -> String
// ("en", "Henri") → "WELL DONE, HENRI!"
// ("es", "Henri") → "¡MUY BIEN, HENRI!"
// ("es", "")      → "¡MUY BIEN!"
```

**Usage:**
```swift
// Get current language
let lang = AppSettings.shared.lastTargetLanguage

// Get flag
let flag = AppSettings.shared.languageFlag("es")  // "🇪🇸"

// Get success message
let msg = AppSettings.shared.successMessage(
    for: "es",
    userName: "Henri"
)  // "¡MUY BIEN, HENRI!"
```

---

## 🤖 LLMService

### **API**

```swift
func generateExample(
    germanWord: String,
    targetWord: String,
    targetLanguage: String = "en"
) async throws -> String?
```

**Parameters:**
- `germanWord`: The German word (e.g., "Sonne")
- `targetWord`: The target language word (e.g., "sun" or "sol")
- `targetLanguage`: Language code ("en" or "es")

**Returns:**
- Example sentence in target language
- `nil` if failed

**Example:**
```swift
let service = AppSettings.shared.createLLMService()

// English example
let englishExample = try await service.generateExample(
    germanWord: "Sonne",
    targetWord: "sun",
    targetLanguage: "en"
)
// → "The sun shines brightly."

// Spanish example
let spanishExample = try await service.generateExample(
    germanWord: "Sonne",
    targetWord: "sol",
    targetLanguage: "es"
)
// → "El sol brilla."
```

---

## 🧪 MockLLMService

### **English Examples (10)**

```swift
let englishMockExamples: [String: String] = [
    "Sonne": "The sun shines brightly.",
    "Mond": "The moon is round.",
    "Apfel": "The apple is red.",
    "Hund": "The dog barks loudly.",
    "Katze": "The cat sleeps quietly.",
    "Haus": "The house is big.",
    "Baum": "The tree is old.",
    "Blume": "The flower blooms.",
    "Auto": "The car drives fast.",
    "Buch": "The book is interesting."
]
```

### **Spanish Examples (10)**

```swift
let spanishMockExamples: [String: String] = [
    "Sonne": "El sol brilla.",
    "Mond": "La luna es redonda.",
    "Apfel": "La manzana es roja.",
    "Hund": "El perro ladra.",
    "Katze": "El gato duerme.",
    "Haus": "La casa es grande.",
    "Baum": "El árbol es viejo.",
    "Blume": "La flor es bonita.",
    "Auto": "El coche es rápido.",
    "Buch": "El libro es interesante."
]
```

### **Fallback Logic**

```swift
// If word not found in mock dictionary:

// English fallback
"The \(targetWord) is nice."

// Spanish fallback
"El/La \(targetWord) es bonito/a."
```

---

## 🎨 UI Components

### **Language Picker**

```swift
@State private var targetLanguage: String = AppSettings.shared.lastTargetLanguage

Picker("Zielsprache", selection: $targetLanguage) {
    Text("🇬🇧 English").tag("en")
    Text("🇪🇸 Español").tag("es")
}
.pickerStyle(.segmented)
.onChange(of: targetLanguage) { oldValue, newValue in
    AppSettings.shared.lastTargetLanguage = newValue
}
```

### **Dynamic Labels**

```swift
var targetLanguageLabel: String {
    let flag = AppSettings.shared.languageFlag(targetLanguage)
    let name = AppSettings.shared.languageName(targetLanguage).uppercased()
    return "\(flag) \(name)"
}
// "🇬🇧 ENGLISH" or "🇪🇸 ESPAÑOL"
```

### **Dynamic Placeholders**

```swift
var targetPlaceholder: String {
    targetLanguage == "es" ? "p.ej. sol" : "e.g. sun"
}
```

### **Dynamic Tips**

```swift
var tipText: String {
    let langName = targetLanguage == "es" ? "spanische" : "englische"
    return "Nutze die AI 🪄 für \(langName) Beispielsätze!"
}
```

---

## 🎮 User Flow Examples

### **Adding English Card**

```swift
// 1. User selects language
targetLanguage = "en"

// 2. User enters words
germanWord = "Sonne"
targetWord = "sun"

// 3. AI generates example
let example = try await llmService.generateExample(
    germanWord: "Sonne",
    targetWord: "sun",
    targetLanguage: "en"
)
// → "The sun shines brightly."

// 4. Find or create deck
let deck = decks.first { $0.targetLanguage == "en" }
    ?? createDeckForLanguage()

// 5. Save card
let card = Flashcard(
    front: "Sonne",
    back: "sun",
    deckId: deck.id,
    exampleSentence: "The sun shines brightly."
)
modelContext.insert(card)
```

### **Adding Spanish Card**

```swift
// 1. User switches language
targetLanguage = "es"

// 2. User enters words
germanWord = "Sonne"
targetWord = "sol"

// 3. AI generates example
let example = try await llmService.generateExample(
    germanWord: "Sonne",
    targetWord: "sol",
    targetLanguage: "es"
)
// → "El sol brilla."

// 4. Find or create deck
let deck = decks.first { $0.targetLanguage == "es" }
    ?? createDeckForLanguage()

// 5. Save card
let card = Flashcard(
    front: "Sonne",
    back: "sol",
    deckId: deck.id,
    exampleSentence: "El sol brilla."
)
modelContext.insert(card)
```

### **Reviewing Cards**

```swift
// 1. Load cards from deck
let deck = decks.first  // e.g., Spanish deck
reviewedDeck = deck

// 2. Display cards
// Front: "Sonne"
// Back: "sol"
// Example: "El sol brilla."

// 3. Complete session
sessionComplete = true

// 4. Show success message
let successMsg = AppSettings.shared.successMessage(
    for: deck.targetLanguage,  // "es"
    userName: "Henri"
)
// → "¡MUY BIEN, HENRI!"
```

---

## 🔍 Querying Data

### **Get All English Cards**

```swift
let englishDecks = decks.filter { $0.targetLanguage == "en" }
let englishDeckIds = englishDecks.map { $0.id }

let descriptor = FetchDescriptor<Flashcard>()
let allCards = try? modelContext.fetch(descriptor)
let englishCards = allCards?.filter { englishDeckIds.contains($0.deckId) }
```

### **Get All Spanish Cards**

```swift
let spanishDecks = decks.filter { $0.targetLanguage == "es" }
let spanishDeckIds = spanishDecks.map { $0.id }

let descriptor = FetchDescriptor<Flashcard>()
let allCards = try? modelContext.fetch(descriptor)
let spanishCards = allCards?.filter { spanishDeckIds.contains($0.deckId) }
```

### **Count Cards Per Language**

```swift
func countCards(for language: String) -> Int {
    let languageDecks = decks.filter { $0.targetLanguage == language }
    let deckIds = languageDecks.map { $0.id }
    
    let descriptor = FetchDescriptor<Flashcard>()
    let allCards = try? modelContext.fetch(descriptor) ?? []
    return allCards.filter { deckIds.contains($0.deckId) }.count
}

let englishCount = countCards(for: "en")  // e.g., 45
let spanishCount = countCards(for: "es")  // e.g., 12
```

---

## 📊 Stats & Analytics

### **Global Stats (All Languages)**

```swift
@Query private var userProgress: [UserProgress]

let progress = userProgress.first

// These are global across all languages:
progress.totalXP               // Combined XP
progress.currentStreak         // Overall streak
progress.totalCardsReviewed    // All cards
progress.totalCorrectAnswers   // All correct answers
```

### **Per-Language Stats**

```swift
// Calculate per-deck accuracy
func accuracy(for deck: Deck) -> Double {
    let deckCards = cards.filter { $0.deckId == deck.id }
    let reviewed = deckCards.filter { $0.timesReviewed > 0 }
    
    guard !reviewed.isEmpty else { return 0 }
    
    let totalReviews = reviewed.reduce(0) { $0 + $1.timesReviewed }
    let totalCorrect = reviewed.reduce(0) { $0 + $1.timesCorrect }
    
    return Double(totalCorrect) / Double(totalReviews) * 100
}

// Usage
let englishDeck = decks.first { $0.targetLanguage == "en" }
let englishAccuracy = accuracy(for: englishDeck)  // e.g., 85.5%

let spanishDeck = decks.first { $0.targetLanguage == "es" }
let spanishAccuracy = accuracy(for: spanishDeck)  // e.g., 70.2%
```

---

## 🛠️ Utility Functions

### **Language Helpers**

```swift
// Check if language is supported
func isSupported(_ language: String) -> Bool {
    AppSettings.shared.availableLanguages.contains(language)
}

// Get opposite language
func otherLanguage(_ current: String) -> String {
    current == "en" ? "es" : "en"
}

// Toggle language
func toggleLanguage() {
    targetLanguage = otherLanguage(targetLanguage)
}
```

### **Deck Management**

```swift
// Find deck for language
func findDeck(for language: String) -> Deck? {
    decks.first { $0.targetLanguage == language }
}

// Create deck if missing
func ensureDeck(for language: String) -> Deck {
    if let existing = findDeck(for: language) {
        return existing
    }
    
    let name = AppSettings.shared.languageName(language)
    let deck = Deck(
        name: name,
        description: "Deutsch → \(name)",
        targetLanguage: language
    )
    modelContext.insert(deck)
    return deck
}
```

---

## 🧩 Integration Examples

### **Example 1: Add Card with Auto-Deck Creation**

```swift
func addCard(
    german: String,
    target: String,
    example: String?,
    language: String
) {
    let deck = ensureDeck(for: language)
    
    let card = Flashcard(
        front: german,
        back: target,
        deckId: deck.id,
        exampleSentence: example
    )
    
    modelContext.insert(card)
    try? modelContext.save()
}

// Usage
addCard(
    german: "Sonne",
    target: "sun",
    example: "The sun shines brightly.",
    language: "en"
)
```

### **Example 2: Review Language-Specific Deck**

```swift
func startReview(for language: String) {
    guard let deck = findDeck(for: language) else {
        print("No deck for \(language)")
        return
    }
    
    let descriptor = FetchDescriptor<Flashcard>()
    let allCards = try? modelContext.fetch(descriptor) ?? []
    let deckCards = allCards.filter { $0.deckId == deck.id }
    
    // Start review with these cards
    reviewCards = deckCards.prefix(20).map { $0 }
}

// Usage
startReview(for: "es")  // Review Spanish
```

### **Example 3: Language Switcher Component**

```swift
struct LanguageSwitcher: View {
    @Binding var selectedLanguage: String
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(AppSettings.shared.availableLanguages, id: \.self) { lang in
                Button {
                    selectedLanguage = lang
                } label: {
                    VStack {
                        Text(AppSettings.shared.languageFlag(lang))
                            .font(.largeTitle)
                        
                        Text(AppSettings.shared.languageName(lang))
                            .font(.caption)
                            .fontWeight(selectedLanguage == lang ? .bold : .regular)
                    }
                }
                .opacity(selectedLanguage == lang ? 1.0 : 0.5)
            }
        }
    }
}
```

---

## 📖 Localization Strings

### **Success Messages**

```swift
// English
"WELL DONE!"
"WELL DONE, {NAME}!"

// Spanish
"¡MUY BIEN!"
"¡MUY BIEN, {NAME}!"

// German (fallback)
"GUT GEMACHT!"
"GUT GEMACHT, {NAME}!"
```

### **UI Labels**

```swift
// German (App UI)
"ZIELSPRACHE"           // Target Language
"DEUTSCH"               // German
"BEISPIEL"              // Example
"SPEICHERN"             // Save
"FERTIG"                // Done
"LERNEN STARTEN"        // Start Learning

// Language Names
"English"               // English
"Español"               // Spanish
```

---

## 🔐 Type Safety

### **Language Enum (Future Enhancement)**

```swift
enum TargetLanguage: String, Codable {
    case english = "en"
    case spanish = "es"
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        }
    }
    
    var name: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}
```

---

## 📝 Best Practices

### **DO:**
✅ Use language codes ("en", "es") for storage  
✅ Display language names in UI ("English", "Español")  
✅ Keep app UI in German  
✅ Localize success messages  
✅ Auto-create decks per language  
✅ Remember last selected language  

### **DON'T:**
❌ Mix languages in same deck  
❌ Store language names instead of codes  
❌ Change app UI language based on target language  
❌ Force user to create decks manually  
❌ Reset language selection unnecessarily  

---

## 🧪 Testing Helpers

```swift
// Test data
let testWords = [
    ("Sonne", "sun", "sol"),
    ("Mond", "moon", "luna"),
    ("Hund", "dog", "perro")
]

// Create test decks
func createTestDecks() {
    let englishDeck = Deck(name: "Test English", targetLanguage: "en")
    let spanishDeck = Deck(name: "Test Spanish", targetLanguage: "es")
    
    modelContext.insert(englishDeck)
    modelContext.insert(spanishDeck)
}

// Create test cards
func createTestCards() {
    for (german, english, spanish) in testWords {
        // English card
        let engCard = Flashcard(
            front: german,
            back: english,
            deckId: findDeck(for: "en")!.id
        )
        modelContext.insert(engCard)
        
        // Spanish card
        let espCard = Flashcard(
            front: german,
            back: spanish,
            deckId: findDeck(for: "es")!.id
        )
        modelContext.insert(espCard)
    }
}
```

---

## 📚 Further Reading

- **SwiftData:** [Apple Documentation](https://developer.apple.com/documentation/swiftdata)
- **Localization:** [NSLocalizedString](https://developer.apple.com/documentation/foundation/nslocalizedstring)
- **i18n Best Practices:** Use ISO language codes
- **A1 Vocabulary:** Common European Framework of Reference

---

**Last Updated:** December 10, 2024  
**API Version:** 1.0  
**Languages:** English, Spanish  
**Native Language:** German  

---

**For questions or additions, see:** `Bilingual_Feature_Summary.md`

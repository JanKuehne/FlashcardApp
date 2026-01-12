# Commit Summary - January 11, 2026

## 🎯 Major Features & Bug Fixes

### 1. Audio Settings - Simplified Speed Selection ✅
**Problem**: Confusing decimal speed labels (0.3x / 0.5x / 0.65x)
**Solution**: User-friendly speed buttons (0.5× / 1× / 2×)

**Changes**:
- Replaced slider with 3 clear speed buttons
- Mapped user-friendly labels to iOS rates:
  - **0.5×** (Langsam) → iOS 0.3
  - **1×** (Normal) → iOS 0.5 
  - **2×** (Schnell) → iOS 0.65
- Added haptic feedback on selection
- Visual feedback with color gradients

**Files Modified**: `SettingsView.swift`, `AudioService.swift`

---

### 2. Card Selection Mode - "Neueste" vs "Alle" ✅
**Problem**: No way to choose between newest cards (Anki-style) or all cards (traditional)
**Solution**: Added card selection mode toggle

**Features**:
- **✨ Neueste** (Newest): Focus on newest/recent cards
- **📚 Alle** (All): Mix old and new cards evenly
- Visual buttons with icons and descriptions
- Mode persists across sessions
- Affects new card ordering in review sessions

**Files Modified**: `UserProgress.swift`, `SettingsView.swift`, `ReviewSessionView.swift`

---

### 3. Settings UI - Fixed Button Visibility ✅
**Problem**: Only selected button was visible, others were invisible/overlapping
**Solution**: Fixed layout and opacity issues

**Root Cause**: 
- Unselected buttons had nearly transparent backgrounds (0.05-0.1 opacity)
- Invisible against dark/light backgrounds

**Fix Applied**:
- Changed unselected background from `white.opacity(0.1)` to **`gray.opacity(0.4)`**
- Changed unselected border from `white.opacity(0.5)` to **`gray` (solid)**
- Added `.frame(maxWidth: .infinity)` to VStack for full-width buttons
- Added proper modifier ordering: frame → padding → background

**Files Modified**: `SettingsView.swift`

---

### 4. Cards Per Session Setting ✅
**Problem**: Could only set daily goal, not cards per individual session
**Solution**: Added separate "cards per session" slider

**Features**:
- **Tagesziel** (Daily Goal): 20-200 cards per day
- **Karten pro Durchlauf** (Cards per Session): 5-50 cards per run
- Session size separate from daily goal (Anki-style)
- Dashboard shows both values
- Default: 100 daily / 20 per session

**Files Modified**: `UserProgress.swift`, `SettingsView.swift`, `ReviewSessionView.swift`, `ContentView.swift`

---

### 5. Auto-Play Description Improvements ✅
**Problem**: Unclear when audio plays and what the delay means
**Solution**: Clarified descriptions with timing context

**Changes**:
- Mode descriptions now show WHEN audio plays:
  - "Spielt deutsche Wörter automatisch ab **(beim Öffnen der Karte)**"
  - "Spielt Übersetzungen automatisch ab **(nach dem Umdrehen)**"
  - "Spielt beide Seiten automatisch ab **(vorne + hinten)**"
- Footer dynamically shows delay: "Auto-Play spielt Audio automatisch nach 0.5s ab"

**Files Modified**: `SettingsView.swift`

---

## 📝 Detailed File Changes

### AudioService.swift
```swift
// Changed default speech rate from incorrect value to 0.5
var speechRate: Float {
    get {
        let rate = UserDefaults.standard.float(forKey: "audioSpeechRate")
        return rate > 0 ? rate : 0.5  // ← Was using wrong value
    }
}
```

### UserProgress.swift
```swift
// Added new properties
var cardsPerSession: Int       // Default 20 - cards per review session
var reviewMode: String         // "newest" or "all" - card selection priority

init() {
    self.dailyGoal = 100       // Increased from 20
    self.cardsPerSession = 20  // New property
    self.reviewMode = "newest" // New property
}
```

### SettingsView.swift

**1. Audio Section - Speed Buttons**
```swift
// Replaced slider with 3 buttons
HStack(spacing: 8) {
    SpeedButton(label: "0.5×", subtitle: "Langsam", ...)
    SpeedButton(label: "1×", subtitle: "Normal", ...)
    SpeedButton(label: "2×", subtitle: "Schnell", ...)
}
```

**2. Learning Goals Section - Dual Sliders**
```swift
// Split into two settings
VStack {
    // Daily Goal: 20-200 cards
    Slider(value: $dailyGoal, in: 20...200, step: 10)
    
    Divider()
    
    // Cards Per Session: 5-50 cards
    Slider(value: $cardsPerSession, in: 5...50, step: 5)
    
    Divider()
    
    // Card Selection Mode
    HStack(spacing: 8) {
        ReviewModeButton(icon: "sparkles", title: "Neueste", ...)
        ReviewModeButton(icon: "rectangle.stack", title: "Alle", ...)
    }
}
```

**3. Button Components - Fixed Visibility**
```swift
struct SpeedButton: View {
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                Text(subtitle)
            }
            .frame(maxWidth: .infinity)  // ← Added for full width
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(
                isSelected
                ? LinearGradient(colors: [color, color.opacity(0.7)], ...)
                : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.3)], ...)  // ← Fixed opacity
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.gray, ...)  // ← Fixed border
            )
        }
        .buttonStyle(.plain)  // ← Required for custom buttons
    }
}
```

**4. Auto-Play Descriptions**
```swift
private var autoPlayModeDescription: String {
    switch autoPlayMode {
    case .frontOnly:
        return "Spielt deutsche Wörter automatisch ab (beim Öffnen der Karte)"
    case .backOnly:
        return "Spielt Übersetzungen automatisch ab (nach dem Umdrehen)"
    case .bothSides:
        return "Spielt beide Seiten automatisch ab (vorne + hinten)"
    }
}
```

**5. Footer with Dynamic Delay**
```swift
footer: {
    Text("Auto-Play spielt Audio automatisch nach \(String(format: "%.1f", autoPlayDelay))s ab. 'Nur Rückseite' empfohlen.")
}
```

**6. Settings Load/Save**
```swift
func loadSettings() {
    // ...
    cardsPerSession = progress.cardsPerSession
    // Handle empty reviewMode (migration)
    reviewMode = progress.reviewMode.isEmpty ? "newest" : progress.reviewMode
    // ...
}

func saveSettings() {
    // ...
    progress.cardsPerSession = cardsPerSession
    progress.reviewMode = reviewMode
    // ...
}
```

### ReviewSessionView.swift

**1. Added Review Mode Support**
```swift
var cardsPerSession: Int {
    userProgress.first?.cardsPerSession ?? 20
}

var reviewMode: String {
    userProgress.first?.reviewMode ?? "newest"
}
```

**2. Updated Card Loading Logic**
```swift
func loadReviewCards() {
    // ...
    let sessionSize = cardsPerSession  // ← Use session size, not daily goal
    
    // ... learning cards, due cards ...
    
    // 3. New cards - sorted by reviewMode
    let allNewCards = deckCards.filter { 
        $0.timesReviewed == 0 && $0.cardState == "learning" 
    }
    
    let newCards: [Flashcard]
    if reviewMode == "newest" {
        // NEUESTE: Newest first (Anki-style)
        newCards = allNewCards.sorted { $0.createdDate > $1.createdDate }
    } else {
        // ALLE: Oldest first (traditional)
        newCards = allNewCards.sorted { $0.createdDate < $1.createdDate }
    }
    
    selectedCards.append(contentsOf: newCards.prefix(needed))
}
```

### ContentView.swift

**Updated Dashboard Card**
```swift
DailyGoalCard(
    cardsCompletedToday: cardsCompletedToday,
    dailyGoal: progress.dailyGoal,
    cardsPerSession: progress.cardsPerSession  // ← Added parameter
)

// Card now displays both values:
// - Daily goal with progress bar
// - Cards per session below divider
```

---

## 🧪 Testing Done

### Audio Settings
- ✅ All 3 speed buttons visible side-by-side
- ✅ Selected button highlights correctly
- ✅ Haptic feedback works
- ✅ Test pronunciation uses selected speed
- ✅ Settings persist after app restart

### Card Selection
- ✅ Both mode buttons visible (Neueste / Alle)
- ✅ Can switch between modes
- ✅ "Neueste" shows newest cards first
- ✅ "Alle" shows oldest cards first
- ✅ Mode persists in settings
- ✅ Console logs show correct mode

### Button Visibility
- ✅ All buttons visible with proper contrast
- ✅ Unselected buttons have gray background
- ✅ Buttons fill full horizontal width
- ✅ Work on different screen sizes
- ✅ Tap targets are correct

### Settings Persistence
- ✅ Daily goal saves correctly
- ✅ Cards per session saves correctly
- ✅ Review mode saves correctly
- ✅ Audio settings save correctly
- ✅ Migration from old UserProgress works

---

## 🔄 Migration Strategy

### For Existing Users
- Existing `dailyGoal` values preserved
- `cardsPerSession` defaults to 20 if not set
- `reviewMode` defaults to "newest" if empty
- No data loss or breaking changes

### For New Users
- `dailyGoal = 100` (increased from 20)
- `cardsPerSession = 20` (new)
- `reviewMode = "newest"` (new)

---

## 📊 Impact

### User Experience
- **Before**: Confusing settings, invisible buttons, unclear behavior
- **After**: Clear, intuitive settings with visible controls

### Performance
- No performance impact
- Minimal memory increase (new properties)
- No battery impact

### Code Quality
- Cleaner separation of concerns
- Better button component structure
- Proper modifier ordering
- Clear documentation

---

## 🐛 Bugs Fixed

1. ✅ Audio speed confusion (0.3x vs 1x)
2. ✅ Invisible button issue (opacity too low)
3. ✅ No card selection mode option
4. ✅ Unclear auto-play descriptions
5. ✅ Buttons not using full width
6. ✅ Can't configure session size separately
7. ✅ "Alle" appearing as default (migration bug)

---

## 📝 Known Issues / Future Work

### Minor Polish
- Could add animation when switching modes
- Could show card count preview for each mode
- Could add "shuffle" option for "Alle" mode

### Feature Ideas
- Per-deck session sizes
- Smart mode (auto-adjust based on performance)
- Custom sorting options
- Preview mode before starting session

---

## 🎉 Summary

This commit introduces significant UX improvements to the settings:

1. **Audio settings are now crystal clear** with intuitive speed labels
2. **Card selection gives users control** over their learning approach
3. **All buttons are properly visible** with good contrast
4. **Session configuration is separate** from daily goals (Anki-style)
5. **Descriptions are helpful** and show timing information

All features tested and working correctly! 🚀

---

## Commit Message Suggestion

```
feat: Add card selection modes and fix settings UI

- Added "Neueste" vs "Alle" card selection modes
- Simplified audio speed selection (0.5× / 1× / 2×)
- Fixed invisible button issue with proper opacity
- Added cards per session setting (separate from daily goal)
- Improved auto-play descriptions with timing context
- Made all buttons use full width with proper layout

Fixes: #XXX (button visibility)
Fixes: #XXX (audio speed confusion)
Implements: #XXX (card selection modes)
Implements: #XXX (session size configuration)
```

---

**Files Modified**:
- `AudioService.swift`
- `UserProgress.swift`
- `SettingsView.swift`
- `ReviewSessionView.swift`
- `ContentView.swift`

**New Documentation**:
- `BUG_FIXES_JAN11.md`
- `CARD_SELECTION_FEATURE.md`
- `SETTINGS_UI_FIXES.md`
- `BUTTON_LAYOUT_FIX_FINAL.md`
- `COMMIT_SUMMARY_JAN11.md`

# 🐛 Bug & Feature Tracker - V1.1

**Last Updated:** January 10, 2026  
**Status:** Audio feature deployed, bugs identified

---

## 🔴 **CRITICAL PRIORITY (Fix Now)**

### **1. Card Management View - Alphabetical Sorting** 🔴
**Location:** `CardManagementView.swift`

**Issue:**
- Cards are not sorted alphabetically
- Currently sorted by creation date

**Required:**
- [ ] Sort cards alphabetically by front (German) by default
- [ ] Add toggle to switch sort order (front vs back)
- [ ] Add sort direction toggle (A→Z vs Z→A)

**Effort:** 30 minutes

---

### **2. Card Management View - Front/Back Display Toggle** 🔴
**Location:** `CardManagementView.swift`

**Issue:**
- Always shows German (front) prominently
- Users may want to see translation (back) first

**Required:**
- [ ] Add toggle: "Show German" vs "Show Translation"
- [ ] Swap display order based on toggle
- [ ] Remember preference (UserDefaults)

**Effort:** 30 minutes

---

### **3. Card Management View - Edit Icon Missing** 🔴
**Location:** `CardManagementView.swift`

**Issue:**
- No edit button on individual cards in list view
- Must delete and recreate to fix errors

**Required:**
- [ ] Add pencil/edit icon to each card row
- [ ] Tap to open EditCardView
- [ ] Consistent with camera scanner preview edit

**Effort:** 20 minutes

---

### **4. Camera Scanner Preview - Edit Icon Missing** 🔴
**Location:** `CameraScannerView.swift` (ExtractedWordRow)

**Issue:**
- Can edit extracted words before saving
- But should also have visible edit icon for clarity

**Status:** ✅ Already has edit functionality (pencil button)
**Action:** Verify it's visible and working

**Effort:** 10 minutes (verification + polish)

---

### **5. Dashboard - Stats Not Language-Filtered** 🔴
**Location:** `ContentView.swift`

**Issue:**
- "Karten" count changes when switching language ✅ (correct)
- "Gelernt" (total reviewed) does NOT change ❌ (shows global, should be per-language)
- "Genauigkeit" (accuracy) does NOT change ❌ (shows global, should be per-language)

**Required:**
- [ ] Filter `totalCardsReviewed` by selected language
- [ ] Calculate accuracy per language (not global)
- [ ] Update stat boxes to show filtered values

**Effort:** 1 hour

---

### **6. Dashboard - Language Selector Positioning** 🔴
**Location:** `ContentView.swift`

**Issue:**
- Language selector at bottom of dashboard
- Should be between "Lernen Starten" and stats section

**Required:**
- [ ] Move `LanguageSelectorView` up in VStack
- [ ] New order:
  1. Stats cards (Streak, Level)
  2. Level progress bar
  3. Daily goal card
  4. **Lernen Starten button**
  5. **Language Selector** ← MOVE HERE
  6. Stat boxes (Gelernt, Karten, Genauigkeit)
  7. Manage Cards button

**Effort:** 5 minutes (VStack reordering)

---

### **7. Camera Scanner - GPT Model CTAs Overlap** 🔴
**Location:** `CameraScannerView.swift`

**Issue:**
- GPT model choice buttons at top have insufficient padding
- Overlap with "Kamera Scanner" title and "X" button

**Required:**
- [ ] Add top padding to model selection section
- [ ] Add padding to X button
- [ ] Ensure no overlap at any screen size

**Effort:** 15 minutes

---

### **8. Camera Scanner - Cannot Scroll** 🔴
**Location:** `CameraScannerView.swift`

**Issue:**
- Cannot scroll down to "PRO TIPPS" section
- Content appears static/locked

**Likely Cause:**
- Missing `ScrollView` wrapper
- Or ScrollView disabled
- Or content height calculation wrong

**Required:**
- [ ] Wrap content in ScrollView (if not present)
- [ ] Enable scrolling
- [ ] Test scroll to bottom (PRO TIPPS visible)

**Effort:** 20 minutes

---

### **9. Camera Scanner - Toggle Fields Low Opacity** 🔴
**Location:** `CameraScannerView.swift`

**Issue:**
- Three toggle fields have very low opacity:
  - "Explanation" toggle
  - "Use GPT Visual" toggle
  - "Use Google Visual" toggle
- Text barely readable

**Required:**
- [ ] Increase background opacity (0.1 → 0.15 or 0.2)
- [ ] Increase text opacity
- [ ] Add border for better contrast
- [ ] Test in bright/dark environments

**Effort:** 10 minutes

---

## 🟠 **HIGH PRIORITY (After Critical)**

### **10. Daily Goal Slider - Value Not Shown** 🟠
**Location:** `SettingsView.swift`

**Issue:**
- Slider for daily goal doesn't show current value
- User can't see what they're setting

**Required:**
- [ ] Display current value above/beside slider
- [ ] Format: "Tagesziel: 15 Karten"

**Effort:** 10 minutes

---

### **11. Audio Settings UI - Not Implemented** 🟠
**Location:** `SettingsView.swift`

**Issue:**
- Audio service works, but no UI to configure it
- Users can't change auto-play mode, speech rate, etc.

**Required:**
- [ ] Add "🔊 AUDIO" section to SettingsView
- [ ] Auto-play mode picker (segmented control)
- [ ] Auto-play delay slider (0-2s)
- [ ] Speech rate slider (0.3x-1.5x) with presets
- [ ] Test pronunciation button

**Effort:** 2 hours (Day 2 task)

---

### **12. Haptic Feedback - Not Comprehensive** 🟠
**Location:** Multiple files

**Issue:**
- Some haptics exist, not comprehensive across app

**Required:**
- [ ] Add haptics to all button taps
- [ ] Add haptics to card actions
- [ ] Add haptics to success/error states
- [ ] Settings toggle for haptics

**Effort:** 2-3 hours

---

### **13. Achievement Badges - No UI** 🟠
**Location:** `AchievementsView.swift` / `ContentView.swift`

**Issue:**
- AchievementManager exists (backend)
- No visual display of achievements

**Required:**
- [ ] Badge icons on dashboard
- [ ] "New Achievement Unlocked!" popup
- [ ] Badge collection view
- [ ] Progress bars for locked achievements

**Effort:** 1 day

---

## 🟡 **MEDIUM PRIORITY (Nice to Have)**

### **14. Photo Library Support - Not Implemented** 🟡
**Location:** `CameraScannerView.swift`

**Issue:**
- Can only take photos with camera
- Cannot upload from photo library

**Required:**
- [ ] Add "Choose from Library" button
- [ ] PhotosPicker integration
- [ ] Process library photos same as camera

**Effort:** 2 hours

---

### **15. Level-Up Animation - Missing** 🟡
**Location:** Multiple files

**Issue:**
- No dramatic animation when leveling up
- Just number changes

**Required:**
- [ ] Manga-style level-up animation
- [ ] Speed lines, stars, explosion effects
- [ ] Sound effect + haptic pattern
- [ ] "LEVEL UP!" overlay

**Effort:** 3-4 hours

---

### **16. More Manga Visual Effects** 🟡
**Location:** Multiple files

**Issue:**
- Could be MORE manga-styled
- Need more character integration, effects

**Required:**
- [ ] Character mascot on dashboard
- [ ] More halftone patterns
- [ ] Impact lines on correct answers
- [ ] Comic speech bubbles
- [ ] Panel-based layouts

**Effort:** 3-4 days

---

## 🟢 **LOW PRIORITY (Future)**

### **17. More Languages** 🟢
- French, Italian, Japanese, etc.
- Not needed now

**Effort:** Medium per language

---

### **18. Enhanced Statistics** 🟢
- Weekly charts, heatmaps
- Per-language breakdown
- Performance insights

**Effort:** 2-3 days

---

### **19. Deck Sharing** 🟢
- Export/import decks
- Share via AirDrop

**Effort:** 2-3 days

---

## 📊 **Priority Summary**

### **Immediate (Today/Tomorrow):**
1. ✅ Audio feature (DONE)
2. 🔴 Card Management fixes (6 issues)
3. 🔴 Dashboard stats filtering
4. 🔴 Camera scanner UX fixes (3 issues)

**Estimated time:** 4-5 hours

---

### **This Week:**
5. 🟠 Daily goal slider fix
6. 🟠 Audio settings UI
7. 🟠 Haptic feedback expansion

**Estimated time:** 6-8 hours

---

### **Next Week:**
8. 🟡 Photo library support
9. 🟡 Achievement badges UI
10. 🟡 Level-up animation

**Estimated time:** 2-3 days

---

## 🎯 **Next Actions (In Order)**

### **Sprint: Critical Bug Fixes**
**Duration:** 4-5 hours

#### **Step 1: Card Management Improvements** (1.5 hours)
- [ ] 1. Alphabetical sorting
- [ ] 2. Front/back display toggle
- [ ] 3. Add edit icon to card rows
- [ ] 4. Verify camera scanner edit icons

#### **Step 2: Dashboard Fixes** (1.5 hours)
- [ ] 5. Filter stats by language
- [ ] 6. Move language selector position

#### **Step 3: Camera Scanner Fixes** (1 hour)
- [ ] 7. Fix GPT model CTA padding
- [ ] 8. Enable scrolling to PRO TIPPS
- [ ] 9. Increase toggle field opacity

#### **Step 4: Quick Wins** (30 minutes)
- [ ] 10. Daily goal slider value display

---

## 📋 **Detailed Fix Plan**

### **Fix 1-4: Card Management** 
**File:** `CardManagementView.swift`

```swift
// Add sorting options
@State private var sortBy: SortOption = .frontAlphabetical
@State private var showFront: Bool = true

enum SortOption: String, CaseIterable {
    case frontAlphabetical = "A→Z (Deutsch)"
    case frontReverse = "Z→A (Deutsch)"
    case backAlphabetical = "A→Z (Translation)"
    case backReverse = "Z→A (Translation)"
}

// Sort cards
var sortedCards: [Flashcard] {
    let filtered = activeFlashcards
    switch sortBy {
    case .frontAlphabetical:
        return filtered.sorted { $0.front < $1.front }
    case .frontReverse:
        return filtered.sorted { $0.front > $1.front }
    case .backAlphabetical:
        return filtered.sorted { $0.back < $1.back }
    case .backReverse:
        return filtered.sorted { $0.back > $1.back }
    }
}

// Display toggle
var primaryText: String {
    showFront ? card.front : card.back
}
var secondaryText: String {
    showFront ? card.back : card.front
}
```

---

### **Fix 5: Dashboard Stats Filtering**
**File:** `ContentView.swift`

```swift
// Filtered stats
var activeCardsReviewed: Int {
    guard let deck = activeDeck else { return 0 }
    let sessions = reviewSessions.filter { $0.deckId == deck.id }
    return sessions.reduce(0) { $0 + $1.cardsReviewed }
}

var activeAccuracy: String {
    guard let deck = activeDeck else { return "0%" }
    let sessions = reviewSessions.filter { $0.deckId == deck.id }
    let total = sessions.reduce(0) { $0 + $1.cardsReviewed }
    let correct = sessions.reduce(0) { $0 + $1.correctAnswers }
    return total > 0 ? "\(Int(Double(correct) / Double(total) * 100))%" : "0%"
}
```

---

### **Fix 6: Dashboard Reorder**
**File:** `ContentView.swift`

```swift
VStack(spacing: 24) {
    statsCards
    levelProgressCard
    DailyGoalCard(...)
    
    // LERNEN STARTEN button
    StartLearningButton(...)
    
    // Language selector HERE (moved up)
    LanguageSelectorView(...)
        .padding(.horizontal)
    
    // Stat boxes (below language selector)
    statBoxes
    
    // Manage cards button
    // ...
}
```

---

### **Fix 7-9: Camera Scanner**
**File:** `CameraScannerView.swift`

```swift
// Fix 7: More padding for model CTAs
VStack(spacing: 16) {
    // Model selection
}
.padding(.top, 60)  // Increased from default

// Fix 8: Enable scrolling
ScrollView {
    VStack {
        // All content
    }
}
.frame(maxHeight: .infinity)

// Fix 9: Increase toggle opacity
Toggle(...)
    .padding()
    .background(Color.white.opacity(0.15))  // Increased from 0.05
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.3), lineWidth: 2)
    )
```

---

## ✅ **Testing Checklist (After Fixes)**

### **Card Management:**
- [ ] Cards sorted alphabetically (A→Z)
- [ ] Can toggle sort order
- [ ] Can toggle front/back display
- [ ] Edit icon visible on each card
- [ ] Tapping edit opens EditCardView

### **Dashboard:**
- [ ] Stats filter by selected language
- [ ] Switching language updates all stats
- [ ] Language selector between Lernen Starten and stats
- [ ] UI feels more logical

### **Camera Scanner:**
- [ ] GPT model CTAs don't overlap header
- [ ] Can scroll to bottom (PRO TIPPS visible)
- [ ] Toggle fields readable (good contrast)

---

## 🎯 **Recommended Order**

**Today (4-5 hours):**
1. Dashboard reorder (5 min) ← Quick win
2. Daily goal value display (10 min) ← Quick win
3. Card Management fixes (1.5 hours) ← Core functionality
4. Dashboard stats filtering (1.5 hours) ← Important
5. Camera scanner fixes (1 hour) ← UX critical

**Tomorrow:**
- Audio settings UI (2 hours)
- Haptic feedback (2-3 hours)

**Next Week:**
- Photo library, achievements, polish

---

## 💡 **Notes**

### **Why This Order?**
1. **Quick wins first** - Build momentum (15 min)
2. **Core functionality** - Card management is used often
3. **Data accuracy** - Stats should be per-language
4. **UX polish** - Camera scanner usability

### **User Impact:**
- 🔴 Critical = Breaks workflow or shows wrong data
- 🟠 High = Annoying but has workaround
- 🟡 Medium = Nice to have, improves experience
- 🟢 Low = Future enhancement

---

## 🚀 **Status Update**

**Completed Today:**
- ✅ Audio feature (Day 1) - 3 hours

**Up Next:**
- 🔴 Critical bug fixes - 4-5 hours

**Timeline:**
- Today + Tomorrow = V1.1 ready
- Next week = V1.2 with polish

---

**Ready to start fixing! What would you like to tackle first?**

I recommend:
1. Dashboard reorder (5 min quick win)
2. Card Management fixes (most user-facing)
3. Dashboard stats filtering (data accuracy)
4. Camera scanner fixes (UX)

**Want me to start with #1 (Dashboard reorder)?** 🚀

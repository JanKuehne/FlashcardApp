# ⚡️ QUICK FIX SPRINT - Critical Bugs

**Date:** January 10, 2026  
**Duration:** 4-5 hours  
**Goal:** Fix all critical UX and data issues

---

## 🎯 **The Plan (In Order)**

### **Fix #1: Dashboard Reorder** ⚡️ 5 MINUTES
**Impact:** Better UX flow  
**File:** `ContentView.swift`

**Change:** Move language selector up

**Before:**
```
1. Stats cards
2. Level progress
3. Daily goal
4. Lernen Starten button
5. Stat boxes
6. Manage cards button
7. Language selector ← Too far down!
```

**After:**
```
1. Stats cards
2. Level progress
3. Daily goal
4. Lernen Starten button
5. Language selector ← MOVED HERE
6. Stat boxes
7. Manage cards button
```

---

### **Fix #2: Daily Goal Value Display** ⚡️ 10 MINUTES
**Impact:** Users can see what they're setting  
**File:** `SettingsView.swift`

**Add:**
```swift
Text("Tagesziel: \(progress.dailyGoal) Karten")
    .font(.system(.headline, design: .rounded))
    .fontWeight(.bold)
    .foregroundColor(.white)

Slider(value: $dailyGoal, in: 5...50, step: 1)
```

---

### **Fix #3: Card Management - Alphabetical Sort** ⏱️ 30 MINUTES
**Impact:** Easier to find cards  
**File:** `CardManagementView.swift`

**Add:**
```swift
@State private var sortOption: SortOption = .alphabeticalFront

enum SortOption: String, CaseIterable {
    case alphabeticalFront = "A→Z (Deutsch)"
    case alphabeticalBack = "A→Z (Übersetzung)"
    case dateCreated = "Neueste zuerst"
}

var sortedCards: [Flashcard] {
    switch sortOption {
    case .alphabeticalFront:
        return activeFlashcards.sorted { $0.front < $1.front }
    case .alphabeticalBack:
        return activeFlashcards.sorted { $0.back < $1.back }
    case .dateCreated:
        return activeFlashcards.sorted { $0.createdDate > $1.createdDate }
    }
}

// Picker in toolbar
Picker("Sort", selection: $sortOption) {
    ForEach(SortOption.allCases, id: \.self) { option in
        Text(option.rawValue).tag(option)
    }
}
.pickerStyle(.menu)
```

---

### **Fix #4: Card Management - Front/Back Toggle** ⏱️ 20 MINUTES
**Impact:** Flexibility in how cards displayed  
**File:** `CardManagementView.swift`

**Add:**
```swift
@State private var showFrontFirst: Bool = true

// Toggle button in toolbar
Button {
    showFrontFirst.toggle()
} label: {
    Image(systemName: showFrontFirst ? "textformat.abc" : "character.textbox")
        .font(.title3)
}

// In card row display
Text(showFrontFirst ? card.front : card.back)
    .font(.system(.body, design: .rounded))
    .fontWeight(.bold)
    .foregroundColor(.white)

Text("→ \(showFrontFirst ? card.back : card.front)")
    .font(.system(.caption, design: .rounded))
    .foregroundColor(.green)
```

---

### **Fix #5: Card Management - Edit Icon** ⏱️ 15 MINUTES
**Impact:** Clear edit affordance  
**File:** `CardManagementView.swift`

**Add to card row:**
```swift
// Edit button
NavigationLink(destination: EditCardView(card: card)) {
    Image(systemName: "pencil.circle.fill")
        .font(.title3)
        .foregroundColor(.blue.opacity(0.8))
}
```

---

### **Fix #6: Dashboard - Stats Per Language** ⏱️ 1.5 HOURS
**Impact:** Accurate data (CRITICAL!)  
**File:** `ContentView.swift`

**Problem:** Stats are global, should be per-language

**Solution:**
```swift
// Query all review sessions
@Query private var allReviewSessions: [ReviewSession]

// Filter sessions by active deck
var activeReviewSessions: [ReviewSession] {
    guard let deck = activeDeck else { return [] }
    return allReviewSessions.filter { $0.deckId == deck.id }
}

// Calculate per-language stats
var activeCardsReviewed: Int {
    activeReviewSessions.reduce(0) { $0 + $1.cardsReviewed }
}

var activeAccuracy: String {
    let total = activeReviewSessions.reduce(0) { $0 + $1.cardsReviewed }
    let correct = activeReviewSessions.reduce(0) { $0 + $1.correctAnswers }
    guard total > 0 else { return "0%" }
    return "\(Int(Double(correct) / Double(total) * 100))%"
}

// Update stat boxes
MangaStatBox(
    value: "\(activeCardsReviewed)",  // Per language
    label: "GELERNT",
    color: .blue
)

MangaStatBox(
    value: activeAccuracy,  // Per language
    label: "GENAUIGKEIT",
    color: .green
)
```

**Testing:**
- Switch to English → Shows English stats
- Switch to Spanish → Shows Spanish stats
- Numbers should differ per language

---

### **Fix #7: Camera Scanner - CTA Padding** ⏱️ 15 MINUTES
**Impact:** No overlap, clean UI  
**File:** `CameraScannerView.swift`

**Find:** Model selection section at top

**Add:**
```swift
VStack(spacing: 16) {
    // GPT model toggles
}
.padding(.top, 80)  // Increased padding
.padding(.horizontal, 20)
```

---

### **Fix #8: Camera Scanner - Enable Scrolling** ⏱️ 30 MINUTES
**Impact:** Can see all content  
**File:** `CameraScannerView.swift`

**Problem:** Content not scrollable

**Check:**
1. Is there a ScrollView wrapper?
2. Is content taller than screen?
3. Is scrolling disabled?

**Solution:**
```swift
ScrollView(.vertical, showsIndicators: true) {
    VStack(spacing: 24) {
        // All camera scanner content
        
        // Make sure PRO TIPPS is inside ScrollView!
        proTippsSection
            .padding(.bottom, 40)  // Extra bottom padding
    }
}
```

---

### **Fix #9: Camera Scanner - Toggle Opacity** ⏱️ 10 MINUTES
**Impact:** Readable text  
**File:** `CameraScannerView.swift`

**Find:** Toggle sections

**Update:**
```swift
Toggle("Explanation", isOn: $someToggle)
    .padding()
    .background(Color.white.opacity(0.15))  // Was 0.05
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.3), lineWidth: 2)  // Add border
    )
    .cornerRadius(12)
```

**Apply to:**
- "Explanation" toggle
- "Use GPT Visual" toggle
- "Use Google Visual" toggle

---

## ✅ **Testing Checklist**

### **After Each Fix:**

**Fix #1 (Dashboard Reorder):**
- [ ] Language selector between Lernen Starten and stats
- [ ] Flow feels more natural

**Fix #2 (Daily Goal Value):**
- [ ] Slider shows "Tagesziel: X Karten"
- [ ] Value updates as slider moves

**Fix #3 (Alphabetical Sort):**
- [ ] Cards sorted A→Z by German
- [ ] Can switch to sort by translation
- [ ] Can switch to sort by date

**Fix #4 (Front/Back Toggle):**
- [ ] Toggle button in toolbar
- [ ] Swaps primary/secondary text
- [ ] Icon changes to reflect state

**Fix #5 (Edit Icon):**
- [ ] Pencil icon visible on each card
- [ ] Tapping opens EditCardView
- [ ] Can edit front, back, example

**Fix #6 (Stats Per Language):**
- [ ] English deck → Shows English stats
- [ ] Spanish deck → Shows Spanish stats
- [ ] Global XP/Level unchanged (correct)
- [ ] "Gelernt" and "Genauigkeit" per-language

**Fix #7 (CTA Padding):**
- [ ] No overlap with header
- [ ] All buttons visible and tappable

**Fix #8 (Scrolling):**
- [ ] Can scroll down
- [ ] PRO TIPPS visible at bottom
- [ ] Smooth scrolling

**Fix #9 (Toggle Opacity):**
- [ ] Text is readable
- [ ] Background has good contrast
- [ ] Border adds definition

---

## 📊 **Time Estimate**

| Fix | Time | Cumulative |
|-----|------|------------|
| #1 Dashboard Reorder | 5 min | 5 min |
| #2 Daily Goal Value | 10 min | 15 min |
| #3 Alphabetical Sort | 30 min | 45 min |
| #4 Front/Back Toggle | 20 min | 1h 5min |
| #5 Edit Icon | 15 min | 1h 20min |
| #6 Stats Per Language | 1.5h | 2h 50min |
| #7 CTA Padding | 15 min | 3h 5min |
| #8 Enable Scrolling | 30 min | 3h 35min |
| #9 Toggle Opacity | 10 min | 3h 45min |
| **Testing** | 1h | **4h 45min** |

**Total:** ~5 hours

---

## 🚀 **Execution Order**

### **Session 1 (Quick Wins): 30 minutes**
1. Fix #1: Dashboard reorder (5 min)
2. Fix #2: Daily goal value (10 min)
3. Fix #7: CTA padding (15 min)

**Break** ☕️

### **Session 2 (Card Management): 1.5 hours**
4. Fix #3: Alphabetical sort (30 min)
5. Fix #4: Front/back toggle (20 min)
6. Fix #5: Edit icon (15 min)
7. Test card management (15 min)

**Break** ☕️

### **Session 3 (Dashboard Stats): 1.5 hours**
8. Fix #6: Stats per language (1.5 hours)
9. Test thoroughly (included)

**Break** ☕️

### **Session 4 (Camera Scanner): 1 hour**
10. Fix #8: Enable scrolling (30 min)
11. Fix #9: Toggle opacity (10 min)
12. Test camera scanner (20 min)

---

## 🎯 **What's Next After This?**

### **Immediate Next (Tomorrow):**
- Audio Settings UI (2 hours)
- Comprehensive haptics (2-3 hours)

### **This Week:**
- Photo library support (2 hours)
- Achievement badges UI (1 day)
- Level-up animation (3-4 hours)

### **Next Week:**
- Manga visual enhancements (3-4 days)
- Enhanced statistics (2-3 days)

---

## 💡 **Priority Explanation**

**Why fix these first?**

1. **Data accuracy** (Stats per language) - Shows wrong info = critical
2. **Core functionality** (Card management) - Used every day
3. **UX blockers** (Camera scanner scroll) - Can't access features
4. **Quick wins** (Dashboard reorder) - High impact, low effort

**Why NOT audio settings UI first?**
- Audio works without settings UI
- Users can't see wrong stats or edit cards
- Fix broken things before adding features

---

## 📝 **Implementation Notes**

### **File Order:**
1. `ContentView.swift` (Dashboard fixes)
2. `SettingsView.swift` (Daily goal)
3. `CardManagementView.swift` (Card management)
4. `CameraScannerView.swift` (Camera fixes)

### **Git Commits:**
```
feat: reorder dashboard for better UX flow
fix: display daily goal value on slider
feat: add alphabetical sorting to card management
feat: add front/back display toggle
feat: add edit button to card rows
fix: filter stats by selected language
fix: increase padding for camera scanner CTAs
fix: enable scrolling in camera scanner
fix: increase opacity for toggle fields
```

---

## 🎉 **After This Sprint**

**You'll have:**
- ✅ Audio feature working (DONE)
- ✅ All critical bugs fixed
- ✅ Better UX flow
- ✅ Accurate data
- ✅ All features accessible

**Ready for:**
- Audio settings UI
- Polish and enhancements
- V1.1 release!

---

**Ready to start?** 🚀

**Recommendation:** Start with Session 1 (quick wins) to build momentum!

Want me to begin with Fix #1 (Dashboard reorder)?

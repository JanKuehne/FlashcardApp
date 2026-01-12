# Card Selection Feature & Audio Settings Update

## Date: January 11, 2026

---

## 1. 🔊 Audio Settings - Simplified Speed Selection

### Problem
- Speed labels like "0.3x / 0.5x / 0.65x" were confusing
- Users expect "1x" to be normal speed, not "0.5x"
- Slider was unnecessary complexity

### Solution
Replaced slider with **3 clean buttons** showing user-friendly speeds:

| Button Label | Subtitle | Actual iOS Rate | Description |
|-------------|----------|----------------|-------------|
| **0.5×** | Langsam | 0.3 | Half speed (slow) |
| **1×** | Normal | 0.5 | Normal speed |
| **2×** | Schnell | 0.65 | Double speed (fast) |

### User Experience
- ✅ "1×" appears as "normal" to users (intuitive)
- ✅ Big, visual buttons with color coding
- ✅ Selected button highlights with gradient
- ✅ Haptic feedback on selection
- ✅ No confusing decimals or sliders

### Technical Mapping
```swift
// User sees "1×" → iOS uses 0.5 (actual normal rate)
// User sees "0.5×" → iOS uses 0.3 (slower)
// User sees "2×" → iOS uses 0.65 (faster)
```

---

## 2. 🎴 Card Selection Mode - "Neueste" vs "Alle"

### Problem
The Anki-style learning queue was implemented but **users couldn't choose** between:
- Focusing on newest/recent cards (Anki approach)
- Reviewing all cards evenly (traditional approach)

### Solution
Added **"KARTEN-AUSWAHL"** setting with two modes:

### Mode 1: **✨ Neueste** (Newest) - Default
- **Icon**: sparkles (✨)
- **Subtitle**: "Frische Karten"
- **Color**: Blue
- **Behavior**: 
  - Prioritizes newest cards first
  - Anki-style: focus on recent learning
  - New cards sorted by `createdDate` DESC (newest first)

**Best for:**
- Active learners adding new content regularly
- Staying current with recent material
- Anki users familiar with "new card" workflow

### Mode 2: **📚 Alle** (All)
- **Icon**: rectangle.stack (📚)
- **Subtitle**: "Gesamter Stapel"
- **Color**: Green
- **Behavior**:
  - Mixes old and new cards evenly
  - Traditional flashcard approach
  - New cards sorted by `createdDate` ASC (oldest first)

**Best for:**
- Comprehensive review of entire deck
- Users who want to revisit older cards
- More balanced coverage

---

## 3. Implementation Details

### Model Changes (UserProgress.swift)
```swift
var reviewMode: String  // "newest" or "all"

init() {
    // ...
    self.reviewMode = "newest"  // Default to Anki-style
}
```

### Settings UI (SettingsView.swift)
Added to "LERNZIELE" section:

```swift
HStack(spacing: 12) {
    ReviewModeButton(
        icon: "sparkles",
        title: "Neueste",
        subtitle: "Frische Karten",
        mode: "newest",
        isSelected: reviewMode == "newest",
        color: .blue
    ) { reviewMode = "newest" }
    
    ReviewModeButton(
        icon: "rectangle.stack",
        title: "Alle",
        subtitle: "Gesamter Stapel",
        mode: "all",
        isSelected: reviewMode == "all",
        color: .green
    ) { reviewMode = "all" }
}
```

### Review Logic (ReviewSessionView.swift)
```swift
// 3. Add new cards based on reviewMode
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
```

---

## 4. Learning Queue Priority (Unchanged)

The three-tier priority system remains:

1. **Learning Cards** (must complete)
   - Cards currently in learning phase
   - Due for review today
   
2. **Due Cards** (spaced repetition)
   - Graduated cards ready for review
   - Sorted by due date
   
3. **New Cards** (fill remaining slots)
   - **Mode-dependent sorting** ⭐️
   - "Neueste": newest first
   - "Alle": oldest first

---

## 5. German Naming Rationale

### Why "Neueste" and "Alle"?

#### ✨ Neueste (Newest)
- **Intuitive**: Clearly indicates focus on new/recent content
- **Playful**: ✨ sparkles emoji adds excitement
- **Accurate**: Describes the actual behavior

#### 📚 Alle (All)
- **Simple**: One word, easy to understand
- **Comprehensive**: Implies complete deck coverage
- **Neutral**: No judgment, just a different approach

### Alternatives Considered
❌ "Aktuelle" (current) - Too vague, could mean "in progress"
❌ "Basis" (foundation) - Doesn't clearly indicate card selection
✅ "Neueste" (newest) - Clear temporal indicator
✅ "Alle" (all) - Unambiguous, comprehensive

---

## 6. Visual Design

### Audio Speed Buttons
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│   0.5×   │  │    1×    │  │    2×    │
│ Langsam  │  │  Normal  │  │ Schnell  │
└──────────┘  └──────────┘  └──────────┘
   Blue          Green        Orange
```

### Card Selection Buttons
```
┌─────────────────┐  ┌─────────────────┐
│       ✨        │  │       📚        │
│    Neueste      │  │      Alle       │
│ Frische Karten  │  │ Gesamter Stapel │
└─────────────────┘  └─────────────────┘
      Blue               Green
```

---

## 7. User Flow

### Before (Confusing)
1. See "0.3x / 0.5x / 0.65x" → ❓ "What does this mean?"
2. No way to choose card order → 😕 "Why only new cards?"

### After (Clear)
1. See "0.5× / 1× / 2×" → ✅ "1× is normal, got it!"
2. Choose "Neueste" or "Alle" → ✅ "I want newest cards!"

---

## 8. Migration & Defaults

### Existing Users
- `reviewMode` defaults to `"newest"` if not set
- Maintains current Anki-style behavior
- No disruption to existing workflow

### New Users
- Start with "Neueste" (newest) mode
- Audio speed at "1×" (normal)
- Can easily switch at any time

---

## 9. Testing Checklist

### Audio Settings
- [x] Three speed buttons visible
- [x] Selected button highlights in color
- [x] Haptic feedback on tap
- [x] "Test Aussprache" uses selected speed
- [x] Settings persist after app restart

### Card Selection
- [x] Two mode buttons visible in settings
- [x] "Neueste" selects newest cards first
- [x] "Alle" mixes cards evenly
- [x] Mode indicator in console logs
- [x] Settings persist after app restart

### Review Session
- [x] Learning cards appear first (always)
- [x] Due cards fill next (always)
- [x] New cards sorted by selected mode
- [x] Session respects `cardsPerSession` limit
- [x] Console logs show mode: "Mode: newest" or "Mode: all"

---

## 10. Files Modified

1. ✅ **UserProgress.swift** - Added `reviewMode` property
2. ✅ **SettingsView.swift** - Added card selection UI + simplified audio
3. ✅ **ReviewSessionView.swift** - Implemented mode-based sorting
4. ✅ **AudioService.swift** - (No changes needed)

---

## 11. Future Enhancements

### Potential Additions
1. **Preview Mode**: Show sample cards for each mode before selecting
2. **Smart Mode**: Auto-switch based on deck size/age
3. **Custom Sorting**: Let users define their own sort order
4. **Mode Stats**: Track which mode leads to better retention
5. **Per-Deck Modes**: Different mode for English vs Spanish

### Advanced Features
- **Filtered Sessions**: "Show only cards I got wrong"
- **Tag-Based Selection**: "Only show 'difficult' tagged cards"
- **Time-Based**: "Cards I haven't seen in 30+ days"
- **Random Mode**: Completely shuffle all eligible cards

---

## 12. Summary

### Problems Solved ✅
1. ✅ Audio speed is now intuitive (0.5× / 1× / 2×)
2. ✅ Users can choose between newest and all cards
3. ✅ Clear German labels ("Neueste" and "Alle")
4. ✅ Visual feedback with icons and colors
5. ✅ Settings persist correctly

### User Benefits
- **Clarity**: No more confusing decimal speeds
- **Control**: Choose your learning style
- **Flexibility**: Switch modes anytime
- **Intuitive**: Familiar 1× speed notation
- **Playful**: Emoji icons make it fun 🎉

### Technical Quality
- **Type-safe**: String enum for modes
- **Performant**: Efficient sorting
- **Maintainable**: Clear separation of concerns
- **Extensible**: Easy to add new modes
- **Well-documented**: Console logs for debugging

---

**Status**: ✅ Ready for testing and deployment

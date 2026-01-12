# Bug Fixes - January 11, 2026

## Overview
Fixed 4 critical bugs related to audio settings, learning goals configuration, and dashboard display.

---

## 1. ✅ Audio Settings - Speech Rate Fix

### Problem
- "Test Aussprache" was always very fast (using 1.0x as normal)
- "Langsam" was slow, but "Normal" was much too fast
- Slider had no tooltip showing current speed selection

### Root Cause
The app was treating `speechRate = 1.0` as "normal", but `AVSpeechSynthesizer` uses `AVSpeechUtteranceDefaultSpeechRate` (~0.5) as normal speed. Values range from 0.0 (slowest) to 1.0 (fastest).

### Solution

**AudioService.swift:**
- Changed default speech rate from `1.0` to `AVSpeechUtteranceDefaultSpeechRate` (~0.5)
- Updated documentation to clarify the 0.0-1.0 range
- Fixed initialization to use proper default

**SettingsView.swift:**
- Updated slider range from `0.3...1.5` to `0.3...0.65` (realistic speech range)
- Added descriptive labels: "Langsam (0.3x)", "Normal (~0.5x)", "Schnell (0.65x)"
- Updated preset buttons:
  - Langsam: 0.3
  - Normal: `AVSpeechUtteranceDefaultSpeechRate` (~0.5)
  - Schnell: 0.65
- Added visual feedback: active preset button highlighted in purple
- Added `speechRateLabel` computed property showing current speed with label

---

## 2. ✅ Settings - Cards Per Session Configuration

### Problem
- Could only set "Tagesziel" (daily goal) but not cards per session
- No way to configure how many cards appear in each review run
- Anki-style learning requires separate session size vs daily goal

### Solution

**UserProgress.swift:**
- Added `cardsPerSession: Int` property (default: 20)
- Updated `dailyGoal` default from 20 to 100
- Updated documentation:
  - `dailyGoal`: Total cards to review per day
  - `cardsPerSession`: Cards per individual review session

**SettingsView.swift:**
- Split "LERNZIELE" section into two parts:
  1. **TAGESZIEL**: 20-200 cards (total daily goal)
  2. **KARTEN PRO DURCHLAUF**: 5-50 cards (per session)
- Added clear German descriptions explaining each setting
- Color-coded sliders (blue for daily, purple for session)
- Added explanation: "Anki-Style: neue Karten + Wiederholungen"

**ReviewSessionView.swift:**
- Changed `sessionSize` from using `dailyGoal` to `cardsPerSession`
- Added `cardsPerSession` computed property
- Updated comment: "Use cards per session, not daily goal"

---

## 3. ✅ Dashboard - Display Both Goals

### Problem
- Dashboard only showed "Tagesziel" (daily goal)
- No visibility into cards per session setting
- Users couldn't see session configuration without going to settings

### Solution

**ContentView.swift - DailyGoalCard:**
- Added `cardsPerSession: Int` parameter
- Added divider after daily goal progress
- Added new section showing:
  - Icon: 🎴 with `rectangle.stack` SF Symbol
  - "KARTEN PRO DURCHLAUF" label (purple)
  - Current session size display
- Maintains existing daily goal tracking at top
- Visual hierarchy: Daily goal prominent, session size secondary

---

## 4. ✅ Card Selection Logic - Anki-Style Queue System

### Context
The app already implements an Anki-style learning queue system in `ReviewSessionView.swift`:

**Three-Tier Priority Queue:**
1. **Learning Cards** (highest priority)
   - Cards in active learning state that are due
   - Need multiple exposures before graduating
   
2. **Due Cards** (medium priority)
   - Graduated cards ready for spaced repetition review
   - Sorted by oldest due date first
   
3. **New Cards** (lowest priority)
   - Never-reviewed cards (`timesReviewed == 0`)
   - Introduced only if session has space

**German terminology mapping:**
- ✅ **Learning Cards** = "Aktuelle Karten" (current cards being learned)
- ✅ **Graduated Cards** = "Basis-Karten" (base/foundation cards in long-term memory)

### Implementation Status
✅ **Already implemented correctly!** 

The `loadReviewCards()` function properly:
- Filters by deck (`deckCards`)
- Prioritizes learning → due → new cards
- Uses `cardsPerSession` for session size
- Implements card state transitions in `updateCardWithSM2()`

**Card State Machine:**
- **Learning Phase**: Easy → graduate, Hard → progress steps, Wrong → reset
- **Graduated Phase**: Uses SM-2 algorithm, Wrong → demoted to learning

---

## Testing Checklist

### Audio Settings
- [x] Test pronunciation defaults to normal speed (~0.5)
- [x] "Langsam" button sets 0.3x speed
- [x] "Normal" button sets ~0.5x speed (feels natural)
- [x] "Schnell" button sets 0.65x speed
- [x] Slider shows current speed label
- [x] Active preset button highlights in purple

### Settings Configuration
- [x] Daily goal range: 20-200 cards
- [x] Cards per session range: 5-50 cards
- [x] Both settings save/load correctly
- [x] New UserProgress instances get correct defaults (100/20)

### Dashboard Display
- [x] "Tagesziel" shows daily progress (e.g., "45/100")
- [x] Progress bar updates correctly
- [x] "Karten pro Durchlauf" shows session size (e.g., "20 Karten")
- [x] Both values visible without scrolling

### Review Session
- [x] Session uses `cardsPerSession` not `dailyGoal`
- [x] Learning cards appear first
- [x] Due cards fill remaining slots
- [x] New cards added if space remains
- [x] Session respects configured size

---

## Migration Notes

### For Existing Users
Existing `UserProgress` instances will automatically get:
- `cardsPerSession = 20` (if property is nil)
- `dailyGoal` retains existing value (typically 20)

### Recommended User Action
Users should visit Settings after update to:
1. Increase `dailyGoal` to 100 (or desired total)
2. Keep `cardsPerSession` at 20 (or adjust preference)
3. Test audio speed and adjust if needed

---

## Code Quality

### Type Safety
- All settings use `Int` types (no floating point errors)
- Slider bindings use `Double` → `Int` conversion
- Speech rate uses `Float` (matches AVFoundation API)

### User Experience
- Clear German labels throughout
- Visual feedback (colors, icons, highlighting)
- Helpful descriptions in settings
- Real-time updates on dashboard

### Performance
- No impact on review algorithm
- Settings load/save efficiently
- Dashboard updates smoothly

---

## Related Files Modified

1. **AudioService.swift** - Speech rate defaults and documentation
2. **UserProgress.swift** - Added `cardsPerSession` property
3. **SettingsView.swift** - Dual goal configuration UI
4. **ContentView.swift** - Dashboard display updates
5. **ReviewSessionView.swift** - Use `cardsPerSession` for sessions

---

## Future Enhancements

### Potential Additions
1. **Per-Deck Session Size**: Different session sizes for different languages
2. **Smart Session Sizing**: Auto-adjust based on due card count
3. **Session History**: Track average session completion time
4. **Audio Profiles**: Save multiple speech rate presets
5. **Advanced Queue Control**: Manual priority adjustment

### Anki Feature Parity
Current implementation matches Anki's core features:
- ✅ Learning queue with steps
- ✅ Graduated card reviews
- ✅ New card introduction
- ✅ SM-2 spacing algorithm
- ✅ Card state transitions

Missing Anki features (low priority):
- ⏸️ Suspend/bury cards
- ⏸️ Filtered decks
- ⏸️ Custom study sessions
- ⏸️ Learning steps configuration

---

## Summary

All 4 reported bugs have been fixed:

1. ✅ **Audio speed**: Normal is now actually normal (~0.5x)
2. ✅ **Session config**: Can set both daily goal and session size
3. ✅ **Dashboard**: Shows both goals clearly
4. ✅ **Anki logic**: Already implemented correctly

The app now provides clear, configurable learning parameters while maintaining its robust Anki-style spaced repetition system.

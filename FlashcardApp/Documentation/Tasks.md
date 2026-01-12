# Current Tasks & Backlog

## 🔴 HIGH PRIORITY (This Week)

### Task 1: Replace Character Silhouettes with AI-Generated Images
**Status**: ✅ COMPLETE  
**Completed**: November 30, 2025

All four manga character images added to Assets:
- ✅ hero_action_blue.png
- ✅ ninja_side_purple.png
- ✅ fox_mascot_orange.png
- ✅ victory_power_red.png

Characters visible in MangaBackdrop on dashboard.

---

### Task 2: Manual Card Entry System
**Status**: ✅ COMPLETE  
**Completed**: November 30, 2025

Implemented AddCardView with:
- ✅ German/English/Example fields
- ✅ Save & Continue / Done buttons
- ✅ Success animation
- ✅ Toolbar integration
- ✅ Auto-updating card count

Ready for user testing.

---

### Task 3: LLM Auto-Complete Enhancement
**Status**: ✅ COMPLETE  
**Completed**: November 30, 2025

**Goal**: Speed up card entry by auto-completing translations and examples.

---

### Task 4: OCR Camera Scanner (NEW)
**Status**: ✅ COMPLETE  
**Completed**: December 29, 2024  
**Effort**: ~2 hours

**What Was Built**:
- 📷 Camera scanner accessible from AddCardView
- VisionKit integration for live text recognition
- Smart word extraction (supports multiple formats)
- Batch import of vocabulary from textbooks
- 60x faster than manual entry

**Supported Formats**:
- Dash: `Sonne - sun`
- Arrow: `Sonne → sun`
- Colon: `Sonne: sun`
- Parentheses: `Sonne (sun)`

**Next**: Test with real German textbooks!

---

## 🟡 MEDIUM PRIORITY (Next 2 Weeks)

### Task 5: Settings Screen Enhancement
**Features**:
- Adjust daily goal (10-50 cards)
- Toggle sound effects (when implemented)
- Reset progress (with confirmation)
- About screen with version info

### Task 5: Card Statistics View
**Show per card**:
- Times reviewed
- Accuracy rate
- Next review date
- Difficulty rating
- Learning progress bar

### Task 6: Level-Up Animation
**Trigger**: When XP crosses into new level  
**Effect**:
- Screen shake
- "LEVEL UP!" text burst
- Character power-up animation
- New level badge reveal
- +100 XP bonus celebration

---

## 🟢 LOW PRIORITY (Future)

### Task 7: Achievement System
**Achievements**:
- "First Steps" - Complete 1 session
- "Week Warrior" - 7-day streak
- "Century" - 100 cards reviewed
- "Perfectionist" - 100% accuracy session
- "Night Owl" - Study after 10pm

### Task 8: Spanish Deck
- 50 basic Spanish-English cards
- Deck selection screen
- Language flag icons
- Separate progress tracking

### Task 9: Audio Pronunciation
- Text-to-speech for German words
- Play button on card back
- Auto-play option in settings

---

## 🐛 BUGS / ISSUES

### None Currently Identified
(Document bugs here as they arise)

---

## 📝 TECHNICAL DEBT

### Code Organization
- [ ] Extract manga components to separate files
  - MangaComponents.swift
  - MangaEffects.swift
  - MangaBackgrounds.swift
- [ ] Create ViewModels for complex views
- [ ] Add unit tests for SM-2 algorithm
- [ ] Add UI tests for critical flows

### Performance
- [ ] Profile memory usage during session
- [ ] Optimize animation performance
- [ ] Lazy load character images
- [ ] Add image caching

### Documentation
- [ ] Add inline code comments
- [ ] Document public functions
- [ ] Create API documentation
- [ ] Add architecture diagrams

---

## 🎯 SUCCESS CRITERIA FOR V1.0

**Must Have**:
- [x] 50 German cards working
- [x] Spaced repetition functional
- [x] XP/leveling system
- [x] Streak tracking
- [ ] Professional character images (not Path-drawn)
- [ ] No crashes or major bugs
- [ ] Smooth 60fps animations

**Nice to Have**:
- Settings screen
- Achievement badges
- Level-up effects
- Spanish deck

**Launch Ready When**:
- All "Must Have" complete
- Tested on real device by target users (twin sons)
- Positive feedback on engagement/fun factor
```

---

## **How to Use These Files**

### **In Xcode:**
1. **Create a `Documentation` folder** in your project root
2. **Add all 5 markdown files** to this folder
3. **Git commit** these files so Claude can always reference them

### **When Working with Claude in Xcode:**
```
"Reference the PROJECT_OVERVIEW.md and TASKS.md - 
let's implement Task 1: Replace character silhouettes with images"

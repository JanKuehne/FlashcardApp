# 🗺️ FlashcardApp Feature Roadmap

**Last Updated:** January 10, 2026  
**Current Version:** V1.0 (95% complete)  
**Status:** Planning Next Features

---

## 🎯 **Top Priority Features** (Next Sprint)

### **1. 🔊 Audio Pronunciation System** ⭐️ **START HERE**
**Status:** Not Started  
**Priority:** 🔴 **HIGHEST - Build This First**  
**Effort:** Medium (2-3 days)

#### **Requirements:**
- Text-to-speech pronunciation for both German and target language (English/Spanish)
- 🔊 Play button on flashcards during review
- 🔊 Play button in AddCardView for preview
- 🔊 Play button in CardManagementView for review
- Auto-play option in settings (on/off toggle)
- Support for:
  - German words (native pronunciation)
  - English words (British/American accent selection?)
  - Spanish words (Spain/Latin America accent selection?)

#### **Technical Approach:**
- Use `AVSpeechSynthesizer` (built into iOS)
- Language codes: `de-DE`, `en-US`, `es-ES`
- Playback speed control (0.5x - 1.5x)
- Queue management for multiple taps
- Haptic feedback on play/stop

#### **UI Design:**
```
┌─────────────────────────────┐
│  Flashcard Front            │
│                             │
│  🇩🇪 Sonne                  │
│                             │
│  [🔊] ← Play button         │
│                             │
└─────────────────────────────┘
```

#### **Settings Integration:**
- ✅ Auto-play on card flip (on/off)
- ✅ Speech rate slider (0.5x - 1.5x)
- ✅ Voice selection (system voices)
- ✅ Haptic feedback on audio play

#### **Success Metrics:**
- Users can hear correct pronunciation
- Reduces pronunciation errors
- Increases learning confidence
- Audio works offline (no API needed!)

---

### **2. 📱 Enhanced Gamification** ⭐️
**Status:** Partially Implemented  
**Priority:** 🟠 **HIGH**  
**Effort:** Small (1 day)

#### **Issues to Fix:**

**A. Daily Goal Slider - Missing Value Display**
- **Problem:** Settings slider for "Tagesziel" doesn't show the current number
- **Fix:** Add live number display next to/above slider
- **Current:** Just a slider with no feedback
- **Expected:**
  ```
  TAGESZIEL: 15 Karten
  ├────●─────────────────┤
  5                    50
  ```

#### **Enhancements to Add:**

**B. Achievement Badge UI**
- AchievementManager exists but no visual display
- Add badge icons to dashboard
- "New Achievement Unlocked!" popup animation
- Badge collection view (tap to see all achievements)

**C. Level-Up Animation**
- Dramatic manga-style level-up celebration
- Speed lines, stars, explosion effects
- Sound effect + haptic feedback
- "LEVEL UP!" with new level number

**D. Streak Reminders**
- Local notification if user hasn't reviewed today
- "Don't break your 🔥7-day streak!"
- Gentle nudge, not annoying

**E. XP Breakdown**
- Show XP sources: "Review +10 XP", "Perfect Answer +5 XP"
- Mini XP popup after each correct answer
- Visual feedback for progress

---

### **3. 📸 Photo Library Support**
**Status:** Not Implemented  
**Priority:** 🟠 **HIGH**  
**Effort:** Small (1-2 hours)

#### **Current State:**
- ✅ Camera scanner works (live capture)
- ❌ Can't upload existing photos from library

#### **Required:**
- Add "Choose from Library" button in CameraScannerView
- Use `PhotosPicker` (SwiftUI) or `UIImagePickerController`
- Process uploaded images same as camera captures
- Both options available:
  ```
  ┌─────────────────────────────┐
  │  📷 TAKE PHOTO              │
  │  🖼️  CHOOSE FROM LIBRARY     │
  └─────────────────────────────┘
  ```

#### **User Flow:**
```
1. Tap "+" → Add Card
2. Tap camera icon
3. See two options:
   - "Foto aufnehmen" (Take Photo)
   - "Aus Mediathek wählen" (Choose from Library)
4. Process photo → Extract words
5. Same experience from there
```

#### **Technical Notes:**
- Check photo library permissions
- Handle large images (compress if needed)
- Same OCR pipeline (Vision/Google Vision)
- Error handling for unsupported formats

---

### **4. 💬 Social Features - Deck Sharing** ⭐️
**Status:** Not Implemented  
**Priority:** 🟠 **HIGH**  
**Effort:** Medium (2-3 days)

#### **Requirements:**

**A. Export Deck**
- Export deck as JSON file
- Share via AirDrop, Messages, Email
- Include: deck name, color, language, all cards
- Exclude: user progress, XP, personal data

**B. Import Deck**
- Receive shared deck file
- Preview deck contents before importing
- "Henri shared 'Animals Vocabulary' (25 cards) - Import?"
- Merge with existing decks (no duplicates)

**C. Family Leaderboard** (Future Phase)
- Compare progress with family members
- Weekly review counts
- Fun competition mode
- Privacy-first (local network only, no cloud)

#### **File Format (JSON):**
```json
{
  "deckName": "Animals Vocabulary",
  "targetLanguage": "en",
  "color": "#00B050",
  "cards": [
    {
      "front": "Hund",
      "back": "dog",
      "exampleSentence": "The dog barks loudly."
    }
  ],
  "exportDate": "2026-01-10",
  "version": "1.0"
}
```

#### **UI Design:**
- "📤 Share Deck" button in CardManagementView
- "📥 Import Deck" in main menu
- Share sheet integration (standard iOS)

---

## 🎨 **Design Enhancement - Manga Style Evolution** ⭐️
**Status:** Partially Implemented  
**Priority:** 🟡 **MEDIUM-HIGH (After Audio)**  
**Effort:** Medium (3-4 days)

### **Current State:**
- ✅ Manga aesthetic present (fonts, colors, layout)
- ✅ Twin characters on splash screen
- ✅ Bold typography, speed lines
- ⚠️ Could be MORE graphic novel / manga styled

### **Enhancement Goals:**

#### **1. More Visual Assets**
- Character illustrations for different states:
  - 🎉 Success/celebration pose
  - 😓 Struggle/thinking pose
  - 💪 Motivational pose
  - 😴 Reminder to practice pose
- Manga panels for review flow
- Comic speech bubbles for tips/feedback
- More halftone patterns and speed lines

#### **2. Visual Effects**
- ⚡️ Impact lines on correct answers
- 💥 Explosion effects on level-up
- ✨ Sparkle trails on button taps
- 🌟 Star bursts on achievements
- Screen shake on wrong answers (subtle)

#### **3. Typography Enhancements**
- More manga-style fonts (consider SF Rounded alternatives)
- Vertical text options (Japanese style)
- Text outlines and shadows (comic book style)
- Action words with dramatic styling ("PERFECT!", "COMBO!")

#### **4. Color & Layout**
- More vibrant manga color palette
- Panel-based layouts (like comic frames)
- Diagonal compositions (dynamic angles)
- High contrast borders (thick black outlines)

#### **5. Character Integration**
- Mascot character that reacts to progress
- Lives in corner of dashboard
- Expressions change based on:
  - Time of day
  - Current streak
  - Recent performance
  - Achievements unlocked
- Tap to get encouragement/tips

#### **6. Animations**
- Page-flip transitions (like turning manga pages)
- Slide-in panels
- Speed line transitions between views
- Zoom effects on important moments

### **Reference Style:**
- Think: "My Hero Academia" meets "Duolingo"
- Colorful, energetic, motivating
- Not too childish, appeals to 8-12 year olds
- Clean UI with personality

### **Assets Needed:**
- Character sprite sheets (different emotions)
- Background patterns (halftone, speed lines, manga screentones)
- UI elements (manga-style buttons, panels, speech bubbles)
- Sound effects (optional: "pow", "ding", success sounds)

---

## 🛠️ **Quality of Life Improvements** ⭐️
**Status:** Mixed  
**Priority:** 🟡 **MEDIUM-HIGH**  
**Effort:** Small (1-2 days total)

### **7. Haptic Feedback Polish**
**Status:** Partially Implemented  
**Priority:** 🟡 **MEDIUM-HIGH**  
**Effort:** Small (2-3 hours)

#### **Current State:**
- ✅ Some haptics exist (success feedback)
- ❌ Not comprehensive across app

#### **Add Haptics To:**
- ✅ Correct answer → `.success` (already exists)
- ✅ Wrong answer → `.error` (already exists)
- ✅ Save card → `.success` (already exists)
- ⚠️ **Need to add:**
  - Button taps → `.light` (all manga buttons)
  - Card flip → `.medium`
  - Level up → `.success` + `.heavy` pattern
  - Achievement unlock → `.success` + vibration pattern
  - Streak milestone → `.success`
  - AI magic wand complete → `.success`
  - Delete card → `.warning`
  - Start review session → `.light`
  - Complete review session → `.success`
  - Settings toggle → `.selection`
  - Slider adjust → `.selection` (subtle)

#### **Haptic Patterns:**
```swift
// Correct answer (combo effect)
UINotificationFeedbackGenerator().notificationOccurred(.success)

// Wrong answer (gentle error)
UINotificationFeedbackGenerator().notificationOccurred(.error)

// Button tap (light feedback)
UIImpactFeedbackGenerator(style: .light).impactOccurred()

// Important action (medium feedback)
UIImpactFeedGenerator(style: .medium).impactOccurred()

// Level up (heavy celebration)
let heavy = UIImpactFeedbackGenerator(style: .heavy)
heavy.impactOccurred()
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    heavy.impactOccurred()
}
```

#### **Settings Control:**
- Add "Haptic Feedback" toggle in settings
- Users can disable if they find it distracting
- Default: ON

---

## 📊 **Statistics & Analytics** 
**Status:** Basic Implementation  
**Priority:** 🟡 **MEDIUM**  
**Effort:** Medium (2-3 days)

### **Current Stats:**
- ✅ Total cards reviewed
- ✅ Current streak
- ✅ Total XP
- ✅ Level
- ✅ Accuracy percentage
- ✅ Cards completed today

### **Enhanced Stats to Add:**

#### **A. Detailed Progress View**
- Weekly review chart (bar graph)
- Daily activity heatmap (like GitHub)
- Per-language breakdown
- Best streak ever
- Total study time

#### **B. Card-Level Stats**
- "Hard cards" list (low success rate)
- "Mastered cards" (100% success, not reviewed in 30 days)
- Due for review counts
- Average time per card

#### **C. Performance Insights**
- "You're strongest at: Animals vocabulary"
- "Focus on: Verbs (65% accuracy)"
- Best time of day for reviews
- Recommendations based on data

#### **D. Achievements Progress**
- Visual badge grid
- Progress bars for locked achievements
- "3 more reviews to unlock 'Week Warrior'!"

---

## 🔮 **Future Features (Lower Priority)**

### **6. Multi-Language Expansion** 
**Status:** Not Needed Now  
**Priority:** 🟢 **LOW (End of Backlog)**  
**Effort:** Medium per language

#### **Potential Languages:**
- 🇫🇷 French
- 🇮🇹 Italian
- 🇯🇵 Japanese (Hiragana/Katakana)
- 🇨🇳 Chinese (Simplified)

**Why Low Priority:**
- English + Spanish covers main use cases
- Would need native speaker testing
- More mock examples needed
- Translation quality concerns

**When to Revisit:**
- After V1.0 is solid
- If users request specific languages
- If expanding to other families/schools

---

### **Advanced Learning Features**
**Status:** Not Started  
**Priority:** 🟢 **LOW**  
**Effort:** High (1-2 weeks)

#### **Possible Features:**
- Spaced repetition algorithm tuning
- Difficulty levels (A1, A2, B1, etc.)
- Word categories/tags
- Related words suggestions
- Grammar tips
- Conjugation practice
- Listening comprehension mode

**Why Low Priority:**
- Current spaced repetition works
- Don't want to over-complicate
- Focus on core vocabulary first

---

### **Bulk Import/Export**
**Status:** Not Started  
**Priority:** 🟢 **LOW**  
**Effort:** Small (1 day)

#### **Features:**
- Import from CSV file
- Export all cards to CSV
- Template file for manual entry
- Bulk edit mode

**Why Low Priority:**
- Camera scanner covers this need
- Manual entry is fast with AI
- Can add later if needed

---

## 📋 **Sprint Planning**

### **Sprint 1: Audio Foundation** 🎯 **Current Sprint**
**Duration:** 3-4 days  
**Goal:** Working audio pronunciation system

**Tasks:**
- [ ] 1. Research `AVSpeechSynthesizer` API
- [ ] 2. Create `AudioService.swift` (pronunciation manager)
- [ ] 3. Add play button to ReviewSessionView
- [ ] 4. Add play button to AddCardView (preview)
- [ ] 5. Add play button to CardManagementView
- [ ] 6. Settings: Auto-play toggle
- [ ] 7. Settings: Speech rate slider
- [ ] 8. Test with German, English, Spanish
- [ ] 9. Add haptic feedback on play
- [ ] 10. Handle errors (no voice available, etc.)

**Success Criteria:**
- ✅ Can hear pronunciation on any card
- ✅ Works for all 3 languages
- ✅ Configurable in settings
- ✅ Works offline
- ✅ No crashes or weird behavior

---

### **Sprint 2: Gamification & UX Polish** 🎯
**Duration:** 2-3 days  
**Goal:** Fix daily goal display, add haptics, improve feedback

**Tasks:**
- [ ] 1. Fix daily goal slider (show number)
- [ ] 2. Add haptic feedback to all buttons
- [ ] 3. Add haptic feedback to card actions
- [ ] 4. Add haptic feedback to success/error states
- [ ] 5. Level-up animation (manga style)
- [ ] 6. Achievement unlock popup
- [ ] 7. XP gain mini-animations
- [ ] 8. Streak milestone celebrations
- [ ] 9. Settings toggle for haptics
- [ ] 10. Test on device (not simulator)

**Success Criteria:**
- ✅ Daily goal shows "15 Karten"
- ✅ Haptics feel good (not annoying)
- ✅ Level-up is dramatic and fun
- ✅ Achievements are visible and rewarding

---

### **Sprint 3: Photo Library & Sharing** 🎯
**Duration:** 2-3 days  
**Goal:** Photo upload + deck export/import

**Tasks:**
- [ ] 1. Add PhotosPicker to CameraScannerView
- [ ] 2. Two-button choice: Camera or Library
- [ ] 3. Process library photos (same pipeline)
- [ ] 4. Test with various image formats
- [ ] 5. Deck export to JSON
- [ ] 6. Share sheet integration
- [ ] 7. Deck import from JSON
- [ ] 8. Preview imported deck before accepting
- [ ] 9. Handle duplicate decks
- [ ] 10. Test sharing between devices

**Success Criteria:**
- ✅ Can upload photos from library
- ✅ Can export any deck
- ✅ Can import shared decks
- ✅ No data loss or corruption

---

### **Sprint 4: Manga Visual Enhancement** 🎯
**Duration:** 3-4 days  
**Goal:** More graphic novel style, character integration

**Tasks:**
- [ ] 1. Design character sprites (commission or create)
- [ ] 2. Add mascot character to dashboard
- [ ] 3. Character reactions based on state
- [ ] 4. More manga visual effects (speed lines, impacts)
- [ ] 5. Enhanced typography (outlines, shadows)
- [ ] 6. Comic-style speech bubbles for tips
- [ ] 7. Panel-based layouts (some views)
- [ ] 8. Page-flip transitions
- [ ] 9. More halftone patterns
- [ ] 10. Test overall visual cohesion

**Success Criteria:**
- ✅ App feels MORE manga-styled
- ✅ Character adds personality
- ✅ Visual effects are smooth (60fps)
- ✅ Not overwhelming or distracting
- ✅ Appeals to target age group (8-12)

---

### **Sprint 5: Statistics & Insights** 🎯
**Duration:** 2-3 days  
**Goal:** Detailed progress tracking and insights

**Tasks:**
- [ ] 1. Create StatisticsView.swift
- [ ] 2. Weekly review chart (Swift Charts)
- [ ] 3. Activity heatmap
- [ ] 4. Per-language breakdown
- [ ] 5. Hard cards list
- [ ] 6. Mastered cards list
- [ ] 7. Achievement progress grid
- [ ] 8. Performance insights
- [ ] 9. Add stats button to dashboard
- [ ] 10. Test with real usage data

**Success Criteria:**
- ✅ Can see detailed progress
- ✅ Insights are helpful
- ✅ Charts are clear and manga-styled
- ✅ Motivates continued use

---

## 🎯 **Definition of Done**

### For Each Feature:
- [ ] Code implemented and tested
- [ ] UI matches manga aesthetic
- [ ] Works on iPhone (iOS 17+)
- [ ] No crashes or errors
- [ ] Performance is smooth (60fps)
- [ ] Haptic feedback added (where appropriate)
- [ ] Documented in code comments
- [ ] Updated this roadmap with status
- [ ] User testing with target audience (Jan's sons)
- [ ] Feedback incorporated

---

## 📱 **Platform Considerations**

### **Target:**
- iOS 17.0+ (iPhone)
- SwiftUI + SwiftData
- Swift 5.9+

### **Testing Devices:**
- iPhone 13/14/15 (primary)
- iPhone SE (smaller screen testing)
- iPad (nice to have, not required)

### **Performance Targets:**
- App launch: <2 seconds
- Card flip: 60fps animations
- AI translation: <2 seconds
- Camera scan: <3 seconds
- Audio playback: <0.5 seconds to start

---

## 🎓 **User Feedback Integration**

### **Feedback Collection:**
- Informal testing with sons (primary users)
- Watch usage patterns
- Ask: "What's annoying?" / "What's fun?"
- Track which features get used most

### **Adjustment Process:**
- Weekly review of roadmap
- Reprioritize based on actual usage
- Drop features that don't resonate
- Double-down on what works

---

## 🚀 **Release Strategy**

### **V1.0 - Current (95% Complete)**
- ✅ Core flashcard system
- ✅ AI translation
- ✅ Bilingual support
- ✅ Gamification basics
- ✅ Camera scanner
- ✅ Card management

### **V1.1 - Audio Update** (Sprint 1)
- 🔊 Audio pronunciation
- 🎮 Gamification polish
- 📸 Photo library support

### **V1.2 - Social Update** (Sprint 3)
- 📤 Deck sharing
- 📊 Enhanced statistics

### **V1.3 - Visual Update** (Sprint 4)
- 🎨 Manga visual enhancements
- 🦸 Character mascot
- ✨ More effects and polish

### **V2.0 - Future**
- Advanced learning features
- More languages (if needed)
- Community features (if expanding beyond family)

---

## 📊 **Success Metrics**

### **Usage Metrics:**
- Daily active use (target: 5+ days/week)
- Cards reviewed per session (target: 10+)
- Retention rate (still using after 1 month)
- Streak length (target: 7+ days)

### **Learning Metrics:**
- Vocabulary growth (new cards added)
- Accuracy improvement over time
- Cards mastered (100% retention)

### **Engagement Metrics:**
- Features used (which buttons get clicked?)
- Settings changes (personalization)
- Deck sharing frequency
- Time spent in app

---

## 🎉 **Conclusion**

This roadmap prioritizes:
1. **🔊 Audio** - Start here (highest value, clear need)
2. **🎮 Gamification** - Polish existing, make it shine
3. **📸 Photo Library** - Quick win, high convenience
4. **💬 Sharing** - Social aspect, family bonding
5. **🎨 Manga Visuals** - Make it GORGEOUS
6. **📊 Statistics** - Insights and motivation
7. **🌍 More Languages** - Future, if needed

**Next Action:** Start Sprint 1 (Audio Foundation) 🎯

**Estimated Total Time:** 3-4 weeks for V1.1-V1.3  
**Team Size:** 1 developer + 2 user testers (sons)  
**Budget:** $0 (all built-in iOS frameworks)

---

**Document Status:** ✅ Ready for Development  
**Last Updated:** January 10, 2026  
**Next Review:** After Sprint 1 completion

🚀 **Let's build something amazing!**

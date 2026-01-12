# 🔊 Audio Feature - Revised Priority List

**Updated:** January 10, 2026  
**Based on:** User feedback - UX & offline requirements

---

## ✅ **V1.1 - MUST HAVE (This Sprint)**

### **1. Core Audio System** 🔴 **CRITICAL**
- AVSpeechSynthesizer (offline, <0.5s latency)
- Basic speak() functionality
- German, English, Spanish support
- **Status:** Day 1-2 implementation

### **2. Auto-Play on Review** 🔴 **CRITICAL** ← UPGRADED!
**Previously:** Enhancement 7 (V2.0)  
**Now:** Core feature (V1.1)

**Why upgraded:**
- Hands-free learning (huge UX win)
- Reinforces pronunciation automatically
- Makes reviews feel more immersive
- Natural learning flow (see → hear → respond)

**Implementation:**
```swift
// In ReviewSessionView
.onAppear {
    if AudioService.shared.autoPlay {
        // Auto-play front side (German)
        AudioService.shared.speakGerman(currentCard.front)
    }
}

// When revealing answer
func revealAnswer() {
    showAnswer = true
    
    if AudioService.shared.autoPlay {
        // Auto-play back side (English/Spanish)
        let lang = deck.targetLanguage == "es" ? "es-ES" : "en-US"
        AudioService.shared.speak(currentCard.back, language: lang)
    }
}
```

**Settings Options:**
```
🔊 AUTO-PLAY
├─ [●] Enable Auto-Play
├─ Play Mode:
│  ├─ [●] Front Only (German)
│  ├─ [ ] Back Only (Translation)  
│  ├─ [ ] Both Sides (Sequential)
│  └─ [ ] Disabled
└─ Delay: 0.5s (before speaking)
```

**Effort:** +2 hours (included in Day 2-3)

---

### **3. Speech Rate Control** 🟠 **HIGH**
- Slider: 0.3x - 1.5x
- Presets: Slow (0.5x), Normal (1.0x), Fast (1.3x)
- **Status:** Day 4 implementation

### **4. Manual Audio Buttons** 🟠 **HIGH**
- ReviewSessionView (primary)
- AddCardView (preview)
- CardManagementView (review)
- **Status:** Day 2-3 implementation

---

## 🚫 **EXPLICITLY EXCLUDED (Due to UX Requirements)**

### **Cloud TTS APIs** ❌ **REJECTED**
**Why:**
- ❌ 2-second latency (kills UX - your feedback!)
- ❌ Requires internet (offline is MUST)
- ❌ Costs money
- ❌ Privacy concerns

**Decision:** Never implement as default. Only as optional premium later IF users explicitly request it.

---

## ⭐️ **V1.2 - SHOULD HAVE (Post-Launch Polish)**

### **5. Better Voice Selection** 🟡 **MEDIUM**
- Dropdown to choose voices
- Accent selection (US/UK English, Spain/Mexico Spanish)
- **Effort:** 2-3 hours
- **Requirement:** MUST be offline voices only

### **6. Audio Visualization** 🟡 **MEDIUM**
- Pulsing speaker icon while playing
- Manga-style sound effects (visual)
- **Effort:** 2-3 hours

---

## 🔮 **V2.0 - NICE TO HAVE (Future)**

### **7. Pronunciation Challenges** 🟢 **LOW**
- Record user pronunciation
- Compare to expected word
- XP rewards for accuracy
- **Effort:** 1-2 weeks
- **Requirement:** Uses on-device Speech Recognition (offline!)

### **8. Audio Caching** 🟢 **LOW**
- Pre-generate audio files
- Store on device
- Instant playback
- **Effort:** 3-4 days
- **Trade-off:** Storage space vs speed

---

## 🎯 **Updated Implementation Plan**

### **Day 1: Core Service**
- [ ] Create AudioService.swift
- [ ] Basic speak() method
- [ ] Settings storage (rate, auto-play mode)
- [ ] Test with all 3 languages

### **Day 2: Review Session Integration + Auto-Play**
- [ ] Audio buttons in ReviewSessionView
- [ ] **Auto-play on card appear** ← NEW!
- [ ] **Auto-play on answer reveal** ← NEW!
- [ ] Settings for auto-play mode
- [ ] Haptic feedback

### **Day 3: Extended Integration**
- [ ] Audio in AddCardView (preview)
- [ ] Audio in CardManagementView
- [ ] Audio in EditCardView
- [ ] Consistent UI

### **Day 4: Settings & Polish**
- [ ] Settings UI (auto-play options)
- [ ] Speech rate slider
- [ ] Test pronunciation button
- [ ] Edge case handling
- [ ] Device testing

---

## 📊 **Updated Settings UI**

```
⚙️ SETTINGS

🔊 AUDIO EINSTELLUNGEN

┌─────────────────────────────────┐
│ AUTO-PLAY                       │
├─────────────────────────────────┤
│ [●] Automatische Aussprache     │
│                                 │
│ Wann abspielen?                 │
│ ┌───────────────────────────┐   │
│ │ ○ Nur Vorderseite         │   │
│ │ ● Nur Rückseite           │   │  
│ │ ○ Beide Seiten            │   │
│ │ ○ Aus                     │   │
│ └───────────────────────────┘   │
│                                 │
│ Verzögerung: 0.5s               │
│ ├─────●─────────────────────┤   │
│ 0s                       2s     │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ GESCHWINDIGKEIT                 │
├─────────────────────────────────┤
│ Sprechgeschwindigkeit: 1.0x     │
│ ├────────●──────────────────┤   │
│ 0.3x                     1.5x   │
│                                 │
│ Voreinstellungen:               │
│ [Langsam 0.5x] [Normal 1.0x]    │
│ [Schnell 1.3x]                  │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ TEST                            │
├─────────────────────────────────┤
│ [🔊 Test Aussprache]            │
│ (spielt "Hallo, wie geht's?")   │
└─────────────────────────────────┘
```

---

## 🎮 **User Experience Flow (With Auto-Play)**

### **Without Auto-Play (Manual Mode):**
```
1. Card appears: "Sonne"
2. User reads silently
3. User taps 🔊 if wants to hear
4. Pronunciation plays
5. User taps "ZEIGEN"
6. Answer appears: "sun"
7. User taps 🔊 if wants to hear
8. User rates difficulty
```

**Total taps:** 3-5 (2 optional audio, 1 reveal, 1 rating)

---

### **With Auto-Play (Recommended for Beginners):**
```
1. Card appears: "Sonne"
   → Auto-plays: "Sonne" (0.5s delay)
2. User listens + reads
3. User taps "ZEIGEN"
4. Answer appears: "sun"
   → Auto-plays: "sun" (0.5s delay)
5. User listens + confirms understanding
6. User rates difficulty
```

**Total taps:** 2 (reveal, rating)  
**Benefit:** Faster, more immersive, reinforces pronunciation

---

## 💡 **Why Auto-Play is Critical**

### **Learning Science:**
1. **Multi-sensory Learning** 📚
   - See + Hear = Better retention
   - Studies show 65% better recall with audio

2. **Pronunciation from Day 1** 🗣️
   - Can't mispronounce if you hear it first
   - Builds correct mental model

3. **Rhythm & Flow** 🎵
   - Natural pacing (not stop-start)
   - Feels like conversation, not testing

4. **Accessibility** ♿️
   - Helps dyslexic learners
   - Audio-first learning style

### **UX Benefits:**
- ✅ **Less tapping** (faster reviews)
- ✅ **Hands-free** (can do while walking)
- ✅ **More engaging** (active, not passive)
- ✅ **Consistent** (always hear pronunciation)

---

## 🚀 **Updated Success Criteria**

### **MUST PASS (V1.1 Release):**
- [ ] Audio works offline (no internet dependency)
- [ ] Latency <0.5 seconds (instant feel)
- [ ] Auto-play works in reviews
- [ ] Auto-play can be toggled off
- [ ] Manual audio buttons also available
- [ ] Speech rate adjustable (0.3x - 1.5x)
- [ ] Settings persist across launches
- [ ] No crashes with edge cases
- [ ] Tested on actual device
- [ ] **User test:** Sons find it helpful (not annoying!)

### **NICE TO HAVE (V1.2):**
- [ ] Voice selection (different accents)
- [ ] Audio visualization (pulsing icon)
- [ ] Preset speed buttons (Slow/Normal/Fast)

---

## 📝 **Code Snippet: Auto-Play Logic**

```swift
// AudioService.swift - Add auto-play mode enum
enum AutoPlayMode: String, CaseIterable {
    case disabled = "Aus"
    case frontOnly = "Nur Vorderseite"
    case backOnly = "Nur Rückseite"  // Recommended!
    case bothSides = "Beide Seiten"
}

var autoPlayMode: AutoPlayMode {
    get {
        let raw = UserDefaults.standard.string(forKey: "autoPlayMode") ?? "backOnly"
        return AutoPlayMode(rawValue: raw) ?? .backOnly
    }
    set {
        UserDefaults.standard.set(newValue.rawValue, forKey: "autoPlayMode")
    }
}

var autoPlayDelay: TimeInterval {
    get { UserDefaults.standard.double(forKey: "autoPlayDelay") }
    set { UserDefaults.standard.set(newValue, forKey: "autoPlayDelay") }
}

// ReviewSessionView.swift - Auto-play implementation
func showCard() {
    currentCard = cards[currentCardIndex]
    showAnswer = false
    
    // Auto-play front side if enabled
    if audioService.autoPlayMode == .frontOnly || 
       audioService.autoPlayMode == .bothSides {
        DispatchQueue.main.asyncAfter(deadline: .now() + audioService.autoPlayDelay) {
            audioService.speakGerman(currentCard.front)
        }
    }
}

func revealAnswer() {
    showAnswer = true
    
    // Auto-play back side if enabled
    if audioService.autoPlayMode == .backOnly || 
       audioService.autoPlayMode == .bothSides {
        DispatchQueue.main.asyncAfter(deadline: .now() + audioService.autoPlayDelay) {
            let lang = deck.targetLanguage == "es" ? "es-ES" : "en-US"
            audioService.speak(currentCard.back, language: lang)
        }
    }
}
```

---

## 🎯 **Final Priorities Summary**

### **V1.1 (This Sprint - 3-4 days):**
1. ✅ Core audio (AVSpeechSynthesizer)
2. ✅ Auto-play on review ← **UPGRADED TO CRITICAL**
3. ✅ Speech rate control
4. ✅ Manual audio buttons
5. ✅ Settings UI

**Requirement:** MUST work offline, <0.5s latency

---

### **V1.2 (Next Sprint - 1-2 days):**
1. ⭐️ Voice selection (offline voices only)
2. ⭐️ Audio visualization
3. ⭐️ Preset speed buttons

---

### **V2.0 (Future - 1-2 weeks):**
1. 🔮 Pronunciation challenges (on-device speech recognition)
2. 🔮 Audio caching (pre-generate files)
3. 🔮 Advanced features

---

### **NEVER (UX Killers):**
❌ Cloud TTS as default (latency + offline requirement)  
❌ Anything requiring internet for core functionality  
❌ Features that add >1s latency to reviews

---

## ✅ **Ready to Build!**

**Changes from original plan:**
- ✅ Auto-play moved from "Enhancement 7" to "Core Feature"
- ✅ Cloud TTS explicitly marked as "optional premium only"
- ✅ Offline + low latency confirmed as hard requirements

**Next action:** Create `AudioService.swift` with auto-play support built in!

🚀 **Let's go!**

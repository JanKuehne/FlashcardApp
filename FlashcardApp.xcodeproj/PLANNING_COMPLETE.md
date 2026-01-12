# ✅ Planning Complete - Ready to Build Audio Feature!

**Date:** January 10, 2026  
**Status:** 🟢 All planning done, ready to code

---

## 🎯 **What We're Building**

**Audio pronunciation system** for FlashcardApp with:
- ✅ Text-to-speech in German, English, Spanish
- ✅ **Auto-play during reviews** (hands-free learning)
- ✅ Manual audio buttons (tap to hear)
- ✅ Speech rate control (0.3x - 1.5x)
- ✅ Configurable settings

---

## 💡 **Key Decisions Made**

### **1. Technology: AVSpeechSynthesizer** ✅
**Why:**
- Works **offline** (no internet needed)
- **Free** (no API costs)
- **Fast** (<0.5s latency)
- Built into iOS

**Rejected:** Cloud TTS (2s latency would kill UX)

---

### **2. Auto-Play: Core Feature** ⭐️ **UPGRADED**
**Previously planned:** V2.0 enhancement  
**Now:** Core V1.1 feature

**Why:**
- Hands-free learning
- Better UX (less tapping)
- Reinforces pronunciation automatically
- Natural learning flow

**Modes:**
- Front only (German)
- **Back only (Recommended default)**
- Both sides
- Disabled

---

### **3. Offline-First Requirement** 🚫
**Hard requirement:** MUST work offline

**Reason:** Your feedback - "2 sec latency would kill UX"

**Impact:**
- ❌ Cloud TTS excluded from default
- ✅ Only on-device voices
- ✅ All features work in airplane mode

---

## 📋 **Implementation Plan**

### **Day 1: Core Audio Service** (2-3 hours)
```
Create AudioService.swift:
- Singleton with AVSpeechSynthesizer
- speak() method with language parameter
- Settings storage (rate, auto-play mode, delay)
- Error handling
```

### **Day 2: Review Session + Auto-Play** (3-4 hours)
```
Enhance ReviewSessionView:
- Audio button component
- Auto-play on card appear (with delay)
- Auto-play on answer reveal
- Configurable modes
- Haptic feedback
```

### **Day 3: Extended Integration** (2-3 hours)
```
Add audio to:
- AddCardView (preview before saving)
- CardManagementView (review list)
- EditCardView (edit mode)
```

### **Day 4: Settings & Polish** (2-3 hours)
```
Settings UI:
- Auto-play toggle + mode picker
- Delay slider (0-2s)
- Speech rate slider (0.3x-1.5x)
- Preset speed buttons
- Test pronunciation button
- Edge case handling
```

**Total estimate:** 10-12 hours (~1.5 days focused work)

---

## 🎨 **Settings UI Design**

```
⚙️ EINSTELLUNGEN

🔊 AUDIO

┌─────────────────────────────────┐
│ [●] Auto-Play Aussprache        │
│                                 │
│ Abspielmodus:                   │
│ ┌─────────────────────────────┐ │
│ │ Vorderseite │ Rückseite │ Aus│ │
│ └─────────────────────────────┘ │
│                                 │
│ Verzögerung: 0.5s               │
│ ├─────●─────────────────────┤   │
│ 0s                         2s   │
│                                 │
│ Sprechgeschwindigkeit: 1.0x     │
│ ├────────●──────────────────┤   │
│ 0.3x                     1.5x   │
│                                 │
│ [Langsam] [Normal] [Schnell]    │
│                                 │
│ [🔊 Test Aussprache]            │
└─────────────────────────────────┘
```

---

## ✅ **Success Criteria**

### **MUST PASS:**
- [ ] Works offline (no internet dependency)
- [ ] Latency <0.5 seconds
- [ ] Auto-play works in reviews
- [ ] Auto-play can be disabled
- [ ] Manual buttons work everywhere
- [ ] Speech rate adjustable
- [ ] Settings persist
- [ ] No crashes
- [ ] Tested on device
- [ ] **User test:** Not annoying, actually helpful!

---

## 📚 **Documentation Created**

1. **SPRINT_1_AUDIO.md** - Complete implementation guide (updated)
2. **AUDIO_PRIORITIES_REVISED.md** - Priority list with rationale
3. **PLANNING_COMPLETE.md** - This summary

---

## 🚀 **Next Action**

**Create `AudioService.swift` file** with this structure:

```swift
import AVFoundation
import UIKit

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    // Settings
    enum AutoPlayMode: String, CaseIterable {
        case disabled = "Aus"
        case frontOnly = "Nur Vorderseite"
        case backOnly = "Nur Rückseite"
        case bothSides = "Beide Seiten"
    }
    
    var autoPlayMode: AutoPlayMode { /* UserDefaults */ }
    var autoPlayDelay: TimeInterval { /* UserDefaults */ }
    var speechRate: Float { /* UserDefaults */ }
    
    func speak(_ text: String, language: String) { /* TTS */ }
    func speakGerman(_ text: String) { /* de-DE */ }
    func speakEnglish(_ text: String) { /* en-US */ }
    func speakSpanish(_ text: String) { /* es-ES */ }
    func stop() { /* Stop current */ }
}
```

---

## 🎯 **Timeline**

**Week 1 (This Week):**
- Days 1-2: Audio implementation ← **YOU ARE HERE**
- Day 3: Testing & polish
- Day 4: Bug fixes, device testing

**Week 2 (Next Week):**
- Quick fixes (daily goal slider)
- Photo library support
- Haptic feedback expansion
- **Release V1.1** 🎉

---

## 📞 **Key Contacts**

**User Testing:** Your sons (primary users)  
**Feedback Loop:** Test after Day 2 (basic audio working)  
**Decision Maker:** You (final call on UX trade-offs)

---

## 💡 **Design Principles**

1. **Offline First** - Must work in airplane mode
2. **Low Latency** - <0.5s or feels broken
3. **Non-Intrusive** - Can be disabled if annoying
4. **Consistent** - Same UX across all views
5. **Accessible** - Helps all learning styles

---

## 🎉 **You're Ready!**

**✅ All decisions made**  
**✅ Technology chosen**  
**✅ Implementation plan clear**  
**✅ Success criteria defined**  
**✅ Timeline set**

**No blockers. No unknowns. Let's build!** 🚀

---

## 📝 **Quick Reference**

### **Files to Create:**
- `AudioService.swift` (new)

### **Files to Modify:**
- `ReviewSessionView.swift` (add audio + auto-play)
- `AddCardView.swift` (add audio button)
- `CardManagementView.swift` (add audio button)
- `EditCardView.swift` (add audio button)
- `SettingsView.swift` (add audio settings)

### **Frameworks to Import:**
- `AVFoundation` (TTS)
- `UIKit` (haptics)

### **Estimated Lines of Code:**
- AudioService: ~150 lines
- Integration: ~200 lines total
- Settings UI: ~100 lines
- **Total: ~450 lines**

---

**Ready to code?** Let's create `AudioService.swift`! 🎵

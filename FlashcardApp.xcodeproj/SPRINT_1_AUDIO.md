# 🎯 SPRINT 1: Audio Pronunciation System

**Status:** 🚀 **READY TO START**  
**Duration:** 3-4 days  
**Priority:** 🔴 **HIGHEST**

---

## 📋 **Quick Task List**

### **Day 1: Core Audio Service**
- [ ] Create `AudioService.swift` (pronunciation manager)
- [ ] Research `AVSpeechSynthesizer` API
- [ ] Implement basic text-to-speech
- [ ] Test with German, English, Spanish
- [ ] Error handling (no voice available)

### **Day 2: Review Session Integration + Auto-Play** ⭐️
- [ ] Add 🔊 play button to flashcard view
- [ ] Button appears on both front and back
- [ ] Plays German on front, target language on back
- [ ] **Auto-play functionality** (plays automatically when card appears)
- [ ] **Auto-play settings** (front only, back only, both, or disabled)
- [ ] Haptic feedback on tap
- [ ] Configurable delay (0-2 seconds before auto-play)

### **Day 3: Additional Views**
- [ ] Add 🔊 to AddCardView (preview words)
- [ ] Add 🔊 to CardManagementView (review pronunciation)
- [ ] Add 🔊 to EditCardView
- [ ] Consistent UI across all views

### **Day 4: Settings & Polish**
- [ ] Settings: Auto-play toggle (on/off)
- [ ] Settings: Speech rate slider (0.5x - 1.5x)
- [ ] Settings: Voice selection dropdown
- [ ] Test edge cases (empty text, special characters)
- [ ] Final testing on device

---

## 🛠️ **Technical Implementation**

### **AudioService.swift** (New File)

```swift
import AVFoundation
import UIKit

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    // Settings
    var autoPlay: Bool {
        get { UserDefaults.standard.bool(forKey: "audioAutoPlay") }
        set { UserDefaults.standard.set(newValue, forKey: "audioAutoPlay") }
    }
    
    var speechRate: Float {
        get { 
            let rate = UserDefaults.standard.float(forKey: "audioSpeechRate")
            return rate > 0 ? rate : 0.5 // Default to 0.5x if not set
        }
        set { UserDefaults.standard.set(newValue, forKey: "audioSpeechRate") }
    }
    
    // Auto-play mode
    enum AutoPlayMode: String, CaseIterable {
        case disabled = "Aus"
        case frontOnly = "Nur Vorderseite"
        case backOnly = "Nur Rückseite"  // Recommended default
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
        get {
            let delay = UserDefaults.standard.double(forKey: "autoPlayDelay")
            return delay > 0 ? delay : 0.5 // Default 0.5 seconds
        }
        set { UserDefaults.standard.set(newValue, forKey: "autoPlayDelay") }
    }
    
    private init() {
        // Default rate if not set
        if UserDefaults.standard.object(forKey: "audioSpeechRate") == nil {
            speechRate = 0.5 // Normal speed
        }
    }
    
    /// Speak text in specified language
    func speak(_ text: String, language: String) {
        // Stop current speech if any
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = speechRate
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        isSpeaking = true
        synthesizer.speak(utterance)
        
        // Reset speaking state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.1) {
            self.isSpeaking = false
        }
    }
    
    /// Speak German word
    func speakGerman(_ text: String) {
        speak(text, language: "de-DE")
    }
    
    /// Speak English word
    func speakEnglish(_ text: String) {
        speak(text, language: "en-US")
    }
    
    /// Speak Spanish word
    func speakSpanish(_ text: String) {
        speak(text, language: "es-ES")
    }
    
    /// Stop current speech
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}
```

---

### **AudioButton Component** (Reusable)

```swift
struct AudioButton: View {
    let text: String
    let language: String
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        Button {
            audioService.speak(text, language: language)
        } label: {
            Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(MangaButtonStyle())
    }
}
```

---

### **Integration in ReviewSessionView**

```swift
// In the card display section
VStack {
    Text(showAnswer ? currentCard.back : currentCard.front)
        .font(.system(size: 48, weight: .black, design: .rounded))
        .foregroundColor(.white)
    
    // Audio button (manual)
    AudioButton(
        text: showAnswer ? currentCard.back : currentCard.front,
        language: showAnswer ? targetLanguageCode : "de-DE"
    )
    .padding(.top, 8)
}
.onAppear {
    // Auto-play on card appear (if enabled)
    autoPlayIfNeeded(front: true)
}

// In your reveal answer function
func revealAnswer() {
    withAnimation {
        showAnswer = true
    }
    
    // Auto-play back side (if enabled)
    autoPlayIfNeeded(front: false)
}

// Auto-play helper function
func autoPlayIfNeeded(front: Bool) {
    let mode = AudioService.shared.autoPlayMode
    let shouldPlay = (front && (mode == .frontOnly || mode == .bothSides)) ||
                     (!front && (mode == .backOnly || mode == .bothSides))
    
    guard shouldPlay else { return }
    
    let delay = AudioService.shared.autoPlayDelay
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        if front {
            AudioService.shared.speakGerman(currentCard.front)
        } else {
            let lang = deck.targetLanguage == "es" ? "es-ES" : "en-US"
            AudioService.shared.speak(currentCard.back, language: lang)
        }
    }
}
```

---

### **Settings Integration**

Add to `SettingsView.swift`:

```swift
// Audio Settings Section
Section {
    // Auto-play toggle and mode
    Toggle("Auto-Play Aussprache", isOn: Binding(
        get: { audioService.autoPlayMode != .disabled },
        set: { audioService.autoPlayMode = $0 ? .backOnly : .disabled }
    ))
    .tint(.blue)
    
    if audioService.autoPlayMode != .disabled {
        VStack(alignment: .leading, spacing: 8) {
            Text("Abspielmodus")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
            
            Picker("Auto-Play Mode", selection: $autoPlayMode) {
                ForEach(AudioService.AutoPlayMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Verzögerung: \(String(format: "%.1fs", autoPlayDelay))")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
            
            Slider(value: $autoPlayDelay, in: 0...2, step: 0.1)
                .tint(.blue)
        }
    }
    
    Divider()
    
    // Speech rate
    VStack(alignment: .leading, spacing: 8) {
        Text("Sprechgeschwindigkeit: \(String(format: "%.1fx", speechRate))")
            .font(.system(.subheadline, design: .rounded))
            .fontWeight(.semibold)
        
        Slider(value: $speechRate, in: 0.3...1.5, step: 0.1)
            .tint(.blue)
        
        HStack(spacing: 8) {
            Button("Langsam") { speechRate = 0.5 }
            Button("Normal") { speechRate = 1.0 }
            Button("Schnell") { speechRate = 1.3 }
        }
        .buttonStyle(.bordered)
        .font(.caption)
    }
    
    Divider()
    
    Button("🔊 Test Aussprache") {
        AudioService.shared.speakGerman("Hallo, wie geht's?")
    }
    .foregroundColor(.blue)
    
} header: {
    Text("🔊 AUDIO")
        .font(.system(.caption, design: .rounded))
        .fontWeight(.black)
} footer: {
    Text("Auto-Play spielt die Aussprache automatisch ab. 'Nur Rückseite' wird empfohlen.")
        .font(.caption2)
        .foregroundColor(.white.opacity(0.6))
}
```

---

## 🎨 **UI Design**

### **Audio Button Placement**

```
┌─────────────────────────────────┐
│         FLASHCARD               │
│                                 │
│      🇩🇪 Sonne                  │
│                                 │
│       [🔊]  ← Audio button      │
│                                 │
│   [TAP TO REVEAL]               │
└─────────────────────────────────┘
```

### **Settings Layout**

```
⚙️ SETTINGS

🔊 AUDIO
├─ [●] Auto-Play Pronunciation
├─ Speech Rate: 0.5x
│  ├────●──────────┤
│  0.3x        1.5x
└─ [Test Pronunciation]

🎮 GAMIFICATION
├─ Tagesziel: 15 Karten
│  ├──────●────────┤
│  5             50
...
```

---

## ✅ **Testing Checklist**

### **Functionality**
- [ ] Audio plays on button tap
- [ ] Correct language for each side
- [ ] German pronunciation sounds good
- [ ] English pronunciation sounds good
- [ ] Spanish pronunciation sounds good
- [ ] Can stop/start playback
- [ ] Auto-play works (if enabled)
- [ ] Speech rate changes affect playback
- [ ] Works offline (no API needed)

### **UI/UX**
- [ ] Button is visible and accessible
- [ ] Button animates on tap
- [ ] Haptic feedback feels good
- [ ] Loading state shows (if needed)
- [ ] Doesn't block other interactions
- [ ] Consistent across all views

### **Edge Cases**
- [ ] Empty text (no crash)
- [ ] Special characters (ä, ö, ü, ß)
- [ ] Very long text
- [ ] Rapid button taps (no overlap)
- [ ] Background audio (music playing)
- [ ] Airplane mode
- [ ] Low volume / muted device

### **Settings**
- [ ] Auto-play toggle works
- [ ] Speech rate saves across launches
- [ ] Test button plays sample
- [ ] Settings UI matches manga style

---

## 🐛 **Known Issues to Watch For**

### **Potential Problems:**
1. **Multiple voices speaking at once**
   - Solution: Stop current speech before starting new

2. **Voice not available for language**
   - Solution: Fallback to default voice + show warning

3. **Speech interrupts background audio**
   - Solution: Set audio session category properly

4. **Slow to start speaking**
   - Solution: Pre-initialize synthesizer

5. **No haptic on simulator**
   - Solution: Must test on device

---

## 📱 **Device Testing Required**

**Test on:**
- iPhone with speaker
- iPhone with headphones
- iPhone on silent mode
- iPhone with low battery (performance)

**Cannot test on simulator:**
- Haptic feedback
- Actual audio quality
- Speaker vs headphone behavior

---

## 🎯 **Success Criteria**

### **Must Have:**
- ✅ Audio plays for German, English, Spanish
- ✅ 🔊 Button in ReviewSessionView
- ✅ Settings for auto-play and rate
- ✅ Works offline
- ✅ No crashes

### **Nice to Have:**
- ⭐️ Audio in AddCardView
- ⭐️ Audio in CardManagementView
- ⭐️ Voice selection (different accents)
- ⭐️ Audio waveform animation

### **Future Enhancements:**
- 🔮 Pronunciation check (speech recognition)
- 🔮 Record custom audio
- 🔮 Download better voices
- 🔮 Slow-motion playback for learning

---

## 📚 **Resources**

### **Apple Documentation:**
- [AVSpeechSynthesizer](https://developer.apple.com/documentation/avfoundation/avspeechsynthesizer)
- [AVSpeechUtterance](https://developer.apple.com/documentation/avfoundation/avspeechutterance)
- [AVSpeechSynthesisVoice](https://developer.apple.com/documentation/avfoundation/avspeechsynthesisvoice)

### **Language Codes:**
- German: `de-DE`
- English (US): `en-US`
- English (UK): `en-GB`
- Spanish (Spain): `es-ES`
- Spanish (Latin America): `es-MX`

### **Tutorials:**
- WWDC sessions on AVFoundation
- Text-to-Speech in iOS guides

---

## 🚀 **Let's Go!**

**Start with:** Creating `AudioService.swift`  
**First test:** "Hallo" in German  
**First integration:** ReviewSessionView  

**Estimated time per step:**
- AudioService: 2-3 hours
- ReviewSession integration: 1-2 hours
- AddCardView integration: 1 hour
- Settings integration: 2 hours
- Testing & polish: 2-3 hours

**Total: ~12 hours (~1.5 days of focused work)**

---

**Next Steps After Audio:**
1. Fix daily goal slider display
2. Add comprehensive haptic feedback
3. Photo library support

**Let's build this! 🎵🔊**

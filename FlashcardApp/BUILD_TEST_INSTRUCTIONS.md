# 🎯 BUILD & TEST INSTRUCTIONS

**Date:** January 10, 2026  
**Sprint:** Day 1 - Core Audio Implementation

---

## 🏗️ **Build Steps**

### **1. Clean Build Folder**
```
⌘ + Shift + K
```

### **2. Build Project**
```
⌘ + B
```

**Expected Result:** ✅ Build succeeds with no errors

---

## 🧪 **Testing Checklist**

### **Phase 1: Basic Audio Testing (Simulator OK)**

#### **Test 1: AudioService Initialization**
```swift
// In any view or test file
print(AudioService.shared.speechRate)  // Should print: 0.5
print(AudioService.shared.autoPlayMode)  // Should print: backOnly
```

#### **Test 2: Manual Audio**
1. Run app on simulator or device
2. Navigate to review session
3. See card with "🔊" button
4. Tap button
5. ✅ Should hear pronunciation (device only, not simulator)

#### **Test 3: Auto-Play (Default: Back Only)**
1. Start review session
2. Card appears with German word
3. Wait... (should NOT auto-play front)
4. Tap to reveal answer
5. ✅ Should auto-play English/Spanish after 0.5s

---

### **Phase 2: Settings Testing (Device Required)**

**Note:** Settings UI not implemented yet (Day 2 task)

Current settings can be tested programmatically:
```swift
// Change settings in code (temporary)
AudioService.shared.autoPlayMode = .frontOnly
AudioService.shared.autoPlayDelay = 1.0
AudioService.shared.speechRate = 0.7

// Test review session with new settings
```

---

### **Phase 3: Edge Case Testing (Device Required)**

#### **Test 4: Empty Text**
```swift
AudioService.shared.speakGerman("")  // Should not crash
```
✅ Button should be disabled for empty text

#### **Test 5: Special Characters**
```swift
AudioService.shared.speakGerman("Schön")  // ö
AudioService.shared.speakGerman("Größe")  // ö, ß
AudioService.shared.speakGerman("Übung")  // Ü
```
✅ Should pronounce correctly

#### **Test 6: Long Text**
```swift
let longText = "Dies ist ein sehr langer Satz mit vielen Wörtern."
AudioService.shared.speakGerman(longText)
```
✅ Should speak entire sentence

#### **Test 7: Rapid Taps**
1. Tap audio button
2. Immediately tap again (multiple times)
3. ✅ Should stop previous and start new (no overlap)

#### **Test 8: Background Audio**
1. Start playing music (Spotify, Apple Music, etc.)
2. Open flashcard app
3. Start review session
4. ✅ Music should duck (lower volume) during speech
5. ✅ Music should resume after speech

---

## 📱 **Device Testing Required**

### **Why Device Testing?**
- ❌ Simulator doesn't play audio
- ❌ Simulator doesn't have haptic feedback
- ❌ Simulator audio quality differs from device

### **Test Devices:**
- ✅ iPhone with speaker
- ✅ iPhone with headphones
- ✅ iPhone on silent mode
- ✅ iPhone with background music playing

---

## 🐛 **If You Encounter Errors**

### **Error: "Cannot find 'AudioService' in scope"**
**Solution:** Clean build folder (⌘ + Shift + K), then rebuild

### **Error: "Cannot find 'AudioButton' in scope"**
**Solution:** Ensure AudioButton.swift is in project target

### **Error: No audio on device**
**Checks:**
1. Volume up?
2. Not on silent mode (unless testing silent mode)?
3. Permissions granted?
4. Headphones working?

### **Error: "Cannot infer contextual base in reference to member 'top'"**
**Solution:** This was a false error, should resolve after clean build

---

## ✅ **Success Criteria**

### **Must Pass:**
- [ ] Build succeeds with no errors
- [ ] App launches without crash
- [ ] Review session loads
- [ ] Audio button visible on cards
- [ ] Tapping button plays audio (on device)
- [ ] Auto-play works with default settings (back only)
- [ ] No crashes with edge cases

### **Nice to Have:**
- [ ] Audio quality sounds good
- [ ] Auto-play delay feels natural (0.5s)
- [ ] Haptic feedback feels responsive
- [ ] Background music ducks properly

---

## 📊 **Current Status**

### **Implemented:**
- ✅ AudioService.swift (core service)
- ✅ AudioButton.swift (UI component)
- ✅ ReviewSessionView.swift (integration)

### **Not Implemented Yet:**
- ⏳ Settings UI (Day 2)
- ⏳ AddCardView integration (Day 3)
- ⏳ CardManagementView integration (Day 3)
- ⏳ EditCardView integration (Day 3)

---

## 🚀 **Next Steps**

### **If Build Succeeds:**
1. ✅ Test on device (basic audio)
2. ✅ Test auto-play modes
3. ✅ Test edge cases
4. 📝 Note any issues
5. ➡️ **Move to Day 2: Settings UI**

### **If Build Fails:**
1. 🐛 Check error messages
2. 🔧 Fix issues (see "If You Encounter Errors" above)
3. 🔄 Rebuild
4. 🧪 Test again

---

## 💡 **Testing Tips**

### **Best Practices:**
1. **Test on real device** - Audio is critical, simulator won't cut it
2. **Test all languages** - German, English, Spanish
3. **Test with headphones** - Some users will use them
4. **Test in quiet environment** - Hear quality issues
5. **Test with background audio** - Common real-world scenario

### **What to Listen For:**
- ✅ Correct pronunciation
- ✅ Natural pacing
- ✅ Appropriate volume
- ✅ No crackling/distortion
- ✅ Smooth transitions

### **What to Feel For:**
- ✅ Haptic feedback on button tap
- ✅ Responsive UI (no lag)
- ✅ Smooth animations

---

## 🎯 **Expected Results**

### **When It Works:**
```
1. Start review session
2. Card appears: "Sonne"
3. Wait 0.5s
4. [No audio - front side auto-play disabled by default]
5. Tap to reveal
6. Card shows: "sun"
7. Wait 0.5s
8. 🔊 Hear: "sun" (auto-play back side)
9. Tap 🔊 button manually
10. 🔊 Hear: "sun" (manual play)
11. Rate card, move to next
12. Repeat!
```

### **UX Should Feel:**
- ⚡️ Fast (no lag)
- 🎵 Natural (good pronunciation)
- 📱 Responsive (haptics work)
- 🎮 Fun (audio adds immersion)

---

## 📞 **Need Help?**

### **Check These Files:**
1. AudioService.swift - Core logic
2. AudioButton.swift - UI component
3. ReviewSessionView.swift - Integration
4. AUDIO_DAY1_COMPLETE.md - Implementation notes

### **Common Issues:**
- No audio → Check device volume, permissions
- Crashes → Check empty text handling
- Wrong language → Check language code mapping
- Overlap → Check stop() before speak()

---

**Ready to test!** 🎵🔊

**Next:** Run on device and verify audio works!

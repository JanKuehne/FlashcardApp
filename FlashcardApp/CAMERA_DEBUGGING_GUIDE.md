# 🐛 Camera Scanner Debugging Guide

## Current Issue: No Yellow Boxes / No Text Captured

### Symptoms:
- ✅ Camera opens
- ❌ No yellow boxes appear around text
- ❌ Tapping green button just closes camera
- ❌ No results shown

---

## Debugging Steps

### 1. Check Console Output

When you open camera and point at text, you should see:

```
👁️ DataScanner didAdd: X items, total: Y
➕ Adding text: 'montaña'
➕ Adding text: 'Berg'
📝 Total accumulated: 2 items
```

**If you DON'T see these messages:**
- OCR is not recognizing any text
- Camera might not have proper permissions
- Text might not be clear enough

---

### 2. When You Tap Green Button

You should see:

```
🔍 DEBUG: Accumulated text items: 5
🔍 DEBUG: Full text length: 50 characters
📸 Capturing 5 text items
📸 Text content: montaña Berg sol Sonne ...
📸 OCR Extracted Text:
---
montaña
Berg
sol
Sonne
---
💰 Estimated cost: $0.000185
```

**If you see "No text captured yet":**
```
⚠️ No text captured yet - keep camera over text
⚠️ Make sure text is in focus and well-lit
🔍 DEBUG: Accumulated text items: 0
```

This means OCR didn't recognize anything.

---

## Common Issues & Solutions

### Issue 1: No Yellow Boxes Appear

**Possible Causes:**
1. **Camera not focused** - Text is blurry
2. **Poor lighting** - Too dark or shadows
3. **Text too small** - Camera too far away
4. **Handwritten text** - OCR works best with printed text
5. **Wrong orientation** - Try landscape mode

**Solutions:**
- ✅ Hold camera 20-30cm from page
- ✅ Ensure good lighting (natural light best)
- ✅ Keep camera completely still (2-3 seconds)
- ✅ Use printed text (not handwritten)
- ✅ Clean, flat page (no curves)

---

### Issue 2: Text Captured But No API Key

Console shows:
```
❌ LLM Error: OpenAI API-Schlüssel fehlt
```

**Solution:** Need to add API key first!

**Option A: Add via Settings Screen** (if exists)
- Open Settings in app
- Find "OpenAI API Key" field
- Paste your key (starts with `sk-...`)

**Option B: Add Programmatically** (for testing)
```swift
// In SettingsView or anywhere before scanning:
AppSettings.shared.openAIAPIKey = "sk-your-actual-key-here"
```

---

### Issue 3: API Key Invalid

Console shows:
```
❌ OpenAI API Error (401): Invalid API key
```

**Solution:**
- Check key is correct (copy-paste from OpenAI dashboard)
- Ensure key starts with `sk-`
- Check key hasn't been revoked
- Verify you have credits in OpenAI account

---

## Testing Checklist

### Before Opening Camera:
- [ ] API key is set in `AppSettings.shared.openAIAPIKey`
- [ ] Console is open in Xcode
- [ ] Device has good lighting
- [ ] Textbook page is clean and flat

### While Camera is Open:
- [ ] Point at PRINTED text (not handwritten)
- [ ] Hold steady for 2-3 seconds
- [ ] Look for yellow boxes (may take a moment)
- [ ] Check console for `didAdd` messages

### After Tapping Green Button:
- [ ] Check console for "Accumulated text items"
- [ ] If 0 items: Text wasn't recognized
- [ ] If >0 items: Should see LLM processing
- [ ] Processing screen should appear
- [ ] Results should show after ~500ms

---

## Diagnostic Commands

### Check if API Key is Set:
```swift
print("API Key: \(AppSettings.shared.openAIAPIKey.prefix(10))...")
print("Is LLM Enabled: \(AppSettings.shared.isLLMEnabled)")
```

### Check Camera Permissions:
```swift
import AVFoundation

let status = AVCaptureDevice.authorizationStatus(for: .video)
print("Camera permission: \(status)")
// .authorized = good
// .denied = bad (need to enable in Settings)
```

### Check DataScanner Support:
```swift
print("DataScanner supported: \(DataScannerViewController.isSupported)")
print("DataScanner available: \(DataScannerViewController.isAvailable)")
```

---

## Expected Console Flow

### Successful Scan:
```
1. 👁️ DataScanner didAdd: 1 items, total: 1
2. ➕ Adding text: 'la'
3. 👁️ DataScanner didAdd: 1 items, total: 2
4. ➕ Adding text: 'montaña'
5. 👁️ DataScanner didAdd: 1 items, total: 3
6. ➕ Adding text: 'Berg'
7. 📝 Total accumulated: 3 items
   
[User taps green button]

8. 🔍 DEBUG: Accumulated text items: 3
9. 🔍 DEBUG: Full text length: 20 characters
10. 📸 Capturing 3 text items
11. 📸 Text content: la montaña Berg
12. 📸 OCR Extracted Text:
    ---
    la montaña
    Berg
    ---
13. 💰 Estimated cost: $0.000150
14. 📝 LLM extracted 1 pairs:
    German: 'Berg' → Spanish: 'la montaña'
```

---

## Quick Tests

### Test 1: Simple Text
1. Open camera
2. Point at large, printed word (like "EXIT" sign)
3. Wait 2-3 seconds
4. Look for yellow box
5. Check console

### Test 2: Check API Key
Before testing camera:
```swift
let key = AppSettings.shared.openAIAPIKey
print("Has API key: \(!key.isEmpty)")
print("Key starts with sk-: \(key.hasPrefix("sk-"))")
```

### Test 3: Manual Test
Add this temporary code to test LLM directly:
```swift
Task {
    let service = VocabularyExtractionService(apiKey: AppSettings.shared.openAIAPIKey)
    let pairs = try await service.extractVocabulary(
        from: "la montaña Berg el sol Sonne",
        sourceLanguage: "Spanish",
        targetLanguage: "German"
    )
    print("✅ LLM works! Got \(pairs.count) pairs")
}
```

---

## Next Steps

1. **Build & Run with Console open**: ⌘R
2. **Check initial diagnostics** (camera support, API key)
3. **Open camera scanner**
4. **Watch console** for messages
5. **Point at clear, printed text**
6. **Wait for yellow boxes** (or check console if none appear)
7. **Tap green button**
8. **Check console output**

---

## Most Likely Issues

### If NO console messages when camera opens:
**Problem**: Camera not scanning at all
**Solution**: Check camera permissions, device support

### If NO "didAdd" messages when pointing at text:
**Problem**: OCR not recognizing text
**Solution**: Better lighting, clearer text, hold steady

### If "0 items" when tapping button:
**Problem**: Text recognized but not accumulated
**Solution**: Check console for errors, verify delegate is working

### If "API key fehlt":
**Problem**: No API key configured
**Solution**: Add API key to AppSettings

---

## Emergency Fallback

If camera OCR continues not working, you can test the LLM directly with manual text:

```swift
// In CameraScannerView, add a test button:
Button("TEST with sample text") {
    handleScanResult("la montaña Berg el sol Sonne la luna Mond")
}
```

This bypasses camera OCR and tests just the LLM processing.

---

**Remember**: 
- Yellow boxes = OCR is working ✅
- No yellow boxes = OCR not recognizing text ❌
- Console messages are your friend! 📊

**Try again with console open and report what you see!** 🔍

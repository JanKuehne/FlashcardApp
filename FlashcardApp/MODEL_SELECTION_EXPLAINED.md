# Model Selection: How It Works

## 🎯 Answer: **User Chooses in the App UI**

The model selection is **100% user-facing** and happens **before each scan**. Nothing is hardcoded!

---

## 📱 User Experience Flow

```
┌─────────────────────────────────────────┐
│     📷 KAMERA SCANNER Screen            │
├─────────────────────────────────────────┤
│                                         │
│          KI-Modell                      │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ GPT-4o-mini  │  │   GPT-4o     │   │  ← USER TAPS HERE
│  │  Schnell &   │  │   Genauer    │   │
│  │   Günstig    │  │ ~10x teurer  │   │
│  └──────────────┘  └──────────────┘   │
│     (default)          (advanced)       │
│                                         │
│  Toggle: Beispielsätze generieren      │  ← USER TOGGLES HERE
│                                         │
│  📷 KAMERA ÖFFNEN                      │  ← USER TAPS TO SCAN
└─────────────────────────────────────────┘
```

---

## 🔧 Technical Implementation

### 1. State Variable (Line 21)
```swift
@State private var useAdvancedModel = false  // Defaults to GPT-4o-mini
```

### 2. UI Buttons (Lines 165-180)
```swift
modelButton(
    title: "GPT-4o-mini",
    subtitle: "Schnell & Günstig",
    isSelected: !useAdvancedModel,  // ← Selected when false
    color: .blue
) {
    useAdvancedModel = false  // ← User taps, sets to false
}

modelButton(
    title: "GPT-4o",
    subtitle: "Genauer (~10x teurer)",
    isSelected: useAdvancedModel,  // ← Selected when true
    color: .purple
) {
    useAdvancedModel = true  // ← User taps, sets to true
}
```

### 3. Passed to AI Service (Line 542)
```swift
let llmService = VocabularyExtractionService(
    apiKey: apiKey, 
    useAdvancedModel: useAdvancedModel  // ← User's choice passed here
)
```

### 4. AI Service Uses It (VocabularyExtractionService.swift)
```swift
init(apiKey: String, useAdvancedModel: Bool = false) {
    self.apiKey = apiKey
    self.model = useAdvancedModel ? "gpt-4o" : "gpt-4o-mini"
    //            ^^^^^^^^^^^^^^^^
    //            User's choice determines which model
}
```

---

## 📊 How the Model is Selected

```
User Journey:
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  1. User opens camera scanner                               │
│     ↓                                                        │
│  2. User sees TWO buttons:                                  │
│     • GPT-4o-mini (blue, selected by default)              │
│     • GPT-4o (purple, not selected)                        │
│     ↓                                                        │
│  3. User taps GPT-4o button                                 │
│     ↓                                                        │
│  4. useAdvancedModel = true                                 │
│     ↓                                                        │
│  5. Purple button highlights, blue button dims             │
│     ↓                                                        │
│  6. User taps "KAMERA ÖFFNEN"                              │
│     ↓                                                        │
│  7. User scans text and taps "TEXT ERFASSEN"               │
│     ↓                                                        │
│  8. handleScanResult() creates VocabularyExtractionService │
│     with useAdvancedModel: true                            │
│     ↓                                                        │
│  9. Service uses "gpt-4o" for API call                     │
│     ↓                                                        │
│ 10. Better accuracy, ~1 second processing                   │
└──────────────────────────────────────────────────────────────┘
```

---

## 🎨 Visual Button States

### Default State (GPT-4o-mini selected):
```
┌──────────────┐  ┌──────────────┐
│ GPT-4o-mini  │  │   GPT-4o     │
│  Schnell &   │  │   Genauer    │
│   Günstig    │  │ ~10x teurer  │
└──────────────┘  └──────────────┘
   ▲▲▲ BRIGHT         dim
   BLUE BORDER        thin border
   SELECTED ✓         not selected
```

### After User Taps GPT-4o:
```
┌──────────────┐  ┌──────────────┐
│ GPT-4o-mini  │  │   GPT-4o     │
│  Schnell &   │  │   Genauer    │
│   Günstig    │  │ ~10x teurer  │
└──────────────┘  └──────────────┘
     dim            ▲▲▲ BRIGHT
   thin border      PURPLE BORDER
   not selected     SELECTED ✓
```

---

## 🔄 User Can Change Per-Scan

The selection is **per-scan**, not global:

```
Scan 1: User chooses GPT-4o-mini → Fast, cheap
Scan 2: Bad results → User taps GPT-4o → Better accuracy
Scan 3: Clean text again → User taps GPT-4o-mini → Fast again
```

---

## 💾 Where is the State Stored?

```swift
// Line 21 in CameraScannerView.swift
@State private var useAdvancedModel = false
```

- **Type**: `@State` (SwiftUI state)
- **Scope**: Per camera scanner view instance
- **Lifetime**: Exists while camera scanner is open
- **Default**: `false` (GPT-4o-mini)
- **Persists**: NO - resets to default when view dismisses
- **Global**: NO - each scan starts fresh

---

## 🎛️ No Settings Menu, No Hardcoding

### ❌ What This Is NOT:

- **NOT** in a Settings view
- **NOT** stored in UserDefaults
- **NOT** a global app preference
- **NOT** hardcoded in build configuration
- **NOT** determined at compile time
- **NOT** hidden from user

### ✅ What This IS:

- **YES** User-visible buttons in the UI
- **YES** User taps to choose before each scan
- **YES** Live toggle in the camera scanner
- **YES** Immediate visual feedback
- **YES** Can change between scans
- **YES** Completely in user's control

---

## 📍 Exact Code Locations

| What | File | Line |
|------|------|------|
| State declaration | CameraScannerView.swift | 21 |
| UI buttons | CameraScannerView.swift | 165-180 |
| Button function | CameraScannerView.swift | 495-512 |
| Passed to service | CameraScannerView.swift | 542 |
| Service uses it | VocabularyExtractionService.swift | 19 |

---

## 🧪 Test It Yourself

1. Run the app
2. Open camera scanner
3. **Look at the screen** - you'll see two buttons at the top
4. Tap them back and forth
5. Notice:
   - Button highlights change
   - Selected model shows in processing screen
   - Cost estimate changes

---

## 💡 Why This Design?

This approach gives users:

1. **Transparency**: They know which model is being used
2. **Control**: They decide based on situation
3. **Cost awareness**: See the price difference
4. **Flexibility**: Switch per-scan as needed
5. **Education**: Learn when to use each model

---

## 🎯 Summary

**Model selection is 100% in the user's hands through visible UI buttons.**

- Not hardcoded ❌
- Not hidden ❌
- Not automatic ❌

**User taps, user chooses, user sees the difference.** ✅

---

**Location to see it**: 
Run app → Tap "+" → Tap camera icon → **See model buttons at top!**

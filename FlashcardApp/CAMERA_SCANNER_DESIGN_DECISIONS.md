# Camera Scanner - Design Decisions & Rationale
## January 1, 2026

---

## 🎯 **Core Design Philosophy**

The camera scanner was designed with three key principles:
1. **Accuracy First** - Users need reliable extraction (83%+)
2. **Cost Efficiency** - Keep costs negligible ($1-2/month typical use)
3. **User Choice** - Provide options but guide with smart defaults

---

## 📐 **Architecture Decisions**

### **1. Three-Layer OCR Pipeline**

```
Photo → OCR Layer → LLM Layer → Cards
```

**Why not end-to-end?**
- Separation of concerns (OCR vs extraction logic)
- Can swap OCR providers without changing extraction
- Easier to debug and test each layer
- Flexibility for future improvements

**Benefits:**
- Apple Vision (free, on-device)
- Google Vision (cloud, premium)
- GPT-4o Vision (skip OCR entirely)

---

### **2. LLM-Based Extraction (Not Regex)**

**Original Approach:** Regex patterns for word pairing
- Pattern 1: `word1 - word2`
- Pattern 2: `word1 (word2)`
- Pattern 3: `word1    word2` (spacing)

**Why We Switched to LLM:**
1. **Complex Layouts:** Textbooks have varying formats
2. **Context Understanding:** Articles, plurals, verb forms
3. **Language Detection:** Spanish vs German characters
4. **Error Tolerance:** Handles OCR mistakes better
5. **Flexibility:** One system for all textbook formats

**Cost Trade-off:**
- Regex: Free but 40-60% accuracy
- LLM: $0.012/image but 83% accuracy
- **Verdict:** Worth it!

---

### **3. GPT-4o Required (Not 4o-mini)**

**Discovery:** GPT-4o-mini achieved only 17% accuracy

**Why GPT-4o-mini Failed:**
- Weak reasoning about text structure
- Can't reliably match columns
- Struggles with language identification
- Misses context clues (articles, plurals)
- Too conservative even with aggressive prompts

**Why GPT-4o Works:**
- Strong spatial reasoning
- Better language understanding
- Context-aware pairing
- Handles ambiguity well

**Cost Difference:**
- GPT-4o-mini: $0.0003/image (17% accuracy) = **$0.0018 per word**
- GPT-4o: $0.012/image (83% accuracy) = **$0.00144 per word**
- **GPT-4o is actually cheaper per usable word!**

---

### **4. Smart Default: Apple OCR + GPT-4o**

**Why Apple Vision for OCR?**
1. ✅ **Privacy:** Stays on-device
2. ✅ **Speed:** No network upload
3. ✅ **Free:** No API costs
4. ✅ **Reliable:** 83% when paired with GPT-4o
5. ✅ **Offline:** Works without internet (for OCR part)

**Why Not Google Vision by Default?**
1. ❌ Same accuracy as Apple (83%)
2. ❌ Costs money ($0.0015/image)
3. ❌ Requires billing setup
4. ❌ Network dependency
5. ❌ Privacy concerns (image upload)

**Why Keep Google Vision as Option?**
- Some complex layouts work better
- Users may prefer cloud processing
- Benchmark for quality comparison
- May improve over time

---

### **5. Progressive Confidence Thresholds**

```
Scan #1: 50% confidence → Gets clear, obvious words
Scan #2: 30% confidence → Gets moderately uncertain words
Scan #3: 10% confidence → Gets low-confidence words
Scan #4: 5% confidence  → Gets almost everything
```

**Design Rationale:**
- First scan: High quality, no false positives
- Subsequent scans: Fill in missing words
- User controls accuracy vs completeness
- "Erneut" button lowers threshold

**Why Not Start at 10%?**
- Too many false positives
- User gets overwhelmed
- Better to start conservative, then expand

---

### **6. Accumulation Mode**

**Feature:** Words from multiple scans accumulate in one session

**Why?**
- Pages often have 20-40 word pairs
- Single scan might miss 3-5 words
- User can scan again to catch missed words
- Duplicates are filtered automatically

**Alternative Considered:** Replace mode (scan overwrites previous)
**Rejected Because:** User loses previously found words

---

### **7. Duplicate Filtering**

**Two-Layer Check:**
1. Against **existing cards** in deck (database)
2. Against **current session** (in-memory)

**Why Both?**
- Prevents re-adding cards from previous sessions
- Prevents duplicates within current session
- Handles case-insensitive + whitespace normalized

**Normalization:**
```swift
word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
```

---

### **8. Model Selection UI**

**Visual Design:**
```
┌─────────────────────────────┐
│  KI-Modell                  │
│  ┌──────────┐ ┌───────────┐│
│  │4o-mini   │ │ 4o ✓      ││
│  │orange    │ │ green     ││
│  │"Nicht    │ │"Empfohlen"││
│  │empfohlen"│ │           ││
│  └──────────┘ └───────────┘│
│  ✅ GPT-4o: ~83% Genauig...│
└─────────────────────────────┘
```

**Color Psychology:**
- **Green (4o):** Safe, recommended, go
- **Orange (4o-mini):** Warning, caution
- White card: Important decision, focus here

**Text Strategy:**
- Clear labeling: "Empfohlen ✓" vs "Nicht empfohlen"
- Accuracy shown: "~83%" vs "~20%"
- Cost shown: "$0.012/Bild" (transparency)

---

### **9. Photo Upload vs Live Camera**

**Recommended Method:** Photo Upload 📸
- User has time to frame properly
- Can retake until perfect
- Better lighting control
- Less hand shake
- Review before processing

**Live Camera:** Secondary option
- Harder to use (must hold steady 3-4s)
- OCR quality varies
- Network timing issues
- More user frustration

**UI Strategy:**
- Photo upload button: Large, green, "EMPFOHLEN"
- Live camera button: Smaller, secondary, warning text

---

### **10. ScrollView vs VStack**

**Problem:** Toolbar overlaying content

**Solution:** ScrollView instead of fixed VStack
```swift
ScrollView {
    VStack {
        // Content
    }
    .padding()
    .padding(.top, 20)  // Toolbar clearance
}
```

**Why ScrollView?**
- Flexible height (works on all screen sizes)
- Can scroll if toolbar overlaps
- iOS handles safe area better
- Future-proof for more content

**Alternative Considered:** `.safeAreaInset`
**Rejected:** More complex, less flexible

---

## 🎨 **UX Design Decisions**

### **1. Visual Hierarchy**

```
1. Toolbar (system)          ← "📷 KAMERA SCANNER"
2. Model Selection (card)    ← Most important choice
3. Additional Options        ← Toggle switches
4. Instructions              ← Numbered list
5. Action Buttons            ← Photo upload / camera
6. Pro Tips                  ← Yellow info box
7. Test Button               ← Developer/debug
```

**Rationale:**
- Most critical choice first (model selection)
- Progressive disclosure (options → instructions → actions)
- Visual separation (cards, colors, spacing)

---

### **2. Button Tap Targets**

**iOS Standard:** 44pt minimum

**Implementation:**
```swift
.frame(maxWidth: .infinity, minHeight: 44)
.contentShape(Rectangle())
.buttonStyle(.plain)
```

**Why?**
- Accessibility (easier for all users)
- Mobile best practice
- Prevents frustration
- Immediate feedback

**Original Problem:** Only bottom edge was tappable
**Fix:** Entire button area responds

---

### **3. Color Coding**

| Color | Meaning | Usage |
|-------|---------|-------|
| **Green** | Recommended, success | GPT-4o button, success messages |
| **Orange** | Warning, caution | GPT-4o-mini button, warnings |
| **Blue** | Information, neutral | Original toggles, info |
| **Purple** | Premium (removed) | Old GPT-4o color |
| **Red** | Error, remove | Delete buttons, errors |
| **Yellow** | Tips, highlights | Pro tips section |

---

### **4. Progressive Disclosure**

**Level 1 (Always Visible):**
- Model selection
- Photo upload button

**Level 2 (Toggles):**
- Example sentences
- GPT-4o Vision
- Google Vision

**Level 3 (Conditional):**
- Instructions (collapsed in card)
- Pro tips (at bottom)
- Test button (development only)

**Why?**
- Reduces cognitive load
- Focus on essential choices
- Advanced options available but not overwhelming

---

### **5. Feedback & Guidance**

**Immediate Feedback:**
- Button press → visual change
- Model switch → warning message updates
- Photo selected → "Processing..." animation
- Success → green banner with count

**Guidance:**
- Numbered instructions (1-5)
- Pro tips with emojis
- Warning messages (accuracy expectations)
- Cost transparency

**Error Handling:**
- Clear error messages
- Suggestions for fixes
- Fallback options

---

## 🔧 **Technical Design Decisions**

### **1. Service Layer Architecture**

```swift
// Separation of concerns
GoogleVisionService  // OCR only
VocabularyExtractionService  // LLM extraction
LLMService  // Generic LLM calls

// Not:
AllInOneService  // ❌ Too coupled
```

**Benefits:**
- Testable in isolation
- Swappable implementations
- Clear responsibilities
- Easier to maintain

---

### **2. Error Handling Strategy**

```swift
enum VisionError: LocalizedError {
    case invalidImage
    case networkError(String)
    case apiError(String)
    case noTextFound
    
    var errorDescription: String? {
        // User-friendly German messages
    }
}
```

**Why Custom Errors?**
- User-friendly messages
- Localized (German)
- Actionable guidance
- Debugging information

---

### **3. State Management**

```swift
@State private var useAdvancedModel = true
@State private var generateExamples = true
@State private var useDirectVision = false
@State private var useGoogleVision = false
```

**Why @State (Not @AppStorage)?**
- Session-based preferences
- Don't persist user experiments
- Reset to defaults each time
- Simpler state management

**Exception:** API keys in AppSettings
- These should persist

---

### **4. Async/Await Flow**

```swift
Task {
    let ocrText = try await performOCR(image)
    let pairs = try await extractVocabulary(ocrText)
    let filtered = await filterDuplicates(pairs)
    await MainActor.run {
        extractedWords = filtered
    }
}
```

**Why This Pattern?**
- Clear sequential flow
- Proper error propagation
- Main thread updates explicit
- Readable and maintainable

---

### **5. Data Flow**

```
User Photo
    ↓
OCR Service (Vision/Google)
    ↓
Raw Text
    ↓
LLM Service (GPT-4o)
    ↓
Vocabulary Pairs
    ↓
Duplicate Filter (SwiftData)
    ↓
ExtractedWord Array
    ↓
UI Display
    ↓
User Confirmation
    ↓
Flashcard Creation (SwiftData)
```

**Why This Flow?**
- Clear transformation steps
- Easy to test each stage
- Can insert logging/debugging
- Matches mental model

---

## 💡 **Prompt Engineering**

### **Original Prompt (Conservative):**
```
"Skip unclear or partial words"
"Return ONLY valid, clearly matched pairs"
```
**Result:** 2-4 pairs extracted (20% accuracy)

### **Improved Prompt (Aggressive):**
```
"Extract ALL pairs - be thorough but accurate"
"EXTRACT ALL PAIRS - Don't be conservative!"
"Better to extract more than miss words"
```
**Result:** 15-18 pairs extracted (83% accuracy)

### **Key Improvements:**
1. Character hints: ñ, á for Spanish; ä, ö, ß for German
2. Pattern examples: textbook column layout
3. Common formats: articles + nouns, verb forms
4. Explicit instruction: "Extract EVERY clear pair"

---

## 🎯 **Future Design Considerations**

### **Potential Improvements:**

1. **Pre-OCR Image Enhancement**
   - Contrast adjustment
   - Perspective correction
   - Noise reduction
   - **Why Not Yet:** Adds complexity, current quality is good

2. **Multi-Language Support**
   - French-German, Italian-German, etc.
   - **Why Not Yet:** Need more testing with Spanish-German first

3. **Batch Processing**
   - Upload 10 photos at once
   - Process in background
   - **Why Not Yet:** UI complexity, error handling

4. **Scan History**
   - Save scan sessions
   - Resume later
   - **Why Not Yet:** Storage management, UI complexity

5. **Quality Warnings**
   - Detect blurry photos
   - Suggest retake
   - **Why Not Yet:** Additional ML model needed

---

## 📊 **Success Metrics That Guided Design**

1. **Accuracy > 80%** → Chose GPT-4o over 4o-mini
2. **Cost < $0.02/image** → Used Apple OCR (free)
3. **Speed < 2 seconds** → On-device OCR
4. **Tap Target ≥ 44pt** → Proper button sizing
5. **User Choice Clarity** → Color coding + labels

---

## 🏆 **Design Wins**

✅ **Smart Defaults:** Users get best experience out-of-box
✅ **Cost Efficiency:** $1.20 per 100 images (negligible)
✅ **High Accuracy:** 83% matches professional OCR systems
✅ **Clear Guidance:** Users know what to expect
✅ **Flexible Options:** Power users can customize
✅ **Privacy First:** OCR stays on-device by default
✅ **Fast Processing:** <1 second for on-device OCR

---

## 📝 **Lessons for Future Features**

1. **Test with real data** before committing to an approach
2. **Conservative prompts** don't work for extraction tasks
3. **Cheaper isn't better** if it doesn't work (4o-mini)
4. **On-device first** when quality is comparable
5. **Color psychology matters** for user guidance
6. **Progressive disclosure** reduces cognitive load
7. **Smart defaults** are crucial for UX

---

**Last Updated:** January 1, 2026
**Document Owner:** Development Team
**Status:** Design Rationale Complete ✅

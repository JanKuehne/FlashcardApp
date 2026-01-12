# Camera Scanner Updates - Dec 31, 2025

## Summary of Changes

### ✅ Completed Updates

#### 1. VocabularyExtractionService.swift
- ✅ Added model selection: GPT-4o vs GPT-4o-mini
- ✅ Added example sentence generation
- ✅ Enhanced prompt to prevent language confusion
- ✅ Updated cost estimation for both models
- ✅ Updated `VocabularyPair` struct to include `example` field

#### 2. ExtractedWord.swift
- ✅ Added `exampleSentence: String?` field

#### 3. CameraScannerView.swift
- ✅ Added model selection UI (GPT-4o vs GPT-4o-mini toggle)
- ✅ Added example sentence toggle
- ✅ Added duplicate checking against existing flashcards
- ✅ Updated ExtractedWordRow to display example sentences
- ✅ Added `deckId: UUID` parameter to constructor

---

## ⚠️ Breaking Change: Constructor Update

**Old constructor:**
```swift
CameraScannerView { words in
    // handle words
}
```

**New constructor:**
```swift
CameraScannerView(
    onWordsExtracted: { words in
        // handle words
    },
    deckId: deck.id  // Required for duplicate checking
)
```

---

## 🔧 Required Updates in Calling Code

You need to find where `CameraScannerView` is instantiated and update it:

### Example (Before):
```swift
.sheet(isPresented: $showCameraScanner) {
    CameraScannerView { words in
        for word in words {
            let card = Flashcard(
                front: word.german,
                back: word.translation,
                deckId: deck.id
            )
            modelContext.insert(card)
        }
    }
}
```

### Example (After):
```swift
.sheet(isPresented: $showCameraScanner) {
    CameraScannerView(
        onWordsExtracted: { words in
            for word in words {
                let card = Flashcard(
                    front: word.german,
                    back: word.translation,
                    deckId: deck.id,
                    exampleSentence: word.exampleSentence  // Now includes examples!
                )
                modelContext.insert(card)
            }
        },
        deckId: deck.id  // Pass deck ID for duplicate checking
    )
}
```

---

## New Features for Users

### 1. Model Selection
Users can now choose between:
- **GPT-4o-mini** (default): Fast & cheap (~$0.0001 per scan)
- **GPT-4o**: More accurate, better at handling messy OCR (~$0.001 per scan, ~10x cost)

### 2. Example Sentences
- Toggle to enable/disable example sentence generation
- Examples are in the source language (Spanish in your case)
- Displayed in the word list with a bubble icon

### 3. Duplicate Prevention
- Automatically filters out words that already exist in the deck
- Comparison is case-insensitive and whitespace-normalized
- Shows count of duplicates removed in console

### 4. Improved Prompt
The LLM prompt now explicitly:
- Validates that source and target are in different languages
- Skips pairs where languages can't be determined
- Prevents "both sides in same language" issue

---

## Testing Tips

### Test with GPT-4o
1. Scan a textbook page with the camera
2. Before capturing, toggle **"GPT-4o"** model
3. Keep example sentences enabled
4. Capture and observe:
   - ✅ More accurate word pairing
   - ✅ Better handling of messy OCR
   - ✅ Correct language assignment
   - ✅ Natural example sentences

### Test Duplicate Checking
1. Scan some words and add them to deck
2. Scan the same page again
3. Observe: Previously added words are filtered out

### Cost Comparison
- GPT-4o-mini with examples: ~$0.0002 per typical textbook page
- GPT-4o with examples: ~$0.002 per typical textbook page
- Still very affordable! (~$0.20 for 100 scans with GPT-4o)

---

## Recommendations

### For Better OCR Results:
1. **Let camera stabilize**: Wait 2-3 seconds before capturing
2. **Good lighting**: Ensure page is well-lit
3. **Hold steady**: Keep camera parallel to page
4. **Clear view**: Avoid shadows or reflections

### Model Selection Guide:
- Use **GPT-4o-mini** for:
  - Clean, well-formatted textbooks
  - Quick batch imports
  - When cost is a concern

- Use **GPT-4o** for:
  - Handwritten notes
  - Poor quality scans
  - Complex layouts
  - When accuracy is critical

---

## Known Issues & Future Improvements

### OCR Capture Issues (Apple's DataScanner):
- Yellow boxes don't always appear (VisionKit behavior)
- Sometimes captures before enough text is visible
- **Solution**: Manual "Capture" button forces capture of all accumulated text

### Possible Improvements:
1. Add countdown timer before auto-capture (3-2-1)
2. Show live preview of recognized text
3. Allow manual text editing before LLM processing
4. Cache LLM results to avoid duplicate API calls
5. Batch processing: scan multiple pages, then process all at once

---

## Files Modified
- `VocabularyExtractionService.swift`
- `ExtractedWord.swift`
- `CameraScannerView.swift`
- `CAMERA_SCANNER_UPDATES.md` (this file)

# Instructions: Update AddCardView to Use New CameraScannerView

## 🎯 What Needs to Change

The `CameraScannerView` now requires a `deckId` parameter for duplicate checking.

---

## 📝 Find AddCardView.swift

Search your project for `AddCardView.swift` - this is the file that instantiates `CameraScannerView`.

---

## 🔧 Changes Required

### 1. Find the sheet that presents CameraScannerView

Look for something like:

```swift
.sheet(isPresented: $showCameraScanner) {
    CameraScannerView { words in
        // handle words
    }
}
```

### 2. Update to New Constructor

**OLD (will cause compile error):**
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

**NEW (with deckId and example sentences):**
```swift
.sheet(isPresented: $showCameraScanner) {
    CameraScannerView(
        onWordsExtracted: { words in
            for word in words {
                let card = Flashcard(
                    front: word.german,
                    back: word.translation,
                    deckId: deck.id,
                    exampleSentence: word.exampleSentence  // ✨ New feature!
                )
                modelContext.insert(card)
            }
        },
        deckId: deck.id  // 🔍 Required for duplicate checking
    )
}
```

---

## 🔍 What to Look For

In AddCardView.swift, search for:
- `CameraScannerView`
- `showCameraScanner`
- `.sheet(isPresented:`

One of these searches should lead you to the right place.

---

## ✅ After Making Changes

The compile errors should disappear, and you'll have:
- ✅ Duplicate word detection
- ✅ Example sentence support
- ✅ Model selection (GPT-4o vs GPT-4o-mini)
- ✅ Example sentence toggle

---

## 🧪 Test the Changes

1. Run the app
2. Go to a deck
3. Tap the camera icon
4. You should now see:
   - Model selection buttons (GPT-4o-mini / GPT-4o)
   - Example sentences toggle
5. Scan some text
6. Verify example sentences appear in the word list
7. Try scanning the same words again → duplicates should be filtered

---

## 💡 If You Can't Find AddCardView

The file might be named differently. Try searching for:
- Files containing `CameraScannerView(`
- Files containing `showCameraScanner`
- Files with camera button toolbar items

Or share the file structure and I can help locate it!

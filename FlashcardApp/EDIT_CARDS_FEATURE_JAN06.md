# ✏️ Edit Cards Feature + Card Count Fix (January 6, 2026)

## 🎯 **Issues Reported**

### **Bug #1: Card Count Incorrect** 🐛
**Problem:** Display number for "KARTEN" and card number below flag is wrong, still including deleted cards.

**Location:**
- Dashboard stat box showing "X KARTEN"
- "LERNEN STARTEN" button showing card count

### **Feature Request: Edit Cards** ✨
**Requirement:** Add edit functionality for cards with pencil icon
**Locations needed:**
1. **Before adding cards** (Camera scanner confirmation view)
2. **After adding cards** (Card Management view - "Karten verwalten")

**Fields to edit:**
- Front (German word)
- Back (Translation)
- Example sentence

---

## ✅ **Solutions Implemented**

### **Fix #1: Card Count Refresh System** 

**Problem:** SwiftData @Query wasn't immediately reflecting deletions

**Solution:** Implemented notification-based refresh system

#### **How it Works:**
```
User Action (add/edit/delete card)
    ↓
Save to database
    ↓
Post notification: "CardsDidChange"
    ↓
ContentView listens for notification
    ↓
Forces UI refresh with new UUID
    ↓
@Query re-evaluates
    ↓
Correct count displayed
```

#### **Code Changes:**

**1. ContentView.swift** - Added refresh listener:
```swift
@State private var refreshID = UUID()

.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CardsDidChange"))) { _ in
    // Force refresh when cards are added/deleted/edited
    refreshID = UUID()
}
```

**2. All Save/Delete Operations** - Post notification:
```swift
// After saving/deleting
NotificationCenter.default.post(name: NSNotification.Name("CardsDidChange"), object: nil)
```

**Modified Files:**
- ✅ `ContentView.swift` - Added listener
- ✅ `AddCardView.swift` - Posts after saving (manual + camera)
- ✅ `CardManagementView.swift` - Posts after deleting
- ✅ `EditCardView.swift` - Posts after editing

---

### **Feature #2: Edit Card View** ✏️

**New File:** `EditCardView.swift`

Full-screen edit interface with:
- **Front field** (German word) - Blue
- **Back field** (Translation) - Green
- **Example field** (Optional) - Purple
- **Save button** - Only enabled when changes made
- **Success animation** - Visual feedback on save
- **Manga-styled** - Matches app design

#### **Features:**
✅ Edit any field via keyboard
✅ Multiline support for example sentences
✅ Validation (German and translation required)
✅ Change detection (shows warning if unsaved)
✅ Focus management (auto-advance fields)
✅ Haptic feedback
✅ Success animation
✅ Auto-dismiss after save

#### **UI Design:**
```
┌────────────────────────────────────┐
│  [X]    EDIT CARD                  │
├────────────────────────────────────┤
│                                    │
│        編集                         │
│   KARTE BEARBEITEN                 │
│                                    │
│  🇩🇪 DEUTSCH                       │
│  ┌──────────────────────────────┐  │
│  │ Sonne                        │  │
│  └──────────────────────────────┘  │
│                                    │
│  🌍 ÜBERSETZUNG                    │
│  ┌──────────────────────────────┐  │
│  │ sun                          │  │
│  └──────────────────────────────┘  │
│                                    │
│  📝 BEISPIELSATZ (Optional)        │
│  ┌──────────────────────────────┐  │
│  │ The sun shines brightly.     │  │
│  └──────────────────────────────┘  │
│                                    │
│  ⚠️ ÄNDERUNGEN                     │
│  Du hast ungespeicherte Änderungen│
│                                    │
│  ┌──────────────────────────────┐  │
│  │      保存                      │  │
│  │  ÄNDERUNGEN SPEICHERN         │  │
│  └──────────────────────────────┘  │
│                                    │
└────────────────────────────────────┘
```

---

### **Feature #3: Edit in Card Management** 🛠️

**Updated:** `CardManagementView.swift`

Added **"Bearbeiten" button** (pencil icon) to each card row.

#### **Card Row Layout:**
```
┌─────────────────────────────────────────┐
│ VORDERSEITE                  🔄          │
│ Hallo                                   │
│ → hello                                 │
│ 💬 Hello! How are you?                  │
│                                         │
│ [✏️ Bearbeiten]  [🗑️ Löschen]  ✓3  ✗1  │
└─────────────────────────────────────────┘
```

#### **Workflow:**
1. User opens "Karten verwalten"
2. Sees list of all cards
3. Clicks "Bearbeiten" (pencil icon)
4. EditCardView sheet opens
5. User edits fields
6. User clicks "ÄNDERUNGEN SPEICHERN"
7. Card updated in database
8. Sheet dismisses
9. List refreshes with new values

---

### **Feature #4: Edit in Camera Scanner** 📸

**Updated:** `CameraScannerView.swift`

Added **inline editing** for OCR-extracted words **before** they're saved to database.

#### **Before (Old):**
```
[Extracted Word Row]
Hallo
→ hello
💬 Hello! How are you?
                        [X Remove]
```

#### **After (New):**
```
[Extracted Word Row - Display Mode]
Hallo
→ hello
💬 Hello! How are you?
                [✏️ Edit]  [X Remove]

[Tap edit button]

[Extracted Word Row - Edit Mode]
┌─────────────────────────────────┐
│ Deutsch:                        │
│ ┌─────────────────────────────┐ │
│ │ Hallo                       │ │
│ └─────────────────────────────┘ │
│                                 │
│ Übersetzung:                    │
│ ┌─────────────────────────────┐ │
│ │ hello                       │ │
│ └─────────────────────────────┘ │
│                                 │
│ Beispielsatz (optional):        │
│ ┌─────────────────────────────┐ │
│ │ Hello! How are you?         │ │
│ └─────────────────────────────┘ │
│                                 │
│ [Abbrechen]    [Speichern]      │
└─────────────────────────────────┘
```

#### **Inline Edit Features:**
✅ Edit all three fields (German, translation, example)
✅ Text fields appear in-place
✅ "Abbrechen" button (cancel changes)
✅ "Speichern" button (save changes)
✅ Blue border when editing
✅ Haptic feedback on save
✅ Instant visual update

#### **Technical Implementation:**
```swift
struct ExtractedWordRow: View {
    @Binding var word: ExtractedWord  // Changed from `let` to `@Binding`
    @State private var isEditing = false
    @State private var editGerman: String
    @State private var editTranslation: String
    @State private var editExample: String
    
    // Toggle between display and edit modes
    // Changes saved directly to binding
}
```

#### **Usage in Parent:**
```swift
// Changed from ForEach(extractedWords)
ForEach(Array(extractedWords.enumerated()), id: \.element.id) { index, _ in
    ExtractedWordRow(
        word: $extractedWords[index],  // Pass binding
        onRemove: {
            extractedWords.remove(at: index)
        }
    )
}
```

---

## 🎬 **User Workflows**

### **Workflow 1: Edit from Card Management**
```
1. User opens dashboard
2. Taps "KARTEN VERWALTEN" button
3. CardManagementView opens
4. User selects language (English/Spanish)
5. Sees list of all cards for that language
6. Finds card to edit
7. Taps "Bearbeiten" button (blue, with pencil icon)
8. EditCardView sheet opens
9. User modifies:
   - German word
   - Translation
   - Example sentence
10. Taps "ÄNDERUNGEN SPEICHERN"
11. Success animation plays (✓)
12. Sheet dismisses after 1 second
13. Card list refreshes with new values
14. Dashboard card count updates (if needed)
```

---

### **Workflow 2: Edit from Camera (Before Save)**
```
1. User takes photo of vocabulary list
2. OCR extracts words
3. AI generates translations + examples
4. Confirmation screen shows extracted words
5. User notices mistake in word
6. Taps "✏️" button on that word
7. Inline edit mode activates
8. User corrects:
   - German word (typo)
   - Translation (wrong)
   - Example sentence (better wording)
9. Taps "Speichern"
10. Edit mode closes
11. Word updated in list
12. User reviews other words
13. Taps "ALLE HINZUFÜGEN"
14. All words (including edited ones) saved to database
```

---

### **Workflow 3: Delete & Count Updates**
```
1. User in Card Management
2. Taps "Löschen" on a card
3. Confirmation alert appears
4. User confirms deletion
5. Card removed from database
6. "CardsDidChange" notification posted
7. ContentView receives notification
8. refreshID updated → UI refresh
9. @Query re-evaluates
10. Dashboard shows updated count: "24 KARTEN" → "23 KARTEN"
11. "LERNEN STARTEN" button shows new count
```

---

## 🧪 **Testing Checklist**

### **Test Edit Functionality:**
- [ ] Open CardManagementView
- [ ] Select English deck
- [ ] Tap "Bearbeiten" on a card
- [ ] Modify German word
- [ ] Modify translation
- [ ] Modify example sentence
- [ ] Leave example blank (optional field)
- [ ] Tap "ÄNDERUNGEN SPEICHERN"
- [ ] Verify success animation appears
- [ ] Verify sheet dismisses
- [ ] Verify card list shows new values

### **Test Camera Inline Edit:**
- [ ] Open camera scanner
- [ ] Take photo of vocabulary
- [ ] Wait for extraction
- [ ] Tap pencil icon on extracted word
- [ ] Verify edit mode appears
- [ ] Edit fields
- [ ] Tap "Abbrechen" → changes discarded
- [ ] Edit again
- [ ] Tap "Speichern" → changes applied
- [ ] Verify blue border during edit
- [ ] Tap "ALLE HINZUFÜGEN"
- [ ] Verify edited values saved to database

### **Test Card Count Fix:**
- [ ] Note current card count on dashboard
- [ ] Delete a card from Card Management
- [ ] Return to dashboard
- [ ] Verify card count decreased by 1
- [ ] Add a card manually
- [ ] Return to dashboard
- [ ] Verify card count increased by 1
- [ ] Add cards via camera
- [ ] Verify card count increases correctly
- [ ] Delete all cards for a language
- [ ] Verify count shows "0 KARTEN"

### **Test Edge Cases:**
- [ ] Edit card with empty example → saves as nil
- [ ] Edit card, cancel, reopen → shows original values
- [ ] Edit card while another sheet is open
- [ ] Delete card while editing (shouldn't be possible)
- [ ] Edit card, save, immediately edit again
- [ ] Camera: Edit word, remove word → doesn't crash
- [ ] Camera: Edit word, add more words → all saved correctly

---

## 📁 **Files Modified**

### **New Files:**
1. ✅ `EditCardView.swift` (Full edit interface)

### **Modified Files:**
2. ✅ `ContentView.swift` - Added refresh notification listener
3. ✅ `CardManagementView.swift` - Added edit button, posts delete notifications
4. ✅ `AddCardView.swift` - Posts save notifications
5. ✅ `CameraScannerView.swift` - Added inline editing for extracted words

---

## 🎨 **Design Consistency**

All edit interfaces follow **Manga Design System**:
- ✅ Black background
- ✅ Halftone pattern overlay
- ✅ Japanese text accents (編集)
- ✅ Color-coded fields (Blue=German, Green=Translation, Purple=Example)
- ✅ Bold, uppercase headers
- ✅ Rounded corners with thick borders
- ✅ Haptic feedback
- ✅ Smooth animations
- ✅ Success burst effects

---

## 🔧 **Technical Details**

### **Notification System:**
```swift
// Name
"CardsDidChange"

// Posted by:
- AddCardView.saveCard()
- AddCardView.handleExtractedWords()
- CardManagementView.deleteCard()
- CardManagementView.deleteAllCards()
- EditCardView.saveChanges()

// Listened by:
- ContentView (triggers UI refresh)
```

### **Binding Pattern (Camera Scanner):**
```swift
// Old (immutable):
ForEach(extractedWords) { word in
    ExtractedWordRow(word: word, onRemove: {...})
}

// New (mutable):
ForEach(Array(extractedWords.enumerated()), id: \.element.id) { index, _ in
    ExtractedWordRow(word: $extractedWords[index], onRemove: {...})
}
```

### **Change Detection (EditCardView):**
```swift
var hasChanges: Bool {
    frontText != card.front ||
    backText != card.back ||
    exampleText != (card.exampleSentence ?? "")
}

// Save button only enabled when hasChanges == true
```

### **Validation:**
```swift
var canSave: Bool {
    !frontText.trimmingCharacters(in: .whitespaces).isEmpty &&
    !backText.trimmingCharacters(in: .whitespaces).isEmpty
}

// German and translation required
// Example sentence optional
```

---

## 🚀 **Performance Considerations**

### **Refresh Optimization:**
- Notification-based refresh only triggers when data actually changes
- UUID change forces SwiftUI to re-evaluate @Query
- Minimal performance impact (happens in milliseconds)

### **Memory:**
- EditCardView dismissed after save (no memory retention)
- Inline editing uses @State (local to view)
- No memory leaks from notification observers (proper cleanup)

---

## 📊 **Impact Analysis**

### **Before:**
- ❌ Card counts showed deleted cards
- ❌ No way to fix OCR mistakes before saving
- ❌ No way to edit cards after saving (except delete + recreate)
- ❌ Frustrating for users with typos

### **After:**
- ✅ Card counts always accurate
- ✅ Can fix OCR mistakes inline before saving
- ✅ Can edit any card at any time from Card Management
- ✅ Full control over all card properties
- ✅ Better user experience

---

## 💡 **Future Enhancements**

### **Possible Additions:**
1. **Bulk Edit** - Edit multiple cards at once
2. **History** - Undo/redo for edits
3. **Duplicate Detection** - Warn if editing creates duplicate
4. **Quick Edit** - Swipe to edit gesture
5. **Edit from Review** - Edit card during review session
6. **Field-Specific Edit** - Edit just one field quickly
7. **Templates** - Save common edits as templates
8. **Batch Example Generation** - Regenerate all examples with AI

---

## 🎉 **Summary**

### **Bug Fix:**
✅ **Card count display** - Now refreshes correctly after add/delete/edit operations

### **New Features:**
✅ **EditCardView** - Full-screen card editor  
✅ **Card Management Edit** - Pencil button on every card  
✅ **Camera Inline Edit** - Fix mistakes before saving  
✅ **Notification System** - Auto-refresh counts across app  

### **User Benefits:**
- ✅ Fix OCR mistakes easily
- ✅ Correct typos without deleting cards
- ✅ Update example sentences
- ✅ See accurate card counts
- ✅ More control over vocabulary

---

**Date:** January 6, 2026  
**Features:** Edit cards, fix card counts  
**Status:** ✅ **IMPLEMENTED**  
**Files Modified:** 5 files  
**Files Created:** 1 file  
**Breaking Changes:** None  
**Ready for Testing:** Yes  

**Your flashcard app now has full editing capabilities! ✏️🎊**

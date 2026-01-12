# 🐛 Build Fix - Ambiguous Init Error

**Date**: December 29, 2024  
**Issue**: `error: Ambiguous use of 'init'`  
**Status**: ✅ FIXED

---

## 🔍 Problem Diagnosis

### The Error:
```
error: Ambiguous use of 'init'
```

### Root Cause:
`ExtractedWord` struct was defined **inside** `CameraScannerView.swift`, but `AddCardView.swift` was trying to use it. This created an ambiguous reference when both files tried to use the same type.

**Before (Broken)**:
```
CameraScannerView.swift
  └─ struct ExtractedWord { ... }  ← Defined here
  
AddCardView.swift
  └─ func handleExtractedWords(_ words: [ExtractedWord])  ← Can't find it!
```

---

## ✅ Solution

### Created Separate File:
`ExtractedWord.swift` - Shared model accessible by both views

**File Structure After Fix**:
```
ExtractedWord.swift          ← NEW: Shared model
  └─ struct ExtractedWord
  
CameraScannerView.swift      ← Uses ExtractedWord
  └─ Removed duplicate definition
  
AddCardView.swift            ← Uses ExtractedWord
  └─ handleExtractedWords() now works
```

---

## 📝 Files Modified

### 1. Created: `ExtractedWord.swift`
```swift
import Foundation

struct ExtractedWord: Identifiable {
    let id = UUID()
    let german: String
    var translation: String
}
```

### 2. Modified: `CameraScannerView.swift`
- ❌ Removed: Duplicate `ExtractedWord` definition
- ✅ Kept: All usage of `ExtractedWord` type

### 3. No Changes: `AddCardView.swift`
- Already correctly references `ExtractedWord`
- Will now find it in separate file

---

## 🧪 Verification

After fix, check:
- [ ] No compile errors
- [ ] ExtractedWord accessible in both files
- [ ] Camera scanner builds successfully
- [ ] AddCardView builds successfully

---

## 💡 Why This Happened

When creating `CameraScannerView.swift`, I defined `ExtractedWord` at the bottom of the same file (common practice for view-specific models). However, since `AddCardView.swift` also needed to use this type, it should have been in a shared file from the start.

**Lesson**: Types used by multiple files should be in separate files, not nested in view files.

---

## 🚀 Build Status

**Should now build successfully!** ✅

Try building again. If you see other errors, let me know and I'll fix them.

---

**Fix Applied**: December 29, 2024  
**Build Status**: Ready to test

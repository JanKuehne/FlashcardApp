# 🔍 Diagnostic: "Ambiguous use of 'init'" Error

## Root Cause Assessment

### Most Likely Cause: VisionKit API Complexity

`DataScannerViewController` has **multiple overloaded initializers** in VisionKit:

```swift
// iOS 16.0+
init(recognizedDataTypes: Set<RecognizedDataType>)

// iOS 16.0+ with additional parameters
init(
    recognizedDataTypes: Set<RecognizedDataType>,
    qualityLevel: QualityLevel = .balanced,
    recognizesMultipleItems: Bool = false,
    isHighFrameRateTrackingEnabled: Bool = true,
    isPinchToZoomEnabled: Bool = true,
    isGuidanceEnabled: Bool = true,
    isHighlightingEnabled: Bool = false  // iOS 16.4+
)
```

**The Problem:** When you provide some (but not all) optional parameters, Swift can't determine which initializer you want because multiple signatures match.

---

## Applied Fix

### Strategy: Use Absolute Minimal Init

**Changed to most basic form:**

```swift
func makeUIViewController(context: Context) -> DataScannerViewController {
    // Create recognized data types set with explicit type
    var recognizedDataTypes = Set<DataScannerViewController.RecognizedDataType>()
    recognizedDataTypes.insert(.text())
    
    // Create scanner with most basic init (only required parameter)
    let scanner: DataScannerViewController = .init(
        recognizedDataTypes: recognizedDataTypes
    )
    
    scanner.delegate = context.coordinator
    return scanner
}
```

**Why this should work:**
- ✅ Only uses required parameter (`recognizedDataTypes`)
- ✅ Explicitly constructs Set (no array literal)
- ✅ Explicit return type annotation
- ✅ Uses `.init()` syntax which is more explicit
- ✅ No optional parameters that could cause ambiguity

---

## If Build Still Fails

### The error might NOT be in CameraScannerView!

Xcode's "Ambiguous use of 'init'" error can be **misleading about location**. Check:

### 1. **Check Exact Error Location**
   - In Xcode, click the error in the Issue Navigator
   - Look at the **exact line number** highlighted
   - The error might be in a completely different file

### 2. **Check for Other Init Calls**
   Possible culprits in your project:
   ```swift
   // ModelContainer init
   ModelContainer(for: schema, configurations: [modelConfiguration])
   
   // ExtractedWord init
   ExtractedWord(german: german, translation: translation)
   
   // Any SwiftData model init
   Flashcard(...), Deck(...), UserProgress(...), etc.
   ```

### 3. **Check iOS Deployment Target**
   - VisionKit's `DataScannerViewController` requires **iOS 16.0+**
   - In Xcode: Target → General → Minimum Deployments
   - Should be iOS 16.0 or higher

### 4. **Check Framework Linking**
   - Target → Build Phases → Link Binary With Libraries
   - Ensure **VisionKit.framework** is present

### 5. **Clean Build**
   Sometimes Xcode caches cause phantom errors:
   ```
   1. Product → Clean Build Folder (⇧⌘K)
   2. Delete Derived Data:
      - Xcode → Settings → Locations → Derived Data → Click arrow
      - Delete the FlashcardApp folder
   3. Restart Xcode
   4. Build again (⌘B)
   ```

---

## Debugging Questions for User

If build still fails, I need to know:

1. **Which file and line number** does Xcode highlight when you click the error?
2. **What's your iOS deployment target?** (Check Target → General)
3. **Can you see the full error message?** (Sometimes there's more detail below)
4. **Does the error appear in Build Output or Issue Navigator?**

---

## Alternative Solutions

### Option A: Wrap in @available check
```swift
@available(iOS 16.0, *)
struct DataScannerRepresentable: UIViewControllerRepresentable {
    // ... existing code
}
```

### Option B: Use older VisionKit API
If targeting iOS 15, use `VNRecognizeTextRequest` instead of `DataScannerViewController`

### Option C: Make camera feature iOS 16+ only
```swift
if #available(iOS 16.0, *) {
    // Camera scanner code
} else {
    // Fallback: manual entry only
}
```

---

## Status: Awaiting Build Result

**Latest Fix Applied:** Ultra-minimal DataScannerViewController init
**Confidence Level:** High - this should resolve VisionKit init ambiguity
**Next Step:** Try building and report exact error if it persists
